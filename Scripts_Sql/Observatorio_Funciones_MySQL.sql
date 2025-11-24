-- Cambiar el delimitador para permitir la creación de funciones
DELIMITER //

-- ====================================================================
-- FUNCIÓN 1: Años Luz (LY) a Kilómetros (KM)
-- ====================================================================
CREATE FUNCTION FN_LY_a_KM (
    distancia_ly DECIMAL(18, 6)
)
RETURNS DECIMAL(30, 6)
DETERMINISTIC
BEGIN
    
    DECLARE factor_conversion DECIMAL(18, 1);
    SET factor_conversion = 9460730472580.8; -- 9.461 x 10^12 km

    RETURN distancia_ly * factor_conversion;
END//


-- ====================================================================
-- FUNCIÓN 2: Celsius (°C) a Kelvin (K)
-- ====================================================================
CREATE FUNCTION FN_Celsius_a_Kelvin (
    temperatura_celsius DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE constante_kelvin DECIMAL(10, 2); 
    SET constante_kelvin = 273.15;

    RETURN temperatura_celsius + constante_kelvin;
END//

-- Restablecer el delimitador por defecto
DELIMITER ;