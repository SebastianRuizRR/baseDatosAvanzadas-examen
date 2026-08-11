terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ── Proveedor primario (us-east-1) ──────────────────────────────────────────
provider "aws" {
  region = var.region_primaria
}

# ── Proveedor réplica (us-west-2) ───────────────────────────────────────────
# Necesario para que Terraform cree recursos en la región de réplica.
provider "aws" {
  alias  = "replica"
  region = var.region_replica
}

data "aws_caller_identity" "actual" {}

# ── Variables ────────────────────────────────────────────────────────────────
variable "entorno" {
  description = "Entorno de despliegue"
  type        = string
  default     = "prod"
}

variable "region_primaria" {
  description = "Región AWS principal"
  type        = string
  default     = "us-east-1"
}

variable "region_replica" {
  description = "Región AWS para réplica DynamoDB"
  type        = string
  default     = "us-west-2"
}

variable "nombre_tabla" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
  default     = "MisionEmprende-prod"
}

locals {
  prefijo = "mision-emprende-${var.entorno}-${data.aws_caller_identity.actual.account_id}"
  tags = {
    Proyecto = "MisionEmprendeUDD"
    Entorno  = var.entorno
    IaC      = "Terraform"
  }
}

# ════════════════════════════════════════════════════════════════════════════
# DynamoDB — Tabla principal con réplica (Global Tables v2)
#
# ⚠️  AWS Academy: verificar que LabRole tenga permiso dynamodb:CreateGlobalTable
#    antes de ejecutar. Si falla, comentar el bloque `replica {}` y documentar
#    la replicación multi-AZ nativa de DynamoDB como arquitectura distribuida.
# ════════════════════════════════════════════════════════════════════════════
resource "aws_dynamodb_table" "mision_emprende" {
  name         = var.nombre_tabla
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  # Réplica requiere streams habilitados internamente — AWS lo gestiona en Global Tables v2.
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
  attribute {
    name = "GSI1PK"
    type = "S"
  }
  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  # PITR habilitado — requerido para DynamoDB Export to S3 (examen Big Data)
  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  # Réplica activa-activa en us-west-2 (Global Tables v2)
  replica {
    region_name = var.region_replica
  }

  tags = local.tags
}

# ════════════════════════════════════════════════════════════════════════════
# S3 — Frontend (privado, servido por CloudFront)
# ════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket" "frontend" {
  bucket = "${local.prefijo}-frontend"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ════════════════════════════════════════════════════════════════════════════
# S3 — Hosting estático del frontend (sin CloudFront — AWS Academy no permite
# crear CloudFront OAC ni OAI desde el rol LabRole)
# ════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# Política de lectura pública para el hosting estático
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# ════════════════════════════════════════════════════════════════════════════
# S3 — Multimedia (imágenes y videos, acceso por URL pre-firmada)
# ════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket" "multimedia" {
  bucket = "${local.prefijo}-multimedia"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "multimedia" {
  bucket = aws_s3_bucket.multimedia.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# ════════════════════════════════════════════════════════════════════════════
# S3 — Data Lake para Athena (examen Big Data)
# ════════════════════════════════════════════════════════════════════════════
resource "aws_s3_bucket" "datalake" {
  bucket = "${local.prefijo}-datalake"
  tags   = merge(local.tags, { Uso = "BigData-Athena" })
}

resource "aws_s3_bucket_public_access_block" "datalake" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Carpeta lógica para resultados de queries Athena
resource "aws_s3_object" "athena_resultados" {
  bucket  = aws_s3_bucket.datalake.id
  key     = "athena-resultados/"
  content = ""
}

# ════════════════════════════════════════════════════════════════════════════
# Athena — Base de datos para KPIs (examen)
# ════════════════════════════════════════════════════════════════════════════
resource "aws_athena_database" "mision_emprende" {
  name   = "mision_emprende_db"
  bucket = aws_s3_bucket.datalake.id

  force_destroy = true
}

resource "aws_athena_workgroup" "mision_emprende" {
  name = "${local.prefijo}-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.datalake.bucket}/athena-resultados/"
    }
  }

  tags = local.tags
}

# ════════════════════════════════════════════════════════════════════════════
# Outputs
# ════════════════════════════════════════════════════════════════════════════
output "url_frontend" {
  description = "URL pública del frontend (S3 static website)"
  value       = "http://${aws_s3_bucket.frontend.id}.s3-website-${var.region_primaria}.amazonaws.com"
}

output "nombre_bucket_frontend" {
  description = "Nombre del bucket S3 del frontend"
  value       = aws_s3_bucket.frontend.id
}

output "nombre_bucket_multimedia" {
  description = "Nombre del bucket S3 de multimedia"
  value       = aws_s3_bucket.multimedia.id
}

output "nombre_bucket_datalake" {
  description = "Nombre del bucket S3 del data lake"
  value       = aws_s3_bucket.datalake.id
}

output "nombre_tabla_dynamodb" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.mision_emprende.name
}

output "arn_tabla_dynamodb" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.mision_emprende.arn
}
