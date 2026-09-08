-- Fabric notebook source

-- METADATA ********************

-- META {
-- META   "kernel_info": {
-- META     "name": "synapse_pyspark"
-- META   },
-- META   "dependencies": {
-- META     "lakehouse": {
-- META       "default_lakehouse": "38153748-4605-4aa9-96d5-c848565db7d9",
-- META       "default_lakehouse_name": "Tablas_Gold",
-- META       "default_lakehouse_workspace_id": "c1099798-9ed1-461f-b5d2-843e5a67ccfd",
-- META       "known_lakehouses": [
-- META         {
-- META           "id": "38153748-4605-4aa9-96d5-c848565db7d9"
-- META         }
-- META       ]
-- META     }
-- META   }
-- META }

-- CELL ********************

USE dbo;

CREATE OR REPLACE TABLE dbo.gd_dim_calendario AS

WITH fechas AS (
    SELECT EXPLODE(SEQUENCE(TO_DATE('2026-01-01'), TO_DATE('2035-12-31'), INTERVAL 1 DAY)) AS fecha
),

feriados AS (
    SELECT CAST(fecha AS DATE) AS feriado_fecha
    FROM dbo.gd_feriados
),

base AS (
    SELECT fecha,
           YEAR(fecha) AS anio,
           MONTH(fecha) AS mes,
           DAY(fecha) AS dia,
           CASE WHEN DAYOFWEEK(fecha) = 1 THEN 7 ELSE DAYOFWEEK(fecha) - 1 END AS dia_semana,
           DATE_TRUNC('week', fecha) AS inicio_semana
    FROM fechas
),

primer_lunes AS (
    SELECT anio,
           CASE
               WHEN DAYOFWEEK(MAKE_DATE(anio,1,1)) = 2 THEN MAKE_DATE(anio,1,1)
               ELSE DATE_ADD(MAKE_DATE(anio,1,1), MOD(9 - DAYOFWEEK(MAKE_DATE(anio,1,1)),7))
           END AS primer_lunes
    FROM (SELECT DISTINCT anio FROM base)
),

semanas AS (
    SELECT DISTINCT b.inicio_semana,
           CASE
               WHEN b.inicio_semana < p.primer_lunes THEN YEAR(b.inicio_semana)
               ELSE YEAR(DATE_ADD(b.inicio_semana,6))
           END AS anio_semana
    FROM base b
    LEFT JOIN primer_lunes p
        ON YEAR(DATE_ADD(b.inicio_semana,6)) = p.anio
),

numeracion AS (
    SELECT inicio_semana,
           anio_semana,
           ROW_NUMBER() OVER(PARTITION BY anio_semana ORDER BY inicio_semana) AS semana
    FROM semanas
)

SELECT b.fecha,
       b.anio,
       b.mes,
       b.dia,
       n.semana,
       b.dia_semana,
       CASE WHEN b.dia_semana IN (6,7) THEN 1 ELSE 0 END AS es_fin_semana,
       CASE WHEN f.feriado_fecha IS NOT NULL THEN 1 ELSE 0 END AS es_feriado,
       CASE WHEN b.dia_semana IN (6,7) OR f.feriado_fecha IS NOT NULL THEN 0 ELSE 1 END AS dia_habil,
       CONCAT(n.anio_semana, LPAD(n.semana,2,'0')) AS anio_semana,
       b.inicio_semana,
       DATE_ADD(b.inicio_semana,6) AS fin_semana,
       CONCAT(b.anio,'-',LPAD(b.mes,2,'0')) AS anio_mes,
       CASE WHEN b.dia <= 15 THEN 1 ELSE 2 END AS quincena,
       CONCAT(b.anio,'-',LPAD(b.mes,2,'0'),' Q',CASE WHEN b.dia <= 15 THEN 1 ELSE 2 END) AS anio_mes_quincena
       --DATE_FORMAT(b.fecha, 'MMMM') AS nombre_mes,
       --DATE_FORMAT(b.fecha,'EEEE') AS nombre_dia
FROM base b
LEFT JOIN numeracion n
    ON b.inicio_semana = n.inicio_semana
LEFT JOIN feriados f
    ON b.fecha = f.feriado_fecha;

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
