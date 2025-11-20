# ObservatorioDB_Grupo_1: Sistema de Gestión Astronómica
# Grupo 1 - 27/11/2025

## Integrantes
- Macías, Juliana
- Cortés Cid, Francisco
- Moreno, Nahuel
- Teixido, Leonardo
---

Este repositorio contiene la implementación SQL completa para una base de datos relacional destinada a un observatorio astronómico. El sistema está diseñado sobre **MySQL/MariaDB** y se caracteriza por utilizar un modelo de herencia para clasificar cuerpos celestes, integridad transaccional robusta y funciones científicas deterministas.

## 1. Arquitectura de Datos
El núcleo del diseño implementa un patrón de **"Tabla por Tipo" (Table-per-Type)** para manejar la generalización y especialización de los objetos astronómicos.


### Esquema Relacional
* **Clase (`CuerpoCeleste`):** Centraliza los atributos físicos comunes (masa, diámetro, edad).
* **Subclases:**
    * `Estrellas`: Define tipo espectral y temperatura.
    * `Planetas`: Define temperatura media.
    * `Satelites`: Define acoplamiento de marea y el planeta anfitrión.
* **Relaciones Complejas:**
    * `Planeta_Estrella`: Permite definir sistemas solares simples o binarios (un planeta orbitando dos estrellas) y calcula la zona habitable.
    * `RegistroObservacion`: Vincula descubridores con cuerpos celestes, asegurando que no existan registros duplicados para la misma fecha.

---

## 2. Lógica de Negocio (Stored Procedures)
La manipulación de datos se realiza estrictamente a través de procedimientos almacenados que garantizan la atomicidad de las operaciones en la estructura jerárquica.

### Gestión de Transacciones
| Tipo de Operación | Descripción Técnica |
| :--- | :--- |
| **Altas (INSERT)** | **Transaccional.** Inserta primero en la tabla padre (`CuerpoCeleste`), recupera el ID generado (`LAST_INSERT_ID()`) y luego inserta en la tabla hija correspondiente (`Estrellas`, etc.) y en el registro de observación. |
| **Bajas (DELETE)** | **Cascada Lógica.** Implementa validaciones estrictas (ej. `SP_Baja_Planeta` verifica `IF EXISTS` satélites antes de borrar) y elimina referencias en orden inverso para mantener la integridad referencial. |
| **Modificaciones (UPDATE)** | **Sincronizada.** Actualiza simultáneamente los atributos de la clase y la subclase específica en una sola transacción. |

---

## 3. Utilidades Científicas (Funciones)
El sistema incluye funciones escalares deterministas para la estandarización de unidades de medida utilizadas en los reportes.

* **`FN_LY_a_KM`**: Convierte distancias de Años Luz a Kilómetros utilizando un factor de precisión alta (`DECIMAL(30, 6)`) basado en estándares de la IAU.
* **`FN_Celsius_a_Kelvin`**: Transforma temperaturas de Celsius a Kelvin, ajustando el cero absoluto (+273.15) para cálculos termodinámicos.

---

## 4. Testing y Validación
El proyecto incluye un script de pruebas de integración (`Testing_ObservatorioDB.sql`) que valida el ciclo de vida completo de los datos.

### Flujo de Pruebas Automatizado
1.  **Limpieza (`CleanupProcedure`):** Elimina datos en orden inverso a las dependencias (Hijos → Padres) para garantizar un entorno estéril.
2.  **Preparación:** Carga un escenario complejo que incluye un **Sistema Binario** (Estrellas Sirio A y B) y un planeta circumbinario (Kepler-16b) con su propia luna.
3.  **Validación de Constraints:**
    * Verifica actualizaciones de datos en múltiples tablas.
    * Comprueba errores esperados, como el intento de eliminar un planeta que aún tiene satélites orbitando (`SIGNAL SQLSTATE '45000'`).
4.  **Cálculos:** Ejecuta las UDFs para verificar la precisión de las conversiones de masa y distancia.

---

### Instalación y Uso
1.  Ejecutar el script DDL (`Create_Tablas`).
2.  Cargar las Funciones y Stored Procedures.
3.  Ejecutar el script de Pruebas para poblar y validar la base de datos.

---