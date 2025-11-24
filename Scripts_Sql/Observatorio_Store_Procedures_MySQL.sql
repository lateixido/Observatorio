-- Cambiar el delimitador para permitir la creación de procedimientos con múltiples sentencias
DELIMITER //

-- ####################################################################
-- # ALTA
-- ####################################################################

-- ALTA: Constelación (Simple)
CREATE PROCEDURE SP_Alta_Constelacion (
    IN p_nombre VARCHAR(100)
)
BEGIN
    INSERT INTO Constelaciones (nombre)
    VALUES (p_nombre);
END//

-- ALTA: Descubridor (Simple)
CREATE PROCEDURE SP_Alta_Descubridor (
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_fecha_nacimiento DATE,
    IN p_legajo VARCHAR(50)
)
BEGIN
    INSERT INTO Descubridores (nombre, apellido, fecha_nacimiento, legajo)
    VALUES (p_nombre, p_apellido, p_fecha_nacimiento, p_legajo);
END//

-- ALTA: Estrella (Transaccional)
CREATE PROCEDURE SP_Alta_Estrella (
    -- CuerpoCeleste
    IN p_nombre VARCHAR(100),
    IN p_masa DECIMAL(18, 5),
    IN p_edad_millones_anios INT,
	IN p_diametro_km DECIMAL(20, 2), 
    -- Estrellas
    IN p_temperatura_celsius DECIMAL(10, 2),
    IN p_color VARCHAR(20),
    IN p_tipo VARCHAR(20),
    IN p_id_constelacion INT,
    -- RegistroObservacion
    IN p_id_descubridor INT,
    IN p_fecha_encuentro DATE,
    IN p_distancia_desde_tierra_ly DECIMAL(18, 6)
)
BEGIN
    DECLARE v_new_id INT;
    -- Manejo de errores/transacciones
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    -- 1. Insertar en CuerpoCeleste
    INSERT INTO CuerpoCeleste (nombre, masa, edad_millones_anios, diametro_km)
    VALUES (p_nombre, p_masa, p_edad_millones_anios, p_diametro_km);

    SET v_new_id = LAST_INSERT_ID(); -- Nuevo número de identificación

    -- 2. Insertar en Estrellas
    INSERT INTO Estrellas (id_cuerpo_celeste, temperatura_celsius, color, tipo, id_constelacion)
    VALUES (v_new_id, p_temperatura_celsius, p_color, p_tipo, p_id_constelacion);

    -- 3. Insertar en RegistroObservacion
    INSERT INTO RegistroObservacion (id_cuerpo_celeste, id_descubridor, fecha_encuentro, distancia_desde_tierra_ly)
    VALUES (v_new_id, p_id_descubridor, p_fecha_encuentro, p_distancia_desde_tierra_ly);

    COMMIT; 
    SELECT v_new_id AS IdEstrellaCreada; -- Muestra nuevo número de identificación asignado
END//

-- ALTA: Planeta (Transaccional)
CREATE PROCEDURE SP_Alta_Planeta (
    -- CuerpoCeleste
    IN p_nombre VARCHAR(100),
    IN p_masa DECIMAL(18, 5),
    IN p_edad_millones_anios INT,
	IN p_diametro_km DECIMAL(20, 2),
    -- Planetas
    IN p_temperatura_celsius DECIMAL(10, 2),
    -- RegistroObservacion
    IN p_id_descubridor INT,
    IN p_fecha_encuentro DATE,
    IN p_distancia_desde_tierra_ly DECIMAL(18, 6)
)
BEGIN
    DECLARE v_new_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    -- 1. Insertar en CuerpoCeleste
    INSERT INTO CuerpoCeleste (nombre, masa, edad_millones_anios, diametro_km)
    VALUES (p_nombre, p_masa, p_edad_millones_anios, p_diametro_km);

    SET v_new_id = LAST_INSERT_ID();

    -- 2. Insertar en Planetas
    INSERT INTO Planetas (id_cuerpo_celeste, temperatura_celsius)
    VALUES (v_new_id, p_temperatura_celsius);

    -- 3. Insertar en RegistroObservacion
    INSERT INTO RegistroObservacion (id_cuerpo_celeste, id_descubridor, fecha_encuentro, distancia_desde_tierra_ly)
    VALUES (v_new_id, p_id_descubridor, p_fecha_encuentro, p_distancia_desde_tierra_ly);

    COMMIT;
    SELECT v_new_id AS IdPlanetaCreado;
END//

-- ALTA: Satelite (Transaccional)
CREATE PROCEDURE SP_Alta_Satelite (
    -- CuerpoCeleste
    IN p_nombre VARCHAR(100),
    IN p_masa DECIMAL(18, 5),
    IN p_edad_millones_anios INT,
	IN p_diametro_km DECIMAL(20, 2),
    -- Satelites
    IN p_acoplamiento_marea BOOLEAN,
    IN p_id_planeta_orbita INT,
    -- RegistroObservacion
    IN p_id_descubridor INT,
    IN p_fecha_encuentro DATE,
    IN p_distancia_desde_tierra_ly DECIMAL(18, 6)
)
BEGIN
    DECLARE v_new_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    -- 1. Insertar en CuerpoCeleste
    INSERT INTO CuerpoCeleste (nombre, masa, edad_millones_anios, diametro_km)
    VALUES (p_nombre, p_masa, p_edad_millones_anios, p_diametro_km);

    SET v_new_id = LAST_INSERT_ID();

    -- 2. Insertar en Satelites
    INSERT INTO Satelites (id_cuerpo_celeste, acoplamiento_marea, id_planeta_orbita)
    VALUES (v_new_id, p_acoplamiento_marea, p_id_planeta_orbita);

    -- 3. Insertar en RegistroObservacion
    INSERT INTO RegistroObservacion (id_cuerpo_celeste, id_descubridor, fecha_encuentro, distancia_desde_tierra_ly)
    VALUES (v_new_id, p_id_descubridor, p_fecha_encuentro, p_distancia_desde_tierra_ly);

    COMMIT;
    SELECT v_new_id AS IdSateliteCreado;
END//

-- ALTA: VINCULACIÓN PLANETA CON ESTRELLA
CREATE PROCEDURE SP_Vincular_Planeta_Estrella (
    IN p_id_planeta INT,
    IN p_id_estrella INT,
    IN p_distancia_ly DECIMAL(18, 6),
    IN p_zona_ricitos_de_oro BOOLEAN,
    IN p_potencialmente_habitable BOOLEAN
)
BEGIN
    INSERT INTO Planeta_Estrella (id_planeta, id_estrella, distancia_ly, zona_ricitos_de_oro, potencialmente_habitable)
    VALUES (p_id_planeta, p_id_estrella, p_distancia_ly, p_zona_ricitos_de_oro, p_potencialmente_habitable);
END//

-- ####################################################################
-- # BAJA
-- ####################################################################

-- BAJA: Constelación (Condicional)
CREATE PROCEDURE SP_Baja_Constelacion (
    IN p_id_constelacion INT
)
BEGIN
    -- Reemplaza IF EXISTS + RAISERROR + RETURN
    IF EXISTS (SELECT 1 FROM Estrellas WHERE id_constelacion = p_id_constelacion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la constelación. Hay estrellas asociadas.';
    END IF;

    DELETE FROM Constelaciones WHERE id_constelacion = p_id_constelacion;
END//

-- BAJA: Descubridor (Simple)
CREATE PROCEDURE SP_Baja_Descubridor (
    IN p_id_descubridor INT
)
BEGIN
    DELETE FROM Descubridores WHERE id_descubridor = p_id_descubridor;
END//

-- BAJA: Estrella (Transaccional en cascada)
CREATE PROCEDURE SP_Baja_Estrella (
    IN p_id_estrella INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    -- 1. Eliminar referencias en Planeta_Estrella
    DELETE FROM Planeta_Estrella WHERE id_estrella = p_id_estrella;

    -- 2. Eliminar de RegistroObservacion
    DELETE FROM RegistroObservacion WHERE id_cuerpo_celeste = p_id_estrella;

    -- 3. Eliminar de Estrellas
    DELETE FROM Estrellas WHERE id_cuerpo_celeste = p_id_estrella;

    -- 4. Eliminar de CuerpoCeleste
    DELETE FROM CuerpoCeleste WHERE id_cuerpo_celeste = p_id_estrella;

    COMMIT;
END//

-- BAJA: Planeta (Transaccional en cascada con validación)
CREATE PROCEDURE SP_Baja_Planeta (
    IN p_id_planeta INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    -- 1. Verificar si tiene Satélites asociados
    IF EXISTS (SELECT 1 FROM Satelites WHERE id_planeta_orbita = p_id_planeta) THEN
        -- Si hay error, el EXIT HANDLER hará ROLLBACK. Aquí solo lanzamos la señal.
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El planeta tiene satélites asociados. Elimine los satélites primero.';
    END IF;

    -- 2. Eliminar referencias en Planeta_Estrella
    DELETE FROM Planeta_Estrella WHERE id_planeta = p_id_planeta;

    -- 3. Eliminar de RegistroObservacion
    DELETE FROM RegistroObservacion WHERE id_cuerpo_celeste = p_id_planeta;

    -- 4. Eliminar de Planetas
    DELETE FROM Planetas WHERE id_cuerpo_celeste = p_id_planeta;

    -- 5. Eliminar de CuerpoCeleste
    DELETE FROM CuerpoCeleste WHERE id_cuerpo_celeste = p_id_planeta;

    COMMIT;
END//

-- BAJA: Satelite (Transaccional en cascada)
CREATE PROCEDURE SP_Baja_Satelite (
    IN p_id_satelite INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    -- 1. Eliminar de RegistroObservacion
    DELETE FROM RegistroObservacion WHERE id_cuerpo_celeste = p_id_satelite;

    -- 2. Eliminar de Satelites
    DELETE FROM Satelites WHERE id_cuerpo_celeste = p_id_satelite;

    -- 3. Eliminar de CuerpoCeleste
    DELETE FROM CuerpoCeleste WHERE id_cuerpo_celeste = p_id_satelite;

    COMMIT;
END//

-- BAJA (DESVINCULAR)
CREATE PROCEDURE SP_Desvincular_Planeta_Estrella (
    IN p_id_planeta INT,
    IN p_id_estrella INT
)
BEGIN
    DELETE FROM Planeta_Estrella
    WHERE id_planeta = p_id_planeta AND id_estrella = p_id_estrella;
END//

-- ####################################################################
-- # MODIFICACIÓN
-- ####################################################################

-- MODIFICACIÓN: Constelación (Simple)
CREATE PROCEDURE SP_Modificar_Constelacion (
    IN p_id_constelacion INT,
    IN p_nombre VARCHAR(100)
)
BEGIN
    UPDATE Constelaciones
    SET nombre = p_nombre
    WHERE id_constelacion = p_id_constelacion;
END//

-- MODIFICACIÓN: Descubridor (Simple)
CREATE PROCEDURE SP_Modificar_Descubridor (
    IN p_id_descubridor INT,
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_fecha_nacimiento DATE,
    IN p_legajo VARCHAR(50)
)
BEGIN
    UPDATE Descubridores
    SET
        nombre = p_nombre,
        apellido = p_apellido,
        fecha_nacimiento = p_fecha_nacimiento,
        legajo = p_legajo
    WHERE id_descubridor = p_id_descubridor;
END//

-- MODIFICACIÓN: Estrella (Transaccional)
CREATE PROCEDURE SP_Modificar_Estrella (
    IN p_id_estrella INT,
    -- CuerpoCeleste
    IN p_nombre VARCHAR(100),
    IN p_masa DECIMAL(18, 5),
    IN p_edad_millones_anios INT,
    IN p_diametro_km DECIMAL(20, 2),
    -- Estrellas
    IN p_temperatura_celsius DECIMAL(10, 2),
    IN p_color VARCHAR(20),
    IN p_tipo VARCHAR(20),
    IN p_id_constelacion INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    -- 1. Actualizar CuerpoCeleste
    UPDATE CuerpoCeleste
    SET nombre = p_nombre,
        masa = p_masa,
        edad_millones_anios = p_edad_millones_anios,
        diametro_km = p_diametro_km
    WHERE id_cuerpo_celeste = p_id_estrella;

    -- 2. Actualizar Estrellas
    UPDATE Estrellas
    SET temperatura_celsius = p_temperatura_celsius,
        color = p_color,
        tipo = p_tipo,
        id_constelacion = p_id_constelacion
    WHERE id_cuerpo_celeste = p_id_estrella;

    COMMIT;
END//

-- MODIFICACIÓN: Planeta (Transaccional)
CREATE PROCEDURE SP_Modificar_Planeta (
    IN p_id_planeta INT,
    -- CuerpoCeleste
    IN p_nombre VARCHAR(100),
    IN p_masa DECIMAL(18, 5),
    IN p_edad_millones_anios INT,
    IN p_diametro_km DECIMAL(20, 2), -- Nuevo parámetro para CuerpoCeleste
    -- Planetas
    IN p_temperatura_celsius DECIMAL(10, 2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    -- 1. Actualizar CuerpoCeleste (CORREGIDO: Se incluye diametro_km)
    UPDATE CuerpoCeleste
    SET nombre = p_nombre,
        masa = p_masa,
        edad_millones_anios = p_edad_millones_anios,
        diametro_km = p_diametro_km
    WHERE id_cuerpo_celeste = p_id_planeta;

    -- 2. Actualizar Planetas
    UPDATE Planetas
    SET temperatura_celsius = p_temperatura_celsius
    WHERE id_cuerpo_celeste = p_id_planeta;

    COMMIT;
END//

-- MODIFICACIÓN: Registro de Observación (Simple)
CREATE PROCEDURE SP_Modificar_RegistroObservacion (
    IN p_id_registro INT,
    IN p_id_descubridor INT,
    IN p_fecha_encuentro DATE,
    IN p_distancia_desde_tierra_ly DECIMAL(18, 6)
)
BEGIN
    UPDATE RegistroObservacion
    SET
        id_descubridor = p_id_descubridor,
        fecha_encuentro = p_fecha_encuentro,
        distancia_desde_tierra_ly = p_distancia_desde_tierra_ly
    WHERE id_registro = p_id_registro;
END//

-- MODIFICACIÓN: Satelite (Transaccional)
CREATE PROCEDURE SP_Modificar_Satelite (
    IN p_id_satelite INT,
    -- CuerpoCeleste
    IN p_nombre VARCHAR(100),
    IN p_masa DECIMAL(18, 5),
    IN p_edad_millones_anios INT,
    IN p_diametro_km DECIMAL(20, 2), 
    -- Satelites
    IN p_acoplamiento_marea BOOLEAN, 
    IN p_id_planeta_orbita INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;

    -- 1. Actualizar CuerpoCeleste 
    UPDATE CuerpoCeleste
    SET nombre = p_nombre,
        masa = p_masa,
        edad_millones_anios = p_edad_millones_anios,
        diametro_km = p_diametro_km
    WHERE id_cuerpo_celeste = p_id_satelite;

    -- 2. Actualizar Satelites
    UPDATE Satelites
    SET acoplamiento_marea = p_acoplamiento_marea,
        id_planeta_orbita = p_id_planeta_orbita
    WHERE id_cuerpo_celeste = p_id_satelite;

    COMMIT;
END//

-- MODIFICACIÓN: Vínculo Planeta-Estrella (Simple)
CREATE PROCEDURE SP_Modificar_Vínculo_Planeta_Estrella (
    IN p_id_planeta INT,
    IN p_id_estrella INT,
    IN p_distancia_ly DECIMAL(18, 6),
    IN p_zona_ricitos_de_oro BOOLEAN,
    IN p_potencialmente_habitable BOOLEAN
)
BEGIN
    UPDATE Planeta_Estrella
    SET
        distancia_ly = p_distancia_ly,
        zona_ricitos_de_oro = p_zona_ricitos_de_oro,
        potencialmente_habitable = p_potencialmente_habitable
    WHERE id_planeta = p_id_planeta AND id_estrella = p_id_estrella;
END//

-- Restaurar el delimitador por defecto
DELIMITER ;