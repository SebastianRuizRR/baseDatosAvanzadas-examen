# Diagrama de Despliegue — Misión Emprende UDD

```mermaid
graph TB
  subgraph Cliente
    B[Navegador]
  end

  subgraph us_east_1["AWS us-east-1 — Región Primaria"]
    CF[CloudFront\nCDN + HTTPS]
    S3FE[S3 Frontend\nHTML/CSS/JS]
    S3MM[S3 Multimedia\nImágenes/Videos]
    APIGW[API Gateway\nHTTP API]
    subgraph Lambdas
      LA[λ Acceso]
      LP[λ Profesor]
      LS[λ Sesiones]
      LF[λ Fases 1-5]
    end
    DB1[(DynamoDB\nPrimaria\nus-east-1)]
    S3DL[S3 Data Lake\nExport DynamoDB]
    ATH[AWS Athena\nSQL Analytics]
    DASH[Dashboard\nKPIs]
    CW[CloudWatch\nLogs/Métricas]
  end

  subgraph us_west_2["AWS us-west-2 — Réplica"]
    DB2[(DynamoDB\nRéplica\nus-west-2)]
  end

  subgraph IaC["IaC — Máquina Dev"]
    TF[main.tf\nTerraform]
    ANS[deploy.yml\nAnsible]
    SAM[template.yaml\nAWS SAM]
  end

  B -->|HTTPS| CF
  B -->|HTTPS + JWT| APIGW
  CF --> S3FE
  APIGW --> LA & LP & LS & LF
  LA & LP & LS & LF --> DB1
  LA & LP & LS & LF --> S3MM
  LA & LP & LS & LF --> CW
  DB1 <-->|Global Tables\nRéplica activa-activa| DB2
  DB1 -->|Export| S3DL
  S3DL --> ATH
  ATH --> DASH
  TF -->|terraform apply| CF & S3FE & S3MM & APIGW & DB1 & DB2 & S3DL & ATH
  ANS -->|sam build + deploy| Lambdas
```

---

> Versiones adicionales del diagrama disponibles en la carpeta `Documentation/`:
> - `diagrama-despliegue.png` — imagen lista para insertar en PowerPoint
> - `diagrama-despliegue.svg` — versión vectorial escalable
> - `diagrama-despliegue.html` — versión interactiva para abrir en navegador
