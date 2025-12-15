-- #######################################################################
-- # TEMA 2: FUNCIONES DE VENTANA (LAG)
-- # Objetivo: DEMOSTRAR la diferencia de utilidad entre la simple agregación
-- #           y el cálculo analítico interanual con LAG().
-- # Base de Datos: AdventureWorksDW2022
-- #######################################################################

USE AdventureWorksDW2022;
GO

PRINT '--- 1. RESULTADO BASE: Venta Agregada por Año (Simple) ---';

-- *******************************************************************
-- A. VENTA AGREGADA SIMPLE (Resultado base sin valor analítico adicional)
-- *******************************************************************
SELECT  dimd.CalendarYear,
        SUM(fis.SalesAmount) AS Ventas_Totales_Anuales_BASE
FROM    dbo.FactInternetSales fis
        JOIN dbo.DimDate dimd ON fis.OrderDateKey = dimd.DateKey
GROUP BY dimd.CalendarYear
ORDER BY dimd.CalendarYear;
GO

PRINT '--- 2. RESULTADO ANALÍTICO: Comparación Interanual con LAG() ---';

-- *******************************************************************
-- B. ANÁLISIS DE TENDENCIAS EN FACTINTERNETSALES (FUNCIÓN LAG)
-- *******************************************************************
-- Usando una CTE para pre-agregar y luego aplicando la función de ventana.

WITH Ventas_Anuales AS
(
    -- Reutilizamos la agregación de la consulta simple
    SELECT  dimd.CalendarYear,
            SUM(fis.SalesAmount) AS Ventas_Totales_Anuales
    FROM    dbo.FactInternetSales fis
            JOIN
            dbo.DimDate dimd ON fis.OrderDateKey = dimd.DateKey
    GROUP BY dimd.CalendarYear
)
SELECT  va.CalendarYear,
        va.Ventas_Totales_Anuales,
        -- 1. La Función de Ventana LAG()
        -- Accede al valor de Ventas_Totales_Anuales de la fila inmediatamente anterior (1 periodo).
        LAG(va.Ventas_Totales_Anuales, 1) OVER (ORDER BY va.CalendarYear) AS Ventas_Año_Anterior,
        -- 2. Cálculo del Crecimiento (%)
        (va.Ventas_Totales_Anuales - LAG(va.Ventas_Totales_Anuales, 1) OVER (ORDER BY va.CalendarYear)) /
        NULLIF(LAG(va.Ventas_Totales_Anuales, 1) OVER (ORDER BY va.CalendarYear), 0) AS Crecimiento_Porcentual
FROM    Ventas_Anuales va
ORDER BY va.CalendarYear;
GO

PRINT '--- FIN DEL ANÁLISIS LAG() ---';
-- #######################################################################