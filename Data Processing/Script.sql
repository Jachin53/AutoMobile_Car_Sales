--- Show all Columns
SELECT *
FROM CARSALES.AUTOMOBILE.CARSALESDATASET LIMIT 10;

--- There are only 98 Car Makes in Count.

SELECT COUNT(DISTINCT MAKE) AS Make_Count
FROM CARSALES.AUTOMOBILE.CARSALESDATASET;

-- Number of transmissions are only 4.
SELECT COUNT(DISTINCT transmission) AS Transmisssion_Count
FROM CARSALES.AUTOMOBILE.CARSALESDATASET;

--- Number of sellers.
SELECT COUNT(DISTINCT SELLER) AS Number_of_Sellers
FROM CARSALES.AUTOMOBILE.CARSALESDATASET;

---- Units sold
SELECT COUNT(*) AS Units_Sold
FROM CARSALES.AUTOMOBILE.CARSALESDATASET;

-- Basic vehicle info
SELECT
  YEAR, MAKE, MODEL, TRIM, BODY, TRANSMISSION, VIN, STATE, CONDITION, COLOR, INTERIOR, SELLER, MMR,
  -- Cleaned numeric price
  CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) AS selling_price_numeric,

  -- Sales metrics
  COUNT(*) AS units_sold,
  SUM(CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC)) AS total_revenue,

  -- Profit margin calculation
  ROUND((CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) - MMR) / CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) * 100, 2) AS profit_margin_percent,

  -- Performance tier classification
  CASE
    WHEN (CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) - MMR) / CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) >= 0.25 THEN 'High Margin'
    WHEN (CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) - MMR) / CAST(REPLACE(SELLINGPRICE, ',', '') AS NUMERIC) BETWEEN 0.10 AND 0.249 THEN 'Medium Margin'
    ELSE 'Low Margin'
  END AS performance_tier,

  -- Fuel type inference from TRIM
  CASE
    WHEN LOWER(TRIM) LIKE '%hybrid%' THEN 'Hybrid'
    WHEN LOWER(TRIM) LIKE '%ev%' OR LOWER(TRIM) LIKE '%electric%' THEN 'Electric'
    WHEN LOWER(TRIM) LIKE '%diesel%' THEN 'Diesel'
    WHEN LOWER(TRIM) LIKE '%gas%' OR LOWER(TRIM) LIKE '%petrol%' THEN 'Petrol'
    ELSE 'Unknown'
  END AS inferred_fuel_type,

  -- Timestamp formatting
  TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS') AS sale_timestamp,
  CAST(TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS') AS DATE) AS sale_date,
  TO_CHAR(TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS'), 'HH24:MI:SS') AS sale_time,
  DAYNAME(TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS')) AS day_name,
  EXTRACT(HOUR FROM TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS')) AS hour_of_the_day,

  -- Time period grouping
  MONTHNAME(TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS')) AS month_name,
  QUARTER(TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS')) AS quarter,
  EXTRACT(YEAR FROM TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS')) AS sale_year

FROM CARSALES.AUTOMOBILE.CARSALESDATASET

-- Filter out invalid dates
WHERE TRY_TO_TIMESTAMP(saledate, 'Dy Mon DD YYYY HH24:MI:SS') IS NOT NULL

GROUP BY
  YEAR, MAKE, MODEL, TRIM, BODY, TRANSMISSION, VIN, STATE, CONDITION, COLOR, INTERIOR, SELLER, MMR,
  SELLINGPRICE, SALEDATE;
