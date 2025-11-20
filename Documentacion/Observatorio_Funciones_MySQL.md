# Documentación de Funciones Escalares (User Defined Functions)

Este módulo define funciones **deterministas** para realizar cálculos científicos estandarizados dentro de la base de datos. Estas funciones son esenciales para convertir unidades de medida astronómicas y termodinámicas.

## 1\. Conversión de Distancia: Años Luz a Kilómetros

### `FN_LY_a_KM`

Esta función convierte distancias astronómicas expresadas en Años Luz (Ly) a una medida física tangible en Kilómetros (Km).

  * **Tipo:** Determinista (Siempre devuelve el mismo resultado para la misma entrada).
  * **Retorno:** `DECIMAL(30, 6)` - Se utiliza una precisión extremadamente alta para manejar las distancias astronómicas sin desbordamiento.

| Parámetro | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `distancia_ly` | `DECIMAL(18, 6)` | La distancia en años luz a convertir. |

#### Lógica de Conversión

La función utiliza la definición oficial de la Unión Astronómica Internacional (IAU) para un año luz.

`Distancia_{km} = Distancia_{ly}/9,460,730,472,580.8$$`

> **Nota Técnica:** La variable interna `factor_conversion` está definida con precisión suficiente para almacenar la constante exacta de casi 9.5 billones de kilómetros.

-----

## 2\. Conversión de Temperatura: Celsius a Kelvin

### `FN_Celsius_a_Kelvin`

Convierte la temperatura de la escala Celsius (habitual en inputs humanos) a la escala Kelvin (unidad SI utilizada en cálculos científicos estelares).

  * **Tipo:** Determinista.
  * **Retorno:** `DECIMAL(10, 2)`.

| Parámetro | Tipo de Dato | Descripción |
| :--- | :--- | :--- |
| `temperatura_celsius` | `DECIMAL(10, 2)` | La temperatura en grados Celsius (°C). |

#### Lógica de Conversión

Aplica el desplazamiento del cero absoluto.

`{Kelvin} = T_{Celsius} + 273.15`

> **Nota de Implementación:** Se declara la `constante_kelvin` como `DECIMAL(10, 2)` para asegurar que el valor decimal `.15` se maneje correctamente, corrigiendo posibles errores de precisión en definiciones `DECIMAL` más cortas.

-----

### Notas de Ejecución (SQL)

  * **Delimitadores (`//`):** El script utiliza `DELIMITER //` para definir el bloque de código de la función sin que el motor interprete los puntos y coma internos como el fin de la instrucción. Al final, se restablece con `DELIMITER ;`.
  * **Uso Típico:** Estas funciones están diseñadas para usarse dentro de `SELECT` o en `Computed Columns` (Columnas calculadas) si la versión de MySQL lo permite.

**Ejemplo de uso:**

```sql
SELECT 
    nombre, 
    FN_LY_a_KM(distancia_desde_tierra_ly) as distancia_en_km,
    FN_Celsius_a_Kelvin(temperatura_celsius) as temp_kelvin
    FROM RegistroObservacion 
    JOIN CuerpoCeleste ON ...;
```
-----