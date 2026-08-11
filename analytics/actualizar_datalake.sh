#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-1"
DATABASE="mision_emprende_db"

echo "========================================"
echo " Actualizando Data Lake Misión Emprende"
echo "========================================"

TABLE_ARN=$(terraform output -raw arn_tabla_dynamodb)
DATALAKE=$(terraform output -raw nombre_bucket_datalake)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
WORKGROUP="mision-emprende-prod-${ACCOUNT_ID}-workgroup"

echo "Tabla     : $TABLE_ARN"
echo "Data Lake : $DATALAKE"
echo "Workgroup : $WORKGROUP"
echo ""

echo "1/4 Exportando DynamoDB a S3..."

EXPORT_ARN=$(aws dynamodb export-table-to-point-in-time \
  --table-arn "$TABLE_ARN" \
  --s3-bucket "$DATALAKE" \
  --s3-prefix "dynamodb-export" \
  --export-format ION \
  --region "$REGION" \
  --query 'ExportDescription.ExportArn' \
  --output text \
  --no-cli-pager)

echo "Export ARN: $EXPORT_ARN"
echo ""

echo "2/4 Esperando exportación..."

while true; do
    STATUS=$(aws dynamodb describe-export \
      --export-arn "$EXPORT_ARN" \
      --region "$REGION" \
      --query 'ExportDescription.ExportStatus' \
      --output text \
      --no-cli-pager)

    echo "Estado: $STATUS"

    if [ "$STATUS" = "COMPLETED" ]; then
        break
    fi

    if [ "$STATUS" = "FAILED" ] || [ "$STATUS" = "CANCELLED" ]; then
        echo "ERROR: exportación fallida."
        aws dynamodb describe-export \
          --export-arn "$EXPORT_ARN" \
          --region "$REGION" \
          --query 'ExportDescription.FailureMessage' \
          --output text \
          --no-cli-pager
        exit 1
    fi

    sleep 15
done

MANIFEST=$(aws dynamodb describe-export \
  --export-arn "$EXPORT_ARN" \
  --region "$REGION" \
  --query 'ExportDescription.ExportManifest' \
  --output text \
  --no-cli-pager)

ITEMS=$(aws dynamodb describe-export \
  --export-arn "$EXPORT_ARN" \
  --region "$REGION" \
  --query 'ExportDescription.ItemCount' \
  --output text \
  --no-cli-pager)

EXPORT_FOLDER=$(dirname "$MANIFEST")
NEW_LOCATION="s3://${DATALAKE}/${EXPORT_FOLDER}/data/"

echo ""
echo "Registros exportados: $ITEMS"
echo "Nueva ubicación: $NEW_LOCATION"
echo ""

echo "3/4 Actualizando mision_raw en Athena..."

ALTER_SQL="ALTER TABLE ${DATABASE}.mision_raw SET LOCATION '${NEW_LOCATION}'"

QID=$(aws athena start-query-execution \
  --query-string "$ALTER_SQL" \
  --query-execution-context Database="$DATABASE" \
  --work-group "$WORKGROUP" \
  --region "$REGION" \
  --query 'QueryExecutionId' \
  --output text \
  --no-cli-pager)

while true; do
    STATE=$(aws athena get-query-execution \
      --query-execution-id "$QID" \
      --region "$REGION" \
      --query 'QueryExecution.Status.State' \
      --output text \
      --no-cli-pager)

    echo "Athena: $STATE"

    if [ "$STATE" = "SUCCEEDED" ]; then
        break
    fi

    if [ "$STATE" = "FAILED" ] || [ "$STATE" = "CANCELLED" ]; then
        aws athena get-query-execution \
          --query-execution-id "$QID" \
          --region "$REGION" \
          --query 'QueryExecution.Status.StateChangeReason' \
          --output text \
          --no-cli-pager
        exit 1
    fi

    sleep 2
done

echo ""
echo "4/4 Verificando datos..."

QCOUNT=$(aws athena start-query-execution \
  --query-string "SELECT COUNT(*) AS total FROM ${DATABASE}.mision_raw" \
  --query-execution-context Database="$DATABASE" \
  --work-group "$WORKGROUP" \
  --region "$REGION" \
  --query 'QueryExecutionId' \
  --output text \
  --no-cli-pager)

while true; do
    STATE=$(aws athena get-query-execution \
      --query-execution-id "$QCOUNT" \
      --region "$REGION" \
      --query 'QueryExecution.Status.State' \
      --output text \
      --no-cli-pager)

    [ "$STATE" = "SUCCEEDED" ] && break

    if [ "$STATE" = "FAILED" ]; then
        echo "Error verificando Athena."
        exit 1
    fi

    sleep 2
done

TOTAL=$(aws athena get-query-results \
  --query-execution-id "$QCOUNT" \
  --region "$REGION" \
  --query 'ResultSet.Rows[1].Data[0].VarCharValue' \
  --output text \
  --no-cli-pager)

echo ""
echo "========================================"
echo " ✅ Data Lake actualizado"
echo " Registros disponibles en Athena: $TOTAL"
echo "========================================"
