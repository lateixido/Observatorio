-- ####################################################################
-- # 1. CREACIÓN Y SELECCIÓN DE BASE DE DATOS
-- ####################################################################

CREATE DATABASE IF NOT EXISTS ObservatorioDB_Grupo_1;
USE ObservatorioDB_Grupo_1;

-- ####################################################################
-- # 2. TABLAS DE SOPORTE Y ENTIDADES PRINCIPALES
-- ####################################################################

-- Tabla de Descubridores
CREATE TABLE Descubridores (
    id_descubridor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    legajo VARCHAR(50) NULL 
);

-- Tabla de Constelaciones
CREATE TABLE Constelaciones (
    id_constelacion INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-- Entidad Clase: CuerpoCeleste
CREATE TABLE CuerpoCeleste (
    id_cuerpo_celeste INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    masa DECIMAL(18, 5) NOT NULL, 
    diametro_km DECIMAL(20, 2) NOT NULL,
    edad_millones_anios INT NOT NULL
);

-- Entidad de Registro de Observación
CREATE TABLE RegistroObservacion (
    id_registro INT PRIMARY KEY AUTO_INCREMENT,
    id_cuerpo_celeste INT NOT NULL,
    id_descubridor INT NOT NULL,
    fecha_encuentro DATE NOT NULL,
    distancia_desde_tierra_ly DECIMAL(18, 6) NOT NULL,

    FOREIGN KEY (id_cuerpo_celeste) REFERENCES CuerpoCeleste(id_cuerpo_celeste),
    FOREIGN KEY (id_descubridor) REFERENCES Descubridores(id_descubridor),
    CONSTRAINT UQ_Registro_Cuerpo_Fecha UNIQUE (id_cuerpo_celeste, fecha_encuentro)
);

-- ####################################################################
-- # 3. SUBCLASES Y RELACIONES
-- ####################################################################

-- Estrellas
CREATE TABLE Estrellas (
    id_cuerpo_celeste INT PRIMARY KEY,
    temperatura_celsius DECIMAL(10, 2) NOT NULL,
    color VARCHAR(20) NOT NULL CHECK (color IN ('Roja','Naranja','Amarilla','Blanca','Azul')),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Enana','Gigante')),
    id_constelacion INT NOT NULL, 

    FOREIGN KEY (id_cuerpo_celeste) REFERENCES CuerpoCeleste(id_cuerpo_celeste),
    FOREIGN KEY (id_constelacion) REFERENCES Constelaciones(id_constelacion)
);

-- Planetas
CREATE TABLE Planetas (
    id_cuerpo_celeste INT PRIMARY KEY,
    temperatura_celsius DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_cuerpo_celeste) REFERENCES CuerpoCeleste(id_cuerpo_celeste)
);

-- Satélites
CREATE TABLE Satelites (
    id_cuerpo_celeste INT PRIMARY KEY,
    acoplamiento_marea BOOLEAN NOT NULL, -- Corregido: BIT -> BOOLEAN
    id_planeta_orbita INT NOT NULL, 

    FOREIGN KEY (id_cuerpo_celeste) REFERENCES CuerpoCeleste(id_cuerpo_celeste),
    FOREIGN KEY (id_planeta_orbita) REFERENCES Planetas(id_cuerpo_celeste)
);

-- Relación Planeta_Estrella
CREATE TABLE Planeta_Estrella (
    id_planeta INT NOT NULL,
    id_estrella INT NOT NULL,
    distancia_ly DECIMAL(18, 6) NOT NULL,
    zona_ricitos_de_oro BOOLEAN NULL, -- Corregido: BIT -> BOOLEAN
    potencialmente_habitable BOOLEAN NULL, -- Corregido: BIT -> BOOLEAN 

    PRIMARY KEY (id_planeta, id_estrella),
    FOREIGN KEY (id_planeta) REFERENCES Planetas(id_cuerpo_celeste),
    FOREIGN KEY (id_estrella) REFERENCES Estrellas(id_cuerpo_celeste)
);