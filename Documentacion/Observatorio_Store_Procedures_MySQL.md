# Documentación de Stored Procedures: Observatorio

## I. Procedimientos de Alta (Creación de Registros)

Los procedimientos de Alta de cuerpos celestes (**Estrella**, **Planeta**, **Satélite**) son **transaccionales** y garantizan que un objeto se registre completamente en las tres tablas necesarias (`CuerpoCeleste`, la tabla específica y `RegistroObservacion`).

### Tabla de Procedimientos de Alta

| Store Procedure | Propósito | Lógica Clave |
| :--- | :--- | :--- |
| **SP\_Alta\_Constelacion** | Registra una nueva constelación. | Es un INSERT simple en la tabla `Constelaciones`. |
| **SP\_Alta\_Descubridor** | Registra una nueva persona o entidad que realiza observaciones. | Es un INSERT simple en la tabla `Descubridores`. |
| **SP\_Alta\_Estrella** | Crea un nuevo registro de **Estrella**. | **Transaccional** (3 INSERTs):<br>1. Inserta datos comunes (nombre, masa, diámetro) en `CuerpoCeleste`.<br>2. Obtiene el nuevo ID (`LAST_INSERT_ID()`).<br>3. Inserta datos propios (temperatura, color, tipo) en `Estrellas`.<br>4. Inserta datos de la observación inicial en `RegistroObservacion`. |
| **SP\_Alta\_Planeta** | Crea un nuevo registro de **Planeta**. | **Transaccional** (3 INSERTs). Sigue la misma lógica que `SP_Alta_Estrella`, pero inserta datos específicos (solo temperatura) en la tabla `Planetas`. |
| **SP\_Alta\_Satélite** | Crea un nuevo registro de **Satélite** natural. | **Transaccional** (3 INSERTs). Similar a los anteriores, con la particularidad de que registra el `p_acoplamiento_marea` y el `p_id_Planeta_orbita` en la tabla `Satélites`. |
| **SP\_Vincular\_Planeta\_Estrella** | Registra la relación de órbita (Sistema Planetario). | Es un INSERT simple en la tabla de relación `Planeta_Estrella`. Este es crucial para distinguir sistemas **simples** (1 Estrella) de **binarios** (2 Estrellas) y definir si está en la **zona "Ricitos de Oro"**. |

-----

## II. Procedimientos de Baja (Eliminación de Registros)

Los procedimientos de Baja de cuerpos celestes deben seguir una secuencia estricta para eliminar las referencias antes de eliminar el objeto `CuerpoCeleste`.

### Tabla de Procedimientos de Baja

| Store Procedure | Propósito | Lógica Clave |
| :--- | :--- | :--- |
| **SP\_Baja\_Constelacion** | Elimina una constelación. | **Validación Condicional:** Utiliza `IF EXISTS` para verificar si aún existen **Estrellas** asociadas. Si existen, lanza una señal de error (`SIGNAL SQLSTATE '45000'`) y **no permite la eliminación**. |
| **SP\_Baja\_Descubridor** | Elimina un descubridor. | Es un DELETE simple. |
| **SP\_Baja\_Estrella** | Elimina una **Estrella**. | **Transaccional en Cascada:** Elimina las referencias en `Planeta_Estrella` y `RegistroObservacion` **antes** de eliminar el registro de `Estrellas` y, finalmente, de `CuerpoCeleste`. |
| **SP\_Baja\_Planeta** | Elimina un **Planeta**. | **Transaccional con Control de Integridad:** Primero verifica si el **Planeta** tiene **Satélites** orbitándolo (`IF EXISTS`). Si los tiene, lanza un error (`SIGNAL SQLSTATE`) y detiene la transacción. Si no, elimina las referencias y el **Planeta**. |
| **SP\_Baja\_Satélite** | Elimina un **Satélite**. | **Transaccional en Cascada:** Elimina el registro de `RegistroObservacion`, luego de `Satélites` y, por último, de `CuerpoCeleste`. |
| **SP\_Desvincular\_Planeta\_Estrella** | Elimina la relación de órbita específica. | Es un DELETE en la tabla `Planeta_Estrella`, útil para, por ejemplo, cambiar un sistema binario a un sistema simple, eliminando la órbita de una de las **Estrellas**. |

-----

## III. Procedimientos de Modificación (Actualización de Registros)

Los procedimientos de modificación de cuerpos celestes son **transaccionales** y requieren actualizar registros en múltiples tablas, ya que los atributos están separados.

### Tabla de Procedimientos de Modificación

| Store Procedure | Propósito | Lógica Clave |
| :--- | :--- | :--- |
| **SP\_Modificar\_Constelacion** | Actualiza el nombre de una constelación. | UPDATE simple. |
| **SP\_Modificar\_Descubridor** | Actualiza los datos de un descubridor. | UPDATE simple. |
| **SP\_Modificar\_Estrella** | Actualiza los datos de la **Estrella**. | **Transaccional:** Requiere **dos UPDATEs**: uno para el objeto (`CuerpoCeleste` para nombre, masa, diámetro) y otro para la subclase (`Estrellas` para temperatura, color, tipo). |
| **SP\_Modificar\_Planeta** | Actualiza los datos del **Planeta**. | **Transaccional:** Requiere dos UPDATEs, uno para `CuerpoCeleste` y otro para `Planetas`. |
| **SP\_Modificar\_Satélite** | Actualiza los datos del **Satélite**. | **Transaccional:** Requiere dos UPDATEs, uno para `CuerpoCeleste` y otro para `Satélites` (acoplamiento de marea, **Planeta** que órbita). |
| **SP\_Modificar\_RegistroObservacion** | Actualiza la información del registro de observación (descubridor, fecha, distancia). | UPDATE simple en la tabla `RegistroObservacion`. |
| **SP\_Modificar\_Vínculo\_Planeta\_Estrella** | Actualiza los datos de órbita y habitabilidad. | UPDATE en la tabla `Planeta_Estrella`, modificando la distancia a la **Estrella** y las banderas de habitabilidad. |

-----