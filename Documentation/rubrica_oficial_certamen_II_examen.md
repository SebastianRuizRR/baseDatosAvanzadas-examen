# Rúbrica Oficial — Certamen II y Examen
## Bases de Datos Avanzadas

**Propósito:** usar este documento como referencia rígida de lo solicitado por el profesor.  
No se agregan requisitos, criterios de evaluación, ponderaciones ni recomendaciones que no hayan sido indicadas por el profesor.

---

# 1. Certamen II

## Objetivo

> Crear y almacenar una aplicación en la nube con base de datos NoSQL con arquitectura particionada o replicada.

## Rúbrica de cumplimiento

| Criterio | Lo solicitado por el profesor | Estado |
|---|---|---|
| Aplicación en AWS | Crear o subir una aplicación a AWS. Puede ser la aplicación completa o por capas. | ☐ |
| Base de datos NoSQL | Conectar la aplicación usando MongoDB, Cassandra o DynamoDB. | ☐ |
| Arquitectura distribuida | Elegir una arquitectura para la distribución de datos: particionada o replicada. | ☐ |
| Prueba de arquitectura | Si es réplica, botar el nodo principal. Si es particionada, botar un nodo a elección. | ☐ |
| Funcionamiento con todos los nodos | Demostrar la aplicación funcionando con todos los nodos disponibles. | ☐ |
| Funcionamiento con un nodo menos | Demostrar la aplicación funcionando o el comportamiento de la arquitectura con un nodo menos. | ☐ |
| Costos | Incluir los costos del proyecto considerando la factibilidad económica vista en clases. | ☐ |
| Diagrama | Incluir diagrama de la solución / despliegue. | ☐ |
| Terraform | Utilizar Terraform. | ☐ |
| Herramienta adicional | Utilizar Chef, Puppet o Ansible. | ☐ |
| Demo | Realizar la demostración fuera de la PPT. | ☐ |
| Conclusión | Incluir conclusión en la PPT. | ☐ |

---

## 2. Motores NoSQL permitidos

Se debe utilizar uno de los siguientes:

- ☐ DynamoDB
- ☐ MongoDB
- ☐ Cassandra

**Motor seleccionado:** ______________________________

---

## 3. Arquitectura de distribución

Se debe utilizar una de las siguientes:

- ☐ Replicada
- ☐ Particionada

**Arquitectura seleccionada:** ______________________________

### Prueba asociada

**Si es replicada:**
- Botar el nodo principal.

**Si es particionada:**
- Botar un nodo a elección.

En ambos casos:
- Mostrar funcionamiento con todos los nodos.
- Mostrar funcionamiento o comportamiento con un nodo menos.

---

# 4. Costos / Factibilidad Económica

Según lo explicado por el profesor, los costos deben considerar las siguientes categorías.

## 4.1 Recursos Humanos

- Salarios.
- Contrataciones externas.
- Capacitaciones.

## 4.2 Infraestructura y Hosting

- Servidores / Cloud.
- AWS, Azure, GCP.
- CPU.
- Storage.
- RAM.
- Tráfico.

## 4.3 Licencias y Software

### Licencias

- Sistema Operativo.
- Base de Datos.
- IDE.
- Herramientas de monitoreo.

### SaaS

- Trello.
- Jira.
- Figma.
- GitHub.

## 4.4 Operaciones y Mantenimiento

- Mantenimiento evolutivo.
- Corrección de bugs.
- Nuevas funcionalidades.
- Monitoreo.
- Internet / electricidad, solo si corresponde a infraestructura on-premise.

## 4.5 Seguridad

- Certificados.
- Seguros.

## 4.6 Implementación

- Migración.

## 4.7 Contingencia

- Cambio de planes.

## 4.8 Inteligencia Artificial

- Tokens.

---

## 5. Resumen de costos

| Categoría | Costo estimado |
|---|---:|
| Recursos Humanos | $____________ |
| Infraestructura y Hosting | $____________ |
| Licencias y Software | $____________ |
| Operaciones y Mantenimiento | $____________ |
| Seguridad | $____________ |
| Implementación / Migración | $____________ |
| Contingencia | $____________ |
| IA / Tokens | $____________ |
| **Total** | **$____________** |

---

# 6. PPT — Certamen II

La presentación debe contener al menos:

1. Introducción.
2. Índice.
3. Problemática del caso.
4. Solución.
5. Costos.
6. Diagrama de la solución / despliegue.
7. Uso de Terraform + Chef, Puppet o Ansible.
8. Arquitectura para la distribución.
9. Demo de la aplicación.
10. Conclusión.

> Solo se debe salir de la PPT para la parte de demostración.

---

# 7. Entrega — Certamen II

Se requiere:

- ☐ PPT.
- ☐ URL de la aplicación funcionando.
- ☐ `main.tf`.

**Presentación:** 12 de agosto.  
**PPT:** debe entregarse al menos un día antes.

La entrega debe ser realizada por **todos los estudiantes**, no solo por un integrante del grupo.

### Respaldo

En caso de falla durante la demostración, el profesor recomienda tener:

- ☐ Video de respaldo.

---

# 8. Examen

## Objetivo

> Tomar su aplicación con base de datos distribuida y aplicar Big Data.

## Rúbrica de cumplimiento

| Criterio | Lo solicitado por el profesor | Estado |
|---|---|---|
| Base del trabajo | Tomar el trabajo realizado durante el Certamen II. | ☐ |
| KPIs | Crear al menos 5 KPIs. | ☐ |
| Big Data | Integrar la aplicación con Hadoop o Athena. | ☐ |
| Extracción de datos | Extraer datos para responder los KPIs escogidos. | ☐ |
| Dashboard | Crear un dashboard para visualizar los KPIs. | ☐ |
| Decisiones | Explicar qué decisiones se pueden tomar en base al dashboard. | ☐ |
| PPT | Elaborar una PPT que explique los pasos anteriores. | ☐ |

---

# 9. Herramienta Big Data

Se debe utilizar una de las siguientes:

- ☐ Hadoop
- ☐ Athena

**Herramienta seleccionada:** ______________________________

---

# 10. KPIs

Se deben crear al menos 5.

1. ______________________________________________
2. ______________________________________________
3. ______________________________________________
4. ______________________________________________
5. ______________________________________________

---

# 11. Entrega — Examen

Se requiere:

- ☐ PPT del examen.

**Presentación:** 19 de agosto.  
**PPT:** debe entregarse al menos un día antes.

La entrega debe ser realizada por **todos los estudiantes**, no solo por un integrante del grupo.

---

# 12. Checklist final

## Certamen II

- [ ] Aplicación en AWS.
- [ ] MongoDB, Cassandra o DynamoDB.
- [ ] Arquitectura replicada o particionada.
- [ ] Prueba con todos los nodos.
- [ ] Prueba con un nodo menos.
- [ ] Costos.
- [ ] Diagrama de despliegue.
- [ ] Terraform.
- [ ] Chef, Puppet o Ansible.
- [ ] Demo.
- [ ] PPT.
- [ ] URL funcionando.
- [ ] `main.tf`.
- [ ] Video de respaldo recomendado.

## Examen

- [ ] Trabajo del Certamen II como base.
- [ ] Al menos 5 KPIs.
- [ ] Hadoop o Athena.
- [ ] Extracción de datos.
- [ ] Dashboard.
- [ ] Decisiones basadas en el dashboard.
- [ ] PPT.
