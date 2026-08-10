# Contenido para la Presentación — Certamen II
## Bases de Datos Avanzadas — Misión Emprende UDD
**Fecha de presentación:** 12 de agosto de 2026  
**Entrega PPT:** máximo 11 de agosto (un día antes)

---

## 1. Introducción

**Proyecto:** Misión Emprende UDD  
**Tipo:** Juego educativo interactivo en la nube  
**Contexto:** La asignatura Bases de Datos Avanzadas requería construir una aplicación real en AWS con base de datos NoSQL distribuida, herramientas de Infrastructure as Code y una demostración en vivo.

El equipo tomó una aplicación previamente construida en Django + MySQL y la migró a una arquitectura completamente serverless en AWS. Esto implicó rediseñar la capa de datos, reescribir el backend, orquestar la infraestructura con Terraform y automatizar el despliegue con Ansible.

---

## 2. Índice

1. Introducción
2. Problemática del caso
3. Solución propuesta
4. Costos y factibilidad económica
5. Diagrama de despliegue
6. Terraform + Ansible
7. Arquitectura distribuida: DynamoDB Global Tables
8. Demo de la aplicación
9. Conclusión

---

## 3. Problemática del caso

### ¿Qué es Misión Emprende?

Misión Emprende es un juego de emprendimiento para ser jugado durante una clase universitaria. Existen dos roles:

- **Profesor:** crea una sesión, forma grupos y controla en qué fase está la clase.
- **Estudiantes:** ingresan con el código de su grupo y completan desafíos por fases para ganar tokens (puntos).

El juego tiene 5 fases: Equipo, Empatía, Creatividad, Pitch y Evaluación Final.

### Problema técnico original

La versión anterior usaba Django (Python) + MySQL corriendo en un servidor local. Esto generaba los siguientes problemas:

| Problema | Impacto |
|---|---|
| Servidor único | Si el servidor falla, toda la clase queda sin acceso |
| Sin replicación de datos | Pérdida de datos ante falla de disco |
| Sin escalabilidad | Si se conectan 30 grupos al mismo tiempo, el servidor se degrada |
| Mantenimiento manual | Requería administrar SO, parches y dependencias |
| Sin distribución geográfica | Un único punto de falla en una sola máquina |

### Objetivo

Migrar a una arquitectura distribuida en AWS que sea tolerante a fallos, escalable sin intervención manual y de bajo costo operativo.

---

## 4. Solución propuesta

### Arquitectura serverless en AWS

Se eliminó el servidor único y se adoptó el modelo *pay-per-use* de AWS. La solución completa tiene estas capas:

| Capa | Tecnología | Función |
|---|---|---|
| Frontend | S3 + CloudFront | HTML/CSS/JS estático entregado vía CDN con HTTPS |
| API | API Gateway (HTTP API) | Única puerta de entrada para todas las solicitudes |
| Lógica | AWS Lambda (TypeScript) | 4 grupos de funciones: Acceso, Profesor, Sesiones, Fases |
| Base de datos | DynamoDB Global Tables | NoSQL replicada activa-activa entre us-east-1 y us-west-2 |
| Multimedia | S3 (bucket separado) | Imágenes y recursos del juego, acceso por URL prefirmada |
| Analytics | S3 Data Lake + AWS Athena | Exportación de datos y consultas SQL para Big Data |
| Observabilidad | CloudWatch | Logs, métricas y alertas de todas las funciones Lambda |

### ¿Por qué serverless?

- **Sin servidores que administrar:** AWS gestiona la disponibilidad, los parches y la escala.
- **Costo por uso:** Si no hay tráfico, el costo es $0. Lambda cobra por ejecución, no por hora.
- **Escala automática:** Lambda puede ejecutar miles de instancias en paralelo sin configuración adicional.
- **Alta disponibilidad nativa:** API Gateway y Lambda tienen SLA del 99.95%.

### Flujo de una solicitud típica

1. El estudiante abre la aplicación en su navegador → llega a CloudFront (HTTPS).
2. CloudFront sirve los archivos HTML/CSS/JS desde S3.
3. El frontend hace una llamada al API Gateway con el token del grupo.
4. API Gateway enruta la solicitud a la Lambda correspondiente (ej: Lambda Fase 1).
5. La Lambda valida el token, aplica las reglas del juego y lee/escribe en DynamoDB.
6. DynamoDB replica automáticamente el cambio a us-west-2.
7. La respuesta llega de vuelta al navegador del estudiante.

---

## 5. Costos y factibilidad económica

### Costos de desarrollo (únicos)

| Categoría | Costo estimado (CLP) |
|---|---:|
| Recursos Humanos (desarrolladores) | $3.530.000 |
| Implementación / Migración | $171.000 |
| Contingencia (10-15%) | $207.500 |
| **Total desarrollo** | **$3.908.500** |

*Recursos Humanos:* 2 desarrolladores backend (80 h c/u a $15.000/h), 1 frontend (40 h a $12.000/h), 1 arquitecto cloud (20 h a $25.000/h), 1 QA (15 h a $10.000/h).

### Costos operativos mensuales en AWS

| Servicio | Costo mensual (USD) |
|---|---:|
| DynamoDB Global Tables | $2.50 |
| Lambda (8 funciones) | $0.20 |
| API Gateway | $0.02 |
| S3 Frontend + Multimedia | $0.17 |
| S3 Data Lake + Athena | $0.02 |
| CloudFront | $0.42 |
| CloudWatch Logs | $0.25 |
| **Total AWS/mes** | **$3.58 USD** |

Licencias: $0 (toda la cadena usa software open source: Node.js, TypeScript, Terraform, Ansible, AWS SAM).

### Resumen económico

| Período | Costo |
|---|---:|
| Desarrollo inicial (único) | $3.908.500 CLP |
| Operación año 1 (AWS + O&M + IA) | ~$716.300 CLP |
| **Total año 1** | **~$4.624.800 CLP** |
| Años siguientes | ~$716.300 CLP/año |

**Conclusión de factibilidad:** La arquitectura serverless tiene costo marginal casi cero. El mayor costo (85%) es el desarrollo inicial de Recursos Humanos, no la nube. Si el número de sesiones se triplica, el costo de infraestructura no se triplica gracias al modelo PAY_PER_REQUEST de DynamoDB y Lambda.

---

## 6. Diagrama de despliegue

Ver archivo adjunto: [`diagrama-despliegue.md`](./diagrama-despliegue.md)

También disponible como imagen en:
- `Documentation/diagrama-despliegue.png` — captura lista para PPT
- `Documentation/diagrama-despliegue.svg` — versión vectorial

El diagrama muestra:
- El cliente conectándose vía HTTPS a CloudFront
- CloudFront sirviendo el frontend estático desde S3
- El API Gateway recibiendo todas las llamadas autenticadas
- Las 4 Lambdas ejecutando la lógica del juego
- DynamoDB replicada activa-activa entre us-east-1 (primaria) y us-west-2 (réplica)
- El pipeline de datos hacia S3 Data Lake → Athena → Dashboard
- La capa IaC: Terraform (infraestructura) + Ansible (despliegue aplicación)

---

## 7. Terraform + Ansible

### Terraform (`main.tf`)

Terraform es la herramienta de Infrastructure as Code (IaC) que crea y gestiona todos los recursos de AWS mediante código declarativo.

**¿Qué crea el `main.tf` de este proyecto?**

| Recurso | Detalle |
|---|---|
| DynamoDB Global Table | `MisionEmprende-prod`, PAY_PER_REQUEST, réplica automática a us-west-2 |
| S3 Frontend | Bucket privado para HTML/CSS/JS |
| CloudFront Distribution | CDN con HTTPS, apuntando al bucket S3 |
| S3 Multimedia | Bucket separado para imágenes y videos del juego |
| S3 Data Lake | Bucket para exportaciones de DynamoDB |
| Athena Workgroup | Entorno para queries SQL sobre el Data Lake |

**Comando para desplegar toda la infraestructura:**
```bash
terraform init && terraform apply
```

En minutos, Terraform crea todos los recursos en AWS desde cero, de forma reproducible y versionada en Git.

### Ansible (`ansible/deploy.yml`)

Ansible automatiza el despliegue de la aplicación (código) sobre la infraestructura creada por Terraform.

**¿Qué hace el playbook de Ansible?**

1. `npm ci` — instala dependencias del backend TypeScript
2. `sam build` — compila las funciones Lambda
3. `sam deploy` — despliega el stack de Lambdas + API Gateway en AWS
4. Extrae automáticamente la URL del API Gateway del output de CloudFormation
5. Actualiza `frontend/compartido/js/api.js` con la URL real
6. Sube todos los archivos del frontend al bucket S3
7. Invalida la caché de CloudFront para que los usuarios vean los cambios inmediatamente

**Comando para ejecutar el despliegue completo:**
```bash
ansible-playbook ansible/deploy.yml \
  -e "bucket_frontend=<BUCKET>" \
  -e "id_cloudfront=<CF_ID>"
```

### Flujo completo de despliegue

```
[Terraform]  →  Infraestructura AWS (DynamoDB, S3, CloudFront, Athena)
     ↓
[Ansible]    →  Código de aplicación (Lambda, API Gateway, Frontend en S3)
     ↓
[CloudFront] →  Usuarios acceden a la app vía HTTPS
```

---

## 8. Arquitectura distribuida: DynamoDB Global Tables

### Motor seleccionado

**DynamoDB** — base de datos NoSQL serverless administrada por AWS, modelo clave-valor + documentos.

### Arquitectura seleccionada

**Replicada:** DynamoDB Global Tables con replicación activa-activa.

### ¿Qué es DynamoDB Global Tables?

Global Tables es la funcionalidad de DynamoDB que replica automáticamente los datos entre múltiples regiones AWS. En este proyecto:

| | Región | Rol |
|---|---|---|
| **Nodo primario** | `us-east-1` (N. Virginia) | Creación, escritura y lectura principal |
| **Nodo réplica** | `us-west-2` (Oregon) | Réplica activa, puede leer y escribir |

La replicación es **activa-activa**: ambos nodos pueden recibir escrituras. DynamoDB se encarga de la sincronización en milisegundos.

### ¿Por qué replicada y no particionada?

- **Tolerancia a fallos:** Si una región AWS completa falla, la otra sigue operativa.
- **Baja latencia global:** Usuarios en distintos continentes acceden al nodo más cercano.
- **Administración cero:** DynamoDB gestiona el conflicto de escrituras concurrentes automáticamente usando "last-writer-wins".
- **Para la rúbrica:** "botar el nodo principal" (eliminar la réplica us-east-1) deja la aplicación funcionando desde us-west-2.

### Prueba de arquitectura distribuida

**Con todos los nodos activos:**
- Acceder a la aplicación → funcionamiento normal
- Mostrar en la consola AWS ambas regiones activas en DynamoDB

**Botando el nodo principal (us-east-1):**
- Desde la consola de DynamoDB → Tabla → Global Tables → Eliminar réplica `us-east-1`
- La aplicación continúa respondiendo desde `us-west-2`
- Demostrar que los datos siguen accesibles

**Nota de respaldo:** Si la réplica `us-west-2` no se pudo crear (limitación de AWS Academy), DynamoDB en `us-east-1` tiene alta disponibilidad nativa en 3 zonas de disponibilidad (AZs). Se puede demostrar las AZs desde la consola como arquitectura distribuida a nivel de zona.

### Modelo de datos en DynamoDB (single-table design)

| PK | SK | Descripción |
|---|---|---|
| `SESION#123` | `METADATOS` | Datos de la sesión del juego |
| `SESION#123` | `GRUPO#A` | Información del grupo A |
| `SESION#123` | `ALUMNO#1` | Estudiante dentro del grupo |
| `SESION#123` | `PALABRA#A#EQUIPO` | Progreso en Fase 1 |

---

## 9. Demo de la aplicación

> La demostración se realiza fuera de la PPT. Tener video de respaldo preparado.

### Checklist de demo

- [ ] Mostrar la URL de CloudFront funcionando en el navegador (HTTPS)
- [ ] Crear una sesión como Profesor → mostrar el panel de control
- [ ] Ingresar como Estudiante con código de grupo → completar una actividad
- [ ] Mostrar en consola AWS DynamoDB → tabla `MisionEmprende-prod` → ver ítems creados
- [ ] (Si Global Tables activas) Mostrar ambas regiones en la tabla
- [ ] Botar nodo / mostrar AZs → demonstrar que la app sigue funcionando
- [ ] Opcionalmente: abrir CloudWatch Logs → mostrar trazas de las Lambdas ejecutándose

### URLs necesarias para la demo

- **App:** URL de CloudFront (obtenida del output de Terraform)
- **Consola AWS:** https://console.aws.amazon.com/dynamodb

### Video de respaldo

Grabar con anticipación:
1. El flujo completo de creación de sesión y juego de una fase
2. La demostración de los dos nodos DynamoDB

---

## 10. Conclusión

### Lo que se logró

- Se migró con éxito una aplicación Django/MySQL monolítica a una arquitectura serverless en AWS.
- Se implementó una base de datos NoSQL distribuida con replicación activa-activa entre dos regiones.
- Se automatizó completamente el despliegue mediante Terraform (infraestructura) + Ansible (código).
- El costo operativo en AWS es de ~$3.58 USD/mes, prácticamente $0 en momentos sin uso.
- La arquitectura puede escalar a cientos de grupos simultáneos sin cambios de configuración.

### Lecciones aprendidas

- **El diseño de datos NoSQL es diferente a SQL:** En DynamoDB, primero se definen los patrones de acceso y luego se diseña la tabla (single-table design). No hay JOINs ni esquemas flexibles a posteriori.
- **IaC es indispensable:** Terraform permitió reproducir toda la infraestructura en minutos, eliminando errores manuales y documentando el estado real de la nube en código.
- **Serverless no es gratis de complejidad:** La depuración de Lambdas requiere CloudWatch; el cold start puede afectar la primera respuesta; la coordinación entre SAM (Lambdas) y Terraform (infraestructura) requiere orden de despliegue explícito.
- **Las cuentas de AWS Academy tienen limitaciones:** Algunos servicios y permisos no están disponibles; adaptarse a esto forma parte del trabajo de arquitectura en contextos reales con restricciones.

### Próximos pasos (Examen)

- Integrar AWS Athena para consultas SQL sobre el Data Lake (ya aprovisionado en `main.tf`).
- Definir al menos 5 KPIs del juego y crear un dashboard de visualización.
- Exportar datos de DynamoDB al S3 Data Lake y ejecutar queries Athena para responder los KPIs.
