# Script de Pruebas de Integración (Testing Scope)

Este documento describe el flujo de ejecución del script de pruebas automatizado diseñado para validar la integridad, funcionalidad y consistencia de la base de datos `ObservatorioDB_Grupo_1`.

El script simula un escenario de uso real donde se registran cuerpos celestes, se modifican datos por nuevas mediciones, se calculan conversiones físicas y se eliminan registros respetando las reglas de negocio.

## 0. Configuración Inicial y Limpieza (`CleanupProcedure`)
Antes de comenzar, el script garantiza un entorno estéril para evitar errores de duplicidad o referencias rotas de ejecuciones anteriores.

1.  **Eliminación en Cascada Inversa:** Se borran los datos en orden inverso a sus dependencias (Hijos --> Padres) para evitar errores de *Foreign Key*.
    * `Planeta_Estrella` --> `Satelites` --> `Planetas`/`Estrellas` --> `RegistroObservacion` --> `CuerpoCeleste` --> `Descubridores` --> `Constelaciones`.
2.  **Reinicio de Auto-Increment:** (Opcional/Comentado en script) Se prepara el reinicio de los contadores de ID para que las pruebas siempre comiencen con ID 1.

---

## 1. Altas Iniciales (Preparación de Datos)
Se puebla la base de datos con un conjunto de datos interconectado que incluye un sistema binario y un planeta con satélite.

### Entidades Creadas
| ID | Tipo | Nombre | Descripción |
| :--- | :--- | :--- | :--- |
| **1** | `Constelación` | Sagitario | - |
| **1** | `Estrella` | **Sirio A** | Estrella principal. Enana Blanca. |
| **2** | `Estrella` | **Sirio B** | Estrella compañera (Sistema Binario). |
| **3** | `Planeta` | **Kepler-16b** | Planeta circumbinario (orbita a ambas estrellas). |
| **4** | `Satélite` | **Moon Alpha** | Luna que orbita a Kepler-16b. |

### Relaciones Establecidas
* **Sistema Binario:** El Planeta 3 se vincula tanto a la Estrella 1 como a la Estrella 2 mediante `SP_Vincular_Planeta_Estrella`.

---

## 2. Pruebas de Modificación (UPDATEs Transaccionales)
Verifica que los Stored Procedures de modificación actualicen correctamente tanto la tabla padre (`CuerpoCeleste`) como las tablas hijas y de relación.

* **Modificación 2.1 (Estrella):** Se actualiza "Sirio A" a "Sirio A (Revisado)" y se ajusta su masa. Prueba la integridad de la transacción en dos tablas.
* **Modificación 2.2 (Descubridor):** Se asigna un número de legajo a un descubridor que no lo tenía.
* **Modificación 2.3 (Vínculo):** Se cambia el estado del planeta Kepler-16b a **"Potencialmente Habitable"** (`TRUE`) y se ajusta su distancia orbital.

---

## 3. Pruebas de Funciones y Validaciones

### 3.1 Conversión de Unidades (UDFs)
Se ejecutan las funciones escalares para validar los cálculos matemáticos.
* `FN_Celsius_a_Kelvin`: Convierte la temperatura de Sirio A.
* `FN_LY_a_KM`: Calcula la distancia real en km basada en los años luz.

### 3.2 Control de Errores (Constraints)
* Se valida (implícitamente al no fallar o explícitamente si se descomenta una línea de fallo) que las restricciones `CHECK` (ej. colores de estrellas permitidos) estén activas.

---

## 4. Pruebas de Baja (Integridad y Cascada)
Esta es la sección crítica para validar la lógica de negocio de "No eliminar padres con hijos vivos".

### Flujo de Eliminación Controlada
1.  **Intento Fallido (Esperado):** Se intenta borrar el **Planeta 3**.
    * *Resultado:* El sistema debe lanzar un error (`SIGNAL SQLSTATE '45000'`) porque el planeta tiene un satélite (ID 4) activo.
2.  **Desbloqueo:** Se ejecuta `SP_Baja_Satelite(4)`. Esto elimina la dependencia.
3.  **Intento Exitoso:** Se vuelve a ejecutar la baja del Planeta 3. Ahora el procedimiento permite la eliminación y limpia las referencias en `Planeta_Estrella`.
4.  **Limpieza Final:** Se elimina una de las estrellas (Sirio B).

### Verificación Final
El script concluye con `SELECT COUNT(*)` para asegurar que no quedaron registros "huérfanos" en las tablas intermedias.

---