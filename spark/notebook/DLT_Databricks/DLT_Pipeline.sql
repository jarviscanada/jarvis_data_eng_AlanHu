-- reformatting/type casting
CREATE OR REFRESH STREAMING TABLE jarvis_training_catalog.dltproject.aapl_stock_data_silver
AS 
(
  SELECT
  CAST(timestamp AS DATE) AS date,
  CAST(open AS DECIMAL(8,2)),
  CAST(high AS DECIMAL(8,2)),
  CAST(low AS DECIMAL(8,2)),
  CAST(close AS DECIMAL(8,2)),
  volume,
  symbol,
  exchange, 
  sector
  FROM STREAM(jarvis_training_catalog.dltproject.aapl_stock_data_bronze)
);

CREATE OR REFRESH STREAMING TABLE jarvis_training_catalog.dltproject.googl_stock_data_silver
AS
(
  SELECT
  CAST(timestamp AS DATE) AS date,
  CAST(open AS DECIMAL(8,2)),
  CAST(high AS DECIMAL(8,2)),
  CAST(low AS DECIMAL(8,2)),
  CAST(close AS DECIMAL(8,2)),
  volume,
  symbol,
  exchange, 
  sector
  FROM STREAM(jarvis_training_catalog.dltproject.googl_stock_data_bronze)
);

CREATE OR REFRESH STREAMING TABLE jarvis_training_catalog.dltproject.tsla_stock_data_silver
AS
(
  SELECT
  CAST(timestamp AS DATE) AS date,
  CAST(open AS DECIMAL(8,2)),
  CAST(high AS DECIMAL(8,2)),
  CAST(low AS DECIMAL(8,2)),
  CAST(close AS DECIMAL(8,2)),
  volume,
  symbol,
  exchange, 
  sector
  FROM STREAM(jarvis_training_catalog.dltproject.tsla_stock_data_bronze)
);

CREATE OR REFRESH STREAMING TABLE jarvis_training_catalog.dltproject.msft_stock_data_silver
AS
(
  SELECT
  CAST(timestamp AS DATE) AS date,
  CAST(open AS DECIMAL(8,2)),
  CAST(high AS DECIMAL(8,2)),
  CAST(low AS DECIMAL(8,2)),
  CAST(close AS DECIMAL(8,2)),
  volume,
  symbol,
  exchange, 
  sector
  FROM STREAM(jarvis_training_catalog.dltproject.msft_stock_data_bronze)
);

-- now create gold aggregated table
CREATE OR REFRESH MATERIALIZED VIEW jarvis_training_catalog.dltproject.gold_stock_data
AS 
(
 SELECT 
date, symbol, exchange, sector, open, close, low, high, volume, 
CAST((close - LAG(close) OVER (PARTITION BY symbol ORDER BY date))/LAG(close) OVER (PARTITION BY symbol ORDER BY date) AS DECIMAL(10,4))
  AS daily_return,
  CAST(((close - open)/open)*100.0 AS DECIMAL(10,4)) AS pct_change
  FROM 
  (
  (SELECT * FROM jarvis_training_catalog.dltproject.aapl_stock_data_silver)
  UNION ALL
  (SELECT * FROM jarvis_training_catalog.dltproject.googl_stock_data_silver)
  UNION ALL
  (SELECT * FROM jarvis_training_catalog.dltproject.tsla_stock_data_silver)
  UNION ALL
  (SELECT * FROM jarvis_training_catalog.dltproject.msft_stock_data_silver)
  ) AS unified_silver
GROUP BY date, symbol, exchange, sector, open, close, low, high, volume
)


