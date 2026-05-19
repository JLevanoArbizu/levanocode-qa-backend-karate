# Reto de Automatización QA – BackEnd (API ServeRest)

![Karate](https://img.shields.io/badge/Karate%20DSL-000000?style=for-the-badge&logo=Karate&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apachemaven&logoColor=white)

Este repositorio contiene la resolución del reto de automatización para la API de Usuarios de ServeRest utilizando Karate DSL. El proyecto ha sido desarrollado aplicando patrones de diseño escalables, código limpio y generación de datos dinámica.

---

## 🚀 1. Instrucciones de Configuración

Asegúrate de tener **Java JDK 17** (o superior) y **Apache Maven (3.8+)** instalados en tu sistema antes de comenzar para poder configurar el proyecto con Karate DSL.

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/JLevanoArbizu/levanocode-qa-backend-karate.git
   cd levanocode-qa-backend-karate
   ```

2. **Compilar e instalar las dependencias del proyecto**:
   ```bash
   mvn clean install
   ```

---

## 🏃 2. Ejecución de Pruebas

El framework está preparado para ejecutarse mediante el test runner de Maven.

* **Ejecutar toda la suite de pruebas (Por Defecto)**:
  ```bash
  mvn clean test
  ```

* **Ejecutar específicamente el feature de usuarios a través del Runner**:
  ```bash
  mvn test -Dtest=UsersRunner
  ```

---

## 📊 3. Reportes y Evidencias

Al finalizar la ejecución de los tests automatizados para validar la funcionalidad completa, Karate genera un reporte visual HTML interactivo.

* **Ubicación**: `target/karate-reports/karate-summary.html`
* **Contenido**: Abre este archivo en cualquier navegador para visualizar el detalle de cada petición HTTP, headers, payloads y tiempos de respuesta, lo cual asegura la legibilidad y claridad del código ejecutado.

---

## 📋 4. Cobertura del Reto y Criterios de Aceptación

El framework ha sido diseñado para cumplir estrictamente con la historia de usuario principal:
> Como un administrador del sistema, quiero poder gestionar los usuarios a través de la API, para administrar la base de datos de usuarios.

Se han automatizado las siguientes operaciones CRUD para cumplir con los criterios de aceptación:
- [x] Se puede obtener una lista de todos los usuarios mediante el endpoint `GET /usuarios`.
- [x] Se puede registrar un nuevo usuario con datos válidos usando `POST /usuarios`.
- [x] Se puede buscar un usuario específico por su ID con `GET /usuarios/{_id}`.
- [x] Se puede actualizar la información de un usuario existente a través de `PUT /usuarios/{_id}`.
- [x] Se puede eliminar un usuario del sistema utilizando `DELETE /usuarios/{_id}`.

---

## 🏗️ 5. Informe de Estrategia de Automatización y Patrones

El framework se enfoca en la escalabilidad y cumple con los requerimientos técnicos definidos:

1. **Arquitectura 100% Paralelizable (Thread-Safe):** Para garantizar la compatibilidad con ejecuciones concurrentes en CI/CD, las operaciones transaccionales CRUD se encapsulan secuencialmente dentro de un único escenario. Esto mantiene la organización del proyecto.
2. **Generación Dinámica de Datos:** Se desarrollaron utilidades en JavaScript para el manejo adecuado y la generación de datos de prueba dinámicos mediante la interoperabilidad con Java Faker.
3. **Cobertura Integral de Escenarios:** Se manejaron diferentes flujos cubriendo exhaustivamente tanto los casos positivos como los negativos.
4. **Validación Estricta de Contrato:** Se implementaron validaciones de esquema JSON para las respuestas utilizando Fuzzy Matchers nativos de Karate.
5. **Plantillas e Inyección Dinámica:** La plantilla JSON de solicitud (`user-request.json`) se lee dinámicamente aislando los datos estáticos de la ejecución.

---

## 📂 6. Estructura del Proyecto

El proyecto está organizado separando la lógica y creando feature files específicos:

```text
/
├── pom.xml                      # Dependencias del framework (Karate core, JUnit 5, Java Faker)
├── src/test/java/
│   ├── karate-config.js         # Configuración global y baseUrl
│   ├── logback-test.xml         # Configuración de nivel de logs limpia
│   ├── api/
│   │   └── users/
│   │       ├── users.feature    # Suite Gherkin con escenarios CRUD y negativos
│   │       └── UsersRunner.java # Runner JUnit 5 para compilar y ejecutar los tests
│   ├── helpers/
│   │   └── DataGenerator.js     # Utilitario para generación dinámica de datos
│   ├── payloads/
│   │   └── user-request.json    # Plantilla base para payloads JSON
│   └── schemas/
│       └── user-schema.json     # Esquemas para validación del contrato JSON
```