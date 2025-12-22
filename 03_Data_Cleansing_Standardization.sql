-- #######################################################################
-- # TEMA 3: DATA ENGINEERING - LIMPIEZA Y ESTANDARIZACIÓN
-- # Objetivo: Manejar nulos y estandarizar formatos de texto (Data Quality).
-- # Base de Datos: AdventureWorksDW2022
-- #######################################################################

USE AdventureWorksDW2022;
GO

PRINT '--- 1. IDENTIFICANDO EL PROBLEMA: Datos inconsistentes o nulos ---';
SELECT  TOP 10 FirstName, 
        MiddleName, -- Muchos valores NULL aquí
        LastName, 
        EmailAddress
FROM    dbo.DimCustomer;
GO

PRINT '--- 2. APLICANDO TRANSFORMACIÓN (Data Cleansing) ---';
-- Un Ingeniero de Datos asegura que el consumidor final reciba datos limpios.

SELECT  TOP 10 FirstName,
        -- Función COALESCE reemplaza el nulo por un espacio vacío o un valor por defecto
        -- Función UPPER asegura uniformidad para búsquedas rápidas
        UPPER(ISNULL(MiddleName, '')) AS MiddleName_Clean,
        LastName,
        -- Creamos un campo de 'Nombre Completo' ya procesado
        CONCAT(FirstName, ' ', COALESCE(MiddleName + ' ', ''), LastName) AS FullName_Standardized,
        LOWER(EmailAddress) AS Email_Normalized
FROM    dbo.DimCustomer
WHERE   EmailAddress IS NOT NULL;
GO

PRINT '--- Pipeline de Calidad de Datos finalizado. ---';
-- #######################################################################