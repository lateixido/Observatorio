-- ####################################################################
-- # 0. CONFIGURACIÓN INICIAL Y PREPARACIÓN
-- ####################################################################

-- Asegurarse de que el delimitador esté listo para sentencias
DELIMITER //

-- Eliminar datos de prueba anteriores si existen (para permitir la repetición del script)
-- Se asume que se está usando la base de datos "ObservatorioDB_Grupo_1"
DROP PROCEDURE IF EXISTS CleanupProcedure //
CREATE PROCEDURE CleanupProcedure()
BEGIN
    DELETE FROM Planeta_Estrella;
    DELETE FROM Satelites;
    DELETE FROM Estrellas;
    DELETE FROM Planetas;
    DELETE FROM RegistroObservacion;
    DELETE FROM CuerpoCeleste;
    DELETE FROM Descubridores;
    DELETE FROM Constelaciones;
   

END //
DELIMITER ;
 CALL CleanupProcedure(); 
 DROP PROCEDURE CleanupProcedure; 

DELIMITER //

-- ####################################################################
-- # 1. ALTAS INICIALES (PREPARACIÓN DE DATOS)
-- ####################################################################

SELECT '1. ALTAS INICIALES...' AS Mensaje //

-- ALTA CONSTELACIONES (IDs 1, 2)
CALL SP_Alta_Constelacion('Sagitario') // -- ID 1
CALL SP_Alta_Constelacion('Andrómeda') // -- ID 2

-- ALTA DESCUBRIDORES (IDs 1, 2)
CALL SP_Alta_Descubridor('Carl', 'Sagan', '1934-11-09', 'L0001') // -- ID 1
CALL SP_Alta_Descubridor('Vera', 'Rubin', '1928-07-23', NULL) //    -- ID 2

-- ALTA ESTRELLA PRIMARIA (ID 1) - Sirio A
CALL SP_Alta_Estrella(
    'Sirio A', 2.02, 237, 2400000.00, -- CuerpoCeleste
    9940.00, 'Blanca', 'Enana', 1,    -- Estrellas
    1, '2025-01-15', 8.6              -- Observación
) //

-- ALTA ESTRELLA SECUNDARIA (ID 2) - Sirio B
CALL SP_Alta_Estrella(
    'Sirio B', 0.98, 237, 12000.00,
    25000.00, 'Blanca', 'Enana', 1,
    2, '2025-02-10', 8.6
) //

-- ALTA PLANETA (ID 3) - Planeta Binario
CALL SP_Alta_Planeta(
    'Kepler-16b', 0.33, 1000, 100000.00, -- CuerpoCeleste
    -95.00,                             -- Planetas
    1, '2025-03-01', 200.0              -- Observación
) //

-- ALTA SATÉLITE (ID 4) - Luna de Kepler-16b
CALL SP_Alta_Satelite(
    'Moon Alpha', 0.001, 1000, 1500.00,  -- CuerpoCeleste
    TRUE, 3,                            -- Satélite (TRUE = 1)
    2, '2025-03-05', 200.0001           -- Observación (ID del planeta es 3)
) //

-- VINCULACIÓN PLANETA-ESTRELLA (Sistema Binario)
-- Planeta 3 orbita Estrella 1 y 2
CALL SP_Vincular_Planeta_Estrella(
    3, 1, 0.7048, FALSE, FALSE -- Planeta 3 orbita Estrella 1
) //
CALL SP_Vincular_Planeta_Estrella(
    3, 2, 0.2243, FALSE, FALSE -- Planeta 3 orbita Estrella 2
) //


-- ####################################################################
-- # 2. PRUEBAS DE MODIFICACIÓN
-- ####################################################################

SELECT '2. PRUEBAS DE MODIFICACIÓN...' AS Mensaje //

-- MODIFICACIÓN 2.1: Actualizar nombre y masa de un CuerpoCeleste (Sirio A, ID 1)
CALL SP_Modificar_Estrella(
    1,                                  -- p_id_estrella
    'Sirio A (Revisado)', 2.05, 237, 2500000.00, -- CuerpoCeleste
    9940.00, 'Blanca', 'Enana', 1       -- Estrellas
) //

-- MODIFICACIÓN 2.2: Cambiar la designación de un Descubridor (Vera Rubin, ID 2)
CALL SP_Modificar_Descubridor(
    2, 'Vera', 'Rubin', '1928-07-23', 'L0002' -- p_legajo ahora con valor
) //

-- MODIFICACIÓN 2.3: Actualizar habitabilidad de un vínculo (Planeta 3 / Estrella 1)
CALL SP_Modificar_Vínculo_Planeta_Estrella(
    3, 1, 0.7100, TRUE, TRUE -- Se cambia a Potencialmente Habitable
) //

-- MODIFICACIÓN 2.4: Actualizar datos de observación (Satélite, ID 4)
CALL SP_Modificar_RegistroObservacion(
    4, 1, '2025-03-06', 200.0001 -- Registro ID 4 asociado al Satélite 4
) //

-- VERIFICACIÓN DE MODIFICACIONES
SELECT '--- RESULTADOS MODIFICACIONES ---' AS Mensaje //
SELECT id_cuerpo_celeste, nombre, masa, diametro_km FROM CuerpoCeleste WHERE id_cuerpo_celeste IN (1, 3) //
SELECT id_descubridor, nombre, legajo FROM Descubridores WHERE id_descubridor = 2 //
SELECT id_planeta, id_estrella, zona_ricitos_de_oro, potencialmente_habitable FROM Planeta_Estrella WHERE id_planeta = 3 //


-- ####################################################################
-- # 3. PRUEBAS DE FUNCIONES Y VALIDACIÓN (Errores)
-- ####################################################################

SELECT '3. PRUEBAS DE FUNCIONES Y VALIDACIÓN...' AS Mensaje //

-- PRUEBA 3.1: Conversión de Unidades
SELECT 
    FN_Celsius_a_Kelvin(9940.00) AS Temp_Sirio_K,
    FN_LY_a_KM(8.6) AS Distancia_Sirio_KM //


-- ####################################################################
-- # 4. PRUEBAS DE BAJA (CASCADE LÓGICO)
-- ####################################################################

SELECT '4. PRUEBAS DE BAJA...' AS Mensaje //

-- PRUEBA 4.1: BAJA CON RESTRICCIÓN (Intentar eliminar un planeta con satélites)
-- SELECT 'Intentando eliminar Planeta 3 con Satélite...' AS Mensaje //
-- CALL SP_Baja_Planeta(3) // -- ESTE DEBE LANZAR UN SIGNAL '45000'

-- Solución: Eliminar el satélite primero (ID 4)
SELECT '4.2. Eliminando satélite para desbloquear el planeta...' AS Mensaje //
CALL SP_Baja_Satelite(4) //

-- PRUEBA 4.3: BAJA FINAL DEL PLANETA (Ahora debe funcionar)
SELECT '4.4. Eliminando Planeta 3 (Ahora OK)...' AS Mensaje //
CALL SP_Baja_Planeta(3) //

-- PRUEBA 4.5: BAJA FINAL DE ESTRELLA (Eliminar Sirio B, ID 2)
SELECT '4.5. Eliminando Estrella 2 (Sirio B)...' AS Mensaje //
CALL SP_Baja_Estrella(2) //

-- VERIFICACIÓN FINAL DE BAJAS
SELECT '--- VERIFICACIÓN DE BAJAS ---' AS Mensaje //
SELECT 'CuerpoCeleste restantes:', COUNT(*) FROM CuerpoCeleste //
SELECT 'Planeta_Estrella restantes:', COUNT(*) FROM Planeta_Estrella //

SELECT '--- FIN DE PRUEBAS ---' AS Mensaje //

-- Restablecer el delimitador por defecto
DELIMITER ;