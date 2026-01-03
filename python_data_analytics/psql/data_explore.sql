-- show retail schema
\d+ retail;

-- show first ten rows
SELECT * FROM retail LIMIT 10;

-- find number of records
SELECT COUNT(*) AS num_records FROM retail;

-- number of clients (unique client id)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- invoice date range
SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

-- number of SKU/merchants (unique stock code)
SELECT COUNT(DISTINCT stock_code) FROM retail;

-- average invoice amount excluding invoices with a negative amount (e.g. canceled orders have negative amount)
SELECT AVG(invoice_amount)
FROM (
SELECT invoice_no, SUM(quantity*unit_price) AS invoice_amount
FROM retail
GROUP BY invoice_no
HAVING SUM(quantity*unit_price) > 0
);

-- total revenue
SELECT SUM(quantity*unit_price) FROM retail;

-- total revenue by YYYYMM
WITH invoice_as_date (invoice_date, invoice_year, invoice_month) AS
(
SELECT CAST(invoice_date AS DATE),
EXTRACT (YEAR FROM invoice_date),
EXTRACT (MONTH FROM invoice_date),
quantity,
unit_price
FROM retail
)

SELECT invoice_year * 100 + invoice_month AS "YYYYMM",
SUM(quantity*unit_price) AS total_revenue
FROM invoice_as_date
GROUP BY 1
ORDER BY 1 ASC;