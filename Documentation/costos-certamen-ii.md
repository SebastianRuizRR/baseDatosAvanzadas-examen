# Factibilidad Económica — Misión Emprende UDD
## Certamen II — Bases de Datos Avanzadas

---

## 4.1 Recursos Humanos

| Rol | Cantidad | Horas estimadas | Tarifa hora (CLP) | Total (CLP) |
|---|---|---|---|---|
| Desarrollador Backend (Lambda / TypeScript) | 2 | 80 h | $15.000 | $2.400.000 |
| Desarrollador Frontend (HTML/CSS/JS) | 1 | 40 h | $12.000 | $480.000 |
| Arquitecto Cloud (AWS / Terraform) | 1 | 20 h | $25.000 | $500.000 |
| QA / Tester | 1 | 15 h | $10.000 | $150.000 |
| **Subtotal Recursos Humanos** | | | | **$3.530.000** |

> Tarifa de mercado chileno para desarrolladores junior/semi-senior 2025. No incluye cargas sociales.

---

## 4.2 Infraestructura y Hosting (AWS)

Estimación mensual en **USD** para uso académico (baja carga: ~5 sesiones/mes, ~30 grupos).

| Servicio | Especificación | Costo mensual (USD) |
|---|---|---|
| **DynamoDB** (Global Tables) | PAY_PER_REQUEST · ~50.000 lecturas/mes · 2 regiones | $2.50 |
| **Lambda** (8 funciones) | ~10.000 invocaciones/mes · 512 MB · 15 s max | $0.20 |
| **API Gateway** (HTTP API) | ~15.000 solicitudes/mes | $0.02 |
| **S3 Frontend** | 50 MB · ~5 GB transferencia | $0.12 |
| **S3 Multimedia** | 2 GB · 500 solicitudes | $0.05 |
| **S3 Data Lake** (Athena) | 1 GB almacenamiento | $0.02 |
| **CloudFront** | ~5 GB transferencia | $0.42 |
| **Athena** | 5 queries · ~100 MB escaneados c/u | $0.00 |
| **CloudWatch Logs** | ~500 MB logs/mes | $0.25 |
| **Subtotal Infraestructura** | | **$3.58/mes** |
| **Anual** | | **~$43 USD/año** |

> Tipo de cambio referencia: 1 USD ≈ 950 CLP → **~$40.900 CLP/año**

---

## 4.3 Licencias y Software

### 4.3.1 Licencias

| Software | Licencia | Costo |
|---|---|---|
| Sistema Operativo (Ubuntu Server) | Open Source | $0 |
| Node.js 22 | MIT | $0 |
| TypeScript | Apache 2.0 | $0 |
| AWS SAM CLI | Apache 2.0 | $0 |
| Terraform (OSS) | BSL 1.1 | $0 |
| Ansible Community | GPL v3 | $0 |
| **Subtotal Licencias** | | **$0** |

> Toda la cadena de herramientas utiliza software de código abierto sin costo de licencia.

### 4.3.2 SaaS y Herramientas de Equipo

| Herramienta | Plan | Costo mensual (USD) |
|---|---|---|
| GitHub (repositorio) | Free | $0 |
| VS Code | Free | $0 |
| Figma (diseño UX) | Free (educativo) | $0 |
| Trello / Notion | Free | $0 |
| PlantUML (diagrama) | Open Source | $0 |
| **Subtotal SaaS** | | **$0** |

---

## 4.4 Operaciones y Mantenimiento (mensual)

| Ítem | Costo mensual (USD) |
|---|---|
| Mantenimiento evolutivo (2 h/mes desarrollador) | $25 |
| Monitoreo CloudWatch (alertas, dashboards) | $1 |
| Corrección de bugs (estimado) | $10 |
| **Subtotal O&M** | **$36/mes** |

---

## 4.5 Seguridad

| Ítem | Costo anual (USD) |
|---|---|
| Certificado SSL (CloudFront incluye ACM gratuito) | $0 |
| AWS WAF (opcional, post-producción) | $5/mes |
| Revisión de seguridad (1 vez/año) | $200 |
| **Subtotal Seguridad** | **~$260/año** |

---

## 4.6 Implementación / Migración

| Ítem | Costo (USD) |
|---|---|
| Migración de datos Django/MySQL → DynamoDB (8 h) | $120 |
| Pruebas de integración en entorno real (4 h) | $60 |
| **Subtotal Implementación** | **$180** |

---

## 4.7 Contingencia

| Ítem | Porcentaje | Sobre |
|---|---|---|
| Imprevistos técnicos | 10% | Recursos Humanos |
| Cambio de planes / alcance | 5% | Total proyecto |
| **Subtotal Contingencia** | | **~$207.500 CLP** |

---

## 4.8 Inteligencia Artificial (Tokens)

| Uso | Modelo | Tokens/mes (est.) | Costo (USD/mes) |
|---|---|---|---|
| Asistencia en desarrollo (Claude) | Claude Sonnet | ~500.000 | $1.50 |
| Generación de contenido educativo | Claude Haiku | ~200.000 | $0.05 |
| **Subtotal IA** | | | **$1.55/mes** |

---

## 5. Resumen de Costos

### Costos de desarrollo (únicos, en CLP)

| Categoría | Costo estimado (CLP) |
|---|---:|
| Recursos Humanos | $3.530.000 |
| Implementación / Migración | $171.000 |
| Contingencia | $207.500 |
| **Total desarrollo (único)** | **$3.908.500** |

### Costos operativos mensuales (en USD)

| Categoría | Costo mensual (USD) |
|---|---:|
| Infraestructura y Hosting (AWS) | $3.58 |
| Operaciones y Mantenimiento | $36.00 |
| Seguridad | $21.67 |
| IA / Tokens | $1.55 |
| **Total mensual** | **$62.80 USD** |
| **Total anual** | **~$754 USD** |

> Conversión a CLP (1 USD = 950 CLP): **~$716.300 CLP/año**

### Costo total primer año (desarrollo + operación)

| Período | CLP |
|---|---:|
| Desarrollo inicial (único) | $3.908.500 |
| Operación año 1 | $716.300 |
| **Total año 1** | **$4.624.800 CLP** |
| **Años siguientes** | **$716.300 CLP/año** |

---

## Notas de factibilidad económica

- **Costo marginal muy bajo**: la arquitectura serverless elimina costos de servidores en horas sin uso. Con AWS Lambda y DynamoDB PAY_PER_REQUEST, si no hay tráfico, el costo es $0.
- **Escalabilidad sin costo lineal**: si el número de sesiones se triplica, el costo de infraestructura no se triplica gracias al modelo serverless.
- **DynamoDB Global Tables**: agrega ~$2-3 USD/mes de sobrecosto por la replicación. Económicamente justificado por la alta disponibilidad.
- **En producción real**: el mayor costo es Recursos Humanos (85% del total año 1), no la nube.
