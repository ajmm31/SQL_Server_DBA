-- #######################################################################
-- # TEMA: EL PLAN DE EJECUCIÓN (SCAN vs. SEEK)
-- # Objetivo: Demostrar cómo un índice Non-Clustered acelera la búsqueda.
-- # Base de Datos: AdventureWorksDW2022
-- #######################################################################

-- Paso 1. Asegúrete de estar usando la base de datos correcta.
USE AdventureWorksDW2022;
GO

-- Paso 2. LIMPIEZA: Eliminar el índice si existe para iniciar la prueba desde cero.
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_CustomerRegion')
    DROP INDEX IX_CustomerRegion ON FactInternetSales;
GO

PRINT '--- INICIO PRUEBA ---';

-- *******************************************************************
-- A. EL PROBLEMA (LENTO: CLUSTERED INDEX SCAN)
-- *******************************************************************
-- Active el Plan de Ejecución Actual (Ctrl + M) antes de correr esta consulta.
-- Busque en el Plan de Ejecución un 'Clustered Index Scan' con alto costo.
-- SQL Server está leyendo la tabla FactInternetSales completa (o una gran parte)
-- porque el índice por defecto (Clustered) no está optimizado para 'CustomerKey'.

SELECT  SalesOrderNumber,
        SalesAmount,
        ProductKey
FROM    dbo.FactInternetSales
WHERE   CustomerKey = 11185         -- Filtrando por un Cliente Específico
        AND SalesTerritoryKey = 6;  -- Filtrando por una Región Específica
GO

PRINT '--- CREANDO ÍNDICE DE OPTIMIZACIÓN... ---';

-- *******************************************************************
-- B. LA SOLUCIÓN (RÁPIDO: INDEX SEEK)
-- *******************************************************************
-- Crear un índice Non-Clustered compuesto (IX_CustomerRegion) que cubra
-- las columnas usadas en el filtro (WHERE) y las columnas seleccionadas (INCLUDE).

CREATE NONCLUSTERED INDEX IX_CustomerRegion
ON dbo.FactInternetSales (CustomerKey, SalesTerritoryKey)
INCLUDE (SalesOrderNumber, SalesAmount, ProductKey);
GO

-- Vuelva a correr la misma consulta.
-- Active el Plan de Ejecución Actual (Ctrl + M) y compárelo.
-- Ahora debe ver un 'Index Seek' en el nuevo índice (IX_CustomerRegion).

SELECT  SalesOrderNumber,
        SalesAmount,
        ProductKey
FROM    dbo.FactInternetSales
WHERE   CustomerKey = 11185         -- Filtrando por un Cliente Específico
        AND SalesTerritoryKey = 6;  -- Filtrando por una Región Específica
GO

PRINT '--- PRUEBA FINALIZADA. Rendimiento mejorado. ---';
-- #######################################################################