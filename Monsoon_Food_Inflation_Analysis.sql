create database Monsoon_Food_Inflation 


USE monsoon_food_inflation;

SELECT *
FROM sub_division_imd_2017
LIMIT 10;

SELECT
    COUNT(*) AS Total_Records,
    MIN(YEAR) AS Start_Year,
    MAX(YEAR) AS End_Year,
    COUNT(DISTINCT SUBDIVISION) AS Total_Subdivisions,
    SUM(Rainfall_mm IS NULL) AS Missing_Rainfall
FROM sub_division_imd_2017; 


SELECT
    SUBDIVISION,
    YEAR,
    COUNT(*) AS Months_Available
FROM sub_division_imd_2017
GROUP BY SUBDIVISION, YEAR
HAVING COUNT(*) < 12
ORDER BY YEAR, SUBDIVISION; 



SELECT
    YEAR,
    COUNT(*) AS Total_Records,
    SUM(Rainfall_mm IS NULL) AS Missing_Rainfall
FROM sub_division_imd_2017
WHERE YEAR BETWEEN 2013 AND 2017
GROUP BY YEAR
ORDER BY YEAR; 

---Q1. Validate the imported rainfall dataset by identifying 
the total number of records, earliest and latest years, number of unique subdivisions, 
and missing rainfall values.--- 


SELECT
    COUNT(*) AS Total_Records,
    MIN(YEAR) AS Start_Year,
    MAX(YEAR) AS End_Year,
    COUNT(DISTINCT SUBDIVISION) AS Total_Subdivisions,
    SUM(Rainfall_mm IS NULL) AS Missing_Rainfall
FROM sub_division_imd_2017; 

---CPI Data Validation---
SELECT
    COUNT(*) AS Total_Records,
    MIN(year) AS Start_Year,
    MAX(year) AS End_Year,
    COUNT(DISTINCT state) AS Total_States,
    COUNT(DISTINCT subgroup) AS Food_Categories,
    SUM(`index` IS NULL) AS Missing_Index,
    SUM(inflation IS NULL) AS Missing_Inflation
FROM cpi_historical_2013_2017;


---Check CPI records by year---
SELECT
    year,
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT month_code) AS Months_Available,
    COUNT(DISTINCT state) AS States_Available
FROM cpi_historical_2013_2017
GROUP BY year
ORDER BY year; 

---Q2. Identify the matching geographical names between 
the rainfall subdivisions and CPI states.--- 


SELECT DISTINCT
    c.state AS CPI_State,
    r.SUBDIVISION AS Rainfall_Subdivision
FROM cpi_historical_2013_2017 c
INNER JOIN sub_division_imd_2017 r
    ON LOWER(TRIM(c.state)) =
       LOWER(TRIM(r.SUBDIVISION))
ORDER BY c.state; 

---Q3. Match rainfall and food inflation records
 using the same state, year and month.--- 
 
 
SELECT
    c.state,
    c.year,
    c.month,
    c.subgroup,
    c.inflation,
    r.Rainfall_mm
FROM cpi_historical_2013_2017 c
INNER JOIN sub_division_imd_2017 r
    ON LOWER(TRIM(c.state)) = LOWER(TRIM(r.SUBDIVISION))
    AND c.year = r.YEAR
    AND UPPER(LEFT(c.month, 3)) = UPPER(r.Month)
WHERE c.year BETWEEN 2014 AND 2017
ORDER BY c.state, c.year, c.month_code, c.subgroup; 

---Q4. Calculate monthly rainfall deviations 
from historical averages for each subdivision.--- 


SELECT
    r.SUBDIVISION,
    r.YEAR,
    r.Month,
    r.Rainfall_mm,
    ROUND(h.Avg_Rainfall_mm, 2) AS Historical_Avg_mm,
    ROUND(
        r.Rainfall_mm - h.Avg_Rainfall_mm,
        2
    ) AS Rainfall_Deviation_mm
FROM sub_division_imd_2017 r
JOIN (
    SELECT
        SUBDIVISION,
        Month,
        AVG(Rainfall_mm) AS Avg_Rainfall_mm
    FROM sub_division_imd_2017
    WHERE YEAR BETWEEN 1901 AND 2013
    GROUP BY SUBDIVISION, Month
) h
    ON r.SUBDIVISION = h.SUBDIVISION
    AND r.Month = h.Month
WHERE r.YEAR BETWEEN 2014 AND 2017
ORDER BY r.SUBDIVISION, r.YEAR,
    FIELD(r.Month,
        'JAN','FEB','MAR','APR','MAY','JUN',
        'JUL','AUG','SEP','OCT','NOV','DEC'); 
        
        
---Q5. Compare average food inflation across vegetables,
 pulses and cereals during 2014–2017 --- 
 
 
SELECT
    subgroup AS Food_Category,
    COUNT(*) AS Total_Observations,
    ROUND(AVG(inflation), 2) AS Avg_Inflation_Percent,
    ROUND(MIN(inflation), 2) AS Min_Inflation_Percent,
    ROUND(MAX(inflation), 2) AS Max_Inflation_Percent
FROM cpi_historical_2013_2017
WHERE year BETWEEN 2014 AND 2017
  AND subgroup IN (
      'Vegetables',
      'Pulses and Products',
      'Cereals and Products'
  )
GROUP BY subgroup
ORDER BY Avg_Inflation_Percent DESC; 

---Q6. Test whether rainfall deviations are correlated with 
food inflation at lags of 0 to 6 months.--- 


CREATE OR REPLACE VIEW rainfall_inflation_base AS
SELECT
    c.state,
    c.subgroup AS Food_Category,
    STR_TO_DATE(
        CONCAT(c.year, '-', LPAD(c.month_code, 2, '0'), '-01'),
        '%Y-%m-%d'
    ) AS CPI_Date,
    c.inflation AS Inflation_Percent,
    r.Rainfall_mm,
    r.Rainfall_mm - h.Avg_Rainfall_mm AS Rainfall_Deviation_mm 
    
    
FROM cpi_historical_2013_2017 c
JOIN sub_division_imd_2017 r
    ON LOWER(TRIM(c.state)) = LOWER(TRIM(r.SUBDIVISION))
    AND c.year = r.YEAR
    AND UPPER(LEFT(c.month, 3)) = UPPER(r.Month)
JOIN (
    SELECT
        SUBDIVISION,
        Month,
        AVG(Rainfall_mm) AS Avg_Rainfall_mm
    FROM sub_division_imd_2017
    WHERE YEAR BETWEEN 1901 AND 2013
    GROUP BY SUBDIVISION, Month
) h
    ON r.SUBDIVISION = h.SUBDIVISION
    AND r.Month = h.Month
WHERE c.year BETWEEN 2014 AND 2017; 


SELECT COUNT(*) AS Total_Records
FROM rainfall_inflation_base; 


USE monsoon_food_inflation;

CREATE OR REPLACE VIEW rainfall_inflation_base AS
SELECT
    c.state,
    c.subgroup AS Food_Category,
    STR_TO_DATE(
        CONCAT(c.year, '-', LPAD(c.month_code, 2, '0'), '-01'),
        '%Y-%m-%d'
    ) AS CPI_Date,
    c.inflation AS Inflation_Percent,
    r.Rainfall_mm,
    r.Rainfall_mm - h.Avg_Rainfall_mm AS Rainfall_Deviation_mm
FROM cpi_historical_2013_2017 c
JOIN sub_division_imd_2017 r
    ON LOWER(TRIM(c.state)) = LOWER(TRIM(r.SUBDIVISION))
    AND c.year = r.YEAR
    AND UPPER(LEFT(c.month, 3)) = UPPER(r.Month)
JOIN (
    SELECT
        SUBDIVISION,
        Month,
        AVG(Rainfall_mm) AS Avg_Rainfall_mm
    FROM sub_division_imd_2017
    WHERE YEAR BETWEEN 1901 AND 2013
    GROUP BY SUBDIVISION, Month
) h
    ON r.SUBDIVISION = h.SUBDIVISION
    AND r.Month = h.Month
WHERE c.year BETWEEN 2014 AND 2017; 

---SQL Question 6 — Final part: Test 0–6 month lags
Now we need to compare rainfall deviations 
with food inflation occurring 0–6 months later.--- 


CREATE OR REPLACE VIEW rainfall_inflation_lags AS
SELECT
    c.state,
    c.subgroup AS Food_Category,
    MAKEDATE(c.year, 1)
        + INTERVAL (c.month_code - 1) MONTH AS CPI_Date,
    l.Lag_Months,
    c.inflation AS Inflation_Percent,
    r.Rainfall_mm,
    r.Rainfall_mm - h.Avg_Rainfall_mm
        AS Rainfall_Deviation_mm
FROM cpi_historical_2013_2017 c
CROSS JOIN (
    SELECT 0 AS Lag_Months
    UNION ALL SELECT 1
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
) l
JOIN sub_division_imd_2017 r
    ON LOWER(TRIM(c.state)) =
       LOWER(TRIM(r.SUBDIVISION))
    AND STR_TO_DATE(
        CONCAT(r.YEAR, '-', r.Month, '-01'),
        '%Y-%b-%d'
    ) = DATE_SUB(
        MAKEDATE(c.year, 1)
            + INTERVAL (c.month_code - 1) MONTH,
        INTERVAL l.Lag_Months MONTH
    )
JOIN (
    SELECT
        SUBDIVISION,
        Month,
        AVG(Rainfall_mm) AS Avg_Rainfall_mm
    FROM sub_division_imd_2017
    WHERE YEAR BETWEEN 1901 AND 2013
    GROUP BY SUBDIVISION, Month
) h
    ON r.SUBDIVISION = h.SUBDIVISION
    AND r.Month = h.Month
WHERE c.year BETWEEN 2014 AND 2017;



SELECT
    Lag_Months,
    COUNT(*) AS Matched_Records
FROM rainfall_inflation_lags
GROUP BY Lag_Months
ORDER BY Lag_Months; 


USE monsoon_food_inflation;

SELECT COUNT(*) AS CPI_Records
FROM cpi_historical_2013_2017; 


CREATE TABLE rainfall_analysis AS
SELECT
    r.SUBDIVISION AS state,
    STR_TO_DATE(
        CONCAT(r.YEAR, '-', r.Month, '-01'),
        '%Y-%b-%d'
    ) AS Rainfall_Date,
    r.Rainfall_mm,
    r.Rainfall_mm - h.Avg_Rainfall_mm
        AS Rainfall_Deviation_mm
FROM sub_division_imd_2017 r
JOIN (
    SELECT
        SUBDIVISION,
        Month,
        AVG(Rainfall_mm) AS Avg_Rainfall_mm
    FROM sub_division_imd_2017
    WHERE YEAR BETWEEN 1901 AND 2013
    GROUP BY SUBDIVISION, Month
) h
    ON r.SUBDIVISION = h.SUBDIVISION
    AND r.Month = h.Month
WHERE r.YEAR BETWEEN 2013 AND 2017; 


SELECT COUNT(*) AS Total_Records
FROM rainfall_analysis; 

---SQL Question 6 — Next step: Create lagged rainfall matches
We'll now use the smaller table to avoid the previous timeout.--- 


CREATE INDEX idx_rainfall_state_date
ON rainfall_analysis (state(100), Rainfall_Date);

CREATE OR REPLACE VIEW rainfall_inflation_lags AS
SELECT
    c.state,
    c.subgroup AS Food_Category,
    STR_TO_DATE(
        CONCAT(c.year, '-', LPAD(c.month_code, 2, '0'), '-01'),
        '%Y-%m-%d'
    ) AS CPI_Date,
    l.Lag_Months,
    c.inflation AS Inflation_Percent,
    r.Rainfall_mm,
    r.Rainfall_Deviation_mm
FROM cpi_historical_2013_2017 c
CROSS JOIN (
    SELECT 0 AS Lag_Months
    UNION ALL SELECT 1
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
) l
JOIN rainfall_analysis r
    ON LOWER(TRIM(c.state)) = LOWER(TRIM(r.state))
    AND r.Rainfall_Date = DATE_SUB(
        STR_TO_DATE(
            CONCAT(c.year, '-', LPAD(c.month_code, 2, '0'), '-01'),
            '%Y-%m-%d'
        ),
        INTERVAL l.Lag_Months MONTH
    )
WHERE c.year BETWEEN 2014 AND 2017; 


SELECT
    Lag_Months,
    COUNT(*) AS Matched_Records
FROM rainfall_inflation_lags
GROUP BY Lag_Months
ORDER BY Lag_Months; 



SELECT
    Food_Category,
    Lag_Months,
    COUNT(*) AS Observations,
    ROUND(
        (
            AVG(Rainfall_Deviation_mm * Inflation_Percent)
            - AVG(Rainfall_Deviation_mm) * AVG(Inflation_Percent)
        )
        /
        NULLIF(
            STDDEV_POP(Rainfall_Deviation_mm)
            * STDDEV_POP(Inflation_Percent),
            0
        ),
        4
    ) AS Correlation
FROM rainfall_inflation_lags
WHERE Rainfall_Deviation_mm IS NOT NULL
  AND Inflation_Percent IS NOT NULL
GROUP BY Food_Category, Lag_Months
ORDER BY Food_Category, Lag_Months; 


WITH Lag_Correlations AS (
    SELECT
        Food_Category,
        Lag_Months,
        COUNT(*) AS Observations,
        (
            AVG(Rainfall_Deviation_mm * Inflation_Percent)
            - AVG(Rainfall_Deviation_mm) * AVG(Inflation_Percent)
        ) /
        NULLIF(
            STDDEV_POP(Rainfall_Deviation_mm)
            * STDDEV_POP(Inflation_Percent),
            0
        ) AS Correlation
    FROM rainfall_inflation_lags
    WHERE Rainfall_Deviation_mm IS NOT NULL
      AND Inflation_Percent IS NOT NULL
    GROUP BY Food_Category, Lag_Months
),
Ranked_Lags AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Food_Category
            ORDER BY ABS(Correlation) DESC, Lag_Months
        ) AS Lag_Rank
    FROM Lag_Correlations
    WHERE Correlation IS NOT NULL
)
SELECT
    Food_Category,
    Lag_Months AS Strongest_Lag_Months,
    Observations,
    ROUND(Correlation, 4) AS Correlation
FROM Ranked_Lags
WHERE Lag_Rank = 1
ORDER BY Food_Category; 


USE monsoon_food_inflation;

SELECT *
FROM rainfall_inflation_lags; 



USE monsoon_food_inflation;

SELECT *
FROM rainfall_inflation_lags; 


USE monsoon_food_inflation;

CREATE TABLE lag_correlations AS
SELECT
    Food_Category,
    Lag_Months,
    COUNT(*) AS Observations,
    ROUND(
        (
            AVG(Rainfall_Deviation_mm * Inflation_Percent)
            - AVG(Rainfall_Deviation_mm) * AVG(Inflation_Percent)
        ) /
        NULLIF(
            STDDEV_POP(Rainfall_Deviation_mm)
            * STDDEV_POP(Inflation_Percent),
            0
        ),
        4
    ) AS Correlation
FROM rainfall_inflation_lags
WHERE Rainfall_Deviation_mm IS NOT NULL
  AND Inflation_Percent IS NOT NULL
GROUP BY Food_Category, Lag_Months; 


SELECT *
FROM lag_correlations
ORDER BY Food_Category, Lag_Months;
















        


 
 
 
 
 
 
 
 




















