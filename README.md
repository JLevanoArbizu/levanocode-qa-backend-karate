# Reto de Automatización QA – BackEnd (API ServeRest)

<p align="center">
  <img src="https://img.shields.io/badge/Karate%20DSL-000000?style=for-the-badge&logo=Karate&logoColor=white" alt="Karate DSL" />
  <img src="https://img.shields.io/badge/Java%2017-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java 17" />
  <img src="https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white" alt="Maven" />
  <img src="https://img.shields.io/badge/JUnit%205-25A162?style=for-the-badge&logo=junit5&logoColor=white" alt="JUnit 5" />
  <img src="https://img.shields.io/badge/ServeRest%20API-0052CC?style=for-the-badge&logo=postman&logoColor=white" alt="ServeRest API" />
</p>

Este repositorio contiene un framework de automatización de pruebas para la API de gestión de **Usuarios de ServeRest** desarrollado con **Karate DSL**. La arquitectura ha sido completamente optimizada aplicando patrones de diseño empresariales para garantizar ejecuciones concurrentes y generación dinámica de datos.

---

## 1. Ejecución de Pruebas por Consola


### A. Ejecución Completa de la Suite
Compila el código, descarga dependencias y ejecuta la totalidad de las pruebas configuradas en los runners del proyecto:
```bash
mvn clean test
```

### B. Ejecución de un Runner Específico
Para limitar la ejecución al runner específico de la entidad de usuarios:
```bash
mvn test -Dtest=UsersRunner
```

### C. Ejecución por Etiquetas (Tags de Gherkin)
El archivo `users.feature` cuenta con etiquetas que permiten agrupar los escenarios de prueba:
*   `@e2e`: Define la suite completa de extremo a extremo a nivel de Feature.
*   `@smoke`: Escenarios clave de verificación rápida.

*   **Ejecutar solo pruebas rápidas (@smoke)**:
    ```bash
    mvn test "-Dkarate.options=--tags @smoke"
    ```
*   **Ejecutar la regresión completa (@e2e)**:
    ```bash
    mvn test "-Dkarate.options=--tags @e2e"
    ```

### D. Ejecución Directa de un Archivo Feature
Ejecuta de forma explícita el archivo `.feature` sin pasar por la clase runner de JUnit:
```bash
mvn test "-Dkarate.options=classpath:api/users/users.feature"
```

### E. Ejecución por Entorno de Pruebas (Multi-Environment)
El archivo `karate-config.js` reconfigura la URL base y tiempos de espera según el ambiente inyectado en la propiedad del sistema `karate.env`:
*   **Ejecución en QA**:
    ```bash
    mvn test "-Dkarate.env=QA"
    ```
*   **Ejecución en Producción**:
    ```bash
    mvn test "-Dkarate.env=PROD"
    ```

---

## 2. Requisitos Previos de Configuración

Para garantizar una correcta compilación y ejecución de las pruebas, verifique contar con las siguientes herramientas en el sistema:

*   **Java JDK 17** o superior, configurado correctamente en las variables de entorno.
*   **Apache Maven 3.8** o superior, con su correspondiente binario en el PATH del sistema.

---

## 3. Mejoras Clave del Framework

La arquitectura del proyecto ha incorporado optimizaciones técnicas de nivel empresarial que mejoran la flexibilidad y velocidad:

1. **Generación Dinámica de Payloads en Memoria**: Se eliminó la dependencia de plantillas JSON estáticas del disco. Ahora los payloads de las peticiones se configuran en caliente a través de `DataGenerator.js`, facilitando modificaciones rápidas previas al envío (por ejemplo, al actualizar datos con `PUT` vía `* set userData.nome = '...'`).
2. **Puente JS-Java (Java Faker con Fallback Integrado)**: Karate interactúa mediante GraalJS con la biblioteca `com.github.javafaker.Faker` para inyectar datos realistas y únicos. En caso de fallar la carga de la biblioteca, el script activa un fallback inteligente en JavaScript nativo basado en entropía por timestamps para evitar colisiones de registros en el servidor.
3. **Estrategia Chained CRUD (Thread-Safe)**: Las operaciones de creación (POST), validación de correo duplicado, consulta (GET), actualización (PUT) y borrado (DELETE) se ejecutan dentro del mismo escenario secuencial en el hilo correspondiente. Esto garantiza la idempotencia y elimina condiciones de carrera (race conditions), logrando una paralelización segura en pipelines CI/CD.
4. **Validación Estricta de Contrato**: Se sustituyeron múltiples aserciones por una validación estructural recursiva del árbol JSON contra un esquema centralizado (`schemas/user-schema.json`) mediante Fuzzy Matchers de Karate (`match response == userSchema`).
5. **Estabilidad Operativa**: Se resolvió un error sintáctico heredado en `karate-config.js` (un espacio en `karate.configure('readTimeout', 5 000)` que invalidaba el motor de ejecución), logrando que la compilación actual sea estable.

---

## 4. Integración Continua (CI/CD) con GitHub Actions

La estrategia de entrega e integración continua se define mediante cuatro flujos de trabajo (GitHub Workflows) que resguardan la salud del proyecto en cada commit:

### Detalle de los Workflows Disponibles

| Workflow | Evento Desencadenador (Trigger) | Comando Principal | Gestión de Reportes | Notificaciones |
| :--- | :--- | :--- | :--- | :--- |
| **`QA Automation - Karate Alerts`** (`karate-ci.yml`) | Push en ramas `main` o `master` | `mvn test` | Archiva reporte HTML (`retention-days: 2`) siempre | Microsoft Teams (Solo en fallos) |
| **`QA Automation - PR Smoke Validation`** (`pr-smoke-validation.yml`) | Pull Request hacia `main` o `master` | `mvn clean test -Dkarate.options="--tags @smoke"` | Archiva reporte HTML (`retention-days: 3`) siempre | Microsoft Teams (Solo en fallos) |
| **`QA Automation - Nightly E2E Regression`** (`nightly-e2e-regression.yml`) | Diario programado (Cron a las 2:00 AM PET / 07:00 UTC) y ejecución manual | `mvn clean test -Dkarate.options="--tags @e2e"` | Archiva reporte HTML (`retention-days: 7`) en fallos | Microsoft Teams (Solo en fallos) |
| **`QA Automation - Release & Certification Approval`** (`release-qa-approval.yml`) | Manual (`workflow_dispatch`) con selector de ambiente | `mvn clean test -Dkarate.env=${{ inputs.environment }}` | Archiva reporte de certificación (`retention-days: 15`) siempre | Microsoft Teams (Siempre notifica) |

### Flujo de Certificación Dinámica (Release)
El workflow `release-qa-approval.yml` permite certificar pases a entornos superiores. Al iniciarlo desde la interfaz web de GitHub Actions:
1. El usuario selecciona el **ambiente destino** (`QA`, `UAT`, o `PROD`).
2. El runner inyecta el entorno en la propiedad `-Dkarate.env`.
3. El archivo `karate-config.js` lee la propiedad y configura la `baseUrl` y tiempos de espera asignados a dicho ambiente.
4. Finalizado el test, se archiva el reporte por **15 días** como evidencia para auditorías técnicas y se notifica el estado en el canal corporativo de Teams.

---

## 5. Reportes y Evidencias

Una vez finalizadas las pruebas, se genera un reporte visual HTML interactivo detallado con la información completa de la sesión:

*   **Ubicación del Reporte**: `target/karate-reports/karate-summary.html`
*   **Visualización**: Abra el archivo directamente desde su navegador (Chrome, Firefox, Edge).
*   **Contenido**: El reporte detalla cada paso de Gherkin, mostrando cabeceras HTTP, payloads de solicitud y respuesta, códigos de estado y el tiempo de respuesta preciso expresado en milisegundos.

---

## 6. Estructura del Proyecto

La modularidad del proyecto se define bajo la estructura estándar de Maven, aplicando separación de responsabilidades:

```text
/
├── pom.xml                        # Archivo de configuración de dependencias y plugins Maven
├── README.md                      # Documentación del proyecto (esta guía)
├── docs/                          # Documentación complementaria del sistema
│   ├── arquitectura_framework.md  # Información técnica del flujo de datos
│   └── patrones_diseno.md         # Patrones de diseño implementados
└── src/test/java/
    ├── karate-config.js           # Archivo central de configuración de Karate
    ├── logback-test.xml           # Nivel y formato de logs por consola
    ├── api/
    │   └── users/
    │       ├── users.feature      # Suite de escenarios BDD para gestión de usuarios
    │       └── UsersRunner.java   # Ejecutor JUnit 5 para compilar los escenarios
    ├── helpers/
    │   └── DataGenerator.js       # Utilitario para mock de datos únicos (Faker y fallback)
    └── schemas/
        └── user-schema.json       # Definición del esquema para pruebas de contrato
```

---

## 7. Cobertura de la API y Criterios de Aceptación

Los escenarios implementados certifican completamente la gestión de la entidad de usuarios de ServeRest:

- [x] **GET /usuarios**: Recuperación paginada y controlada de la lista de usuarios.
- [x] **POST /usuarios (Positivo)**: Registro exitoso utilizando datos únicos del generador dinámico.
- [x] **POST /usuarios (Negativo)**: Validación estricta que bloquea registros con correos duplicados (Código `400`).
- [x] **GET /usuarios/{_id} (Positivo)**: Búsqueda del usuario creado y validación rigurosa del JSON Schema.
- [x] **GET /usuarios/{_id} (Negativo)**: Validación del comportamiento del servicio ante un ID de 16 caracteres inexistente (Código `400`).
- [x] **PUT /usuarios/{_id}**: Edición de campos del usuario y verificación del cambio exitoso.
- [x] **DELETE /usuarios/{_id}**: Eliminación física del recurso registrado para asegurar la limpieza del entorno.