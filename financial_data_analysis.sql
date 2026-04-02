/* ============================================================
   PROJECT: Financial Performance & Profitability Analytics
   TOOL: MySQL
   AUTHOR: Ajay Kumar
   DATABASE: financialanalyticsdb
   ============================================================ */


/* ============================================================
   STEP 1 — Create Database
   ============================================================ */

CREATE DATABASE financialanalyticsdb;

USE financialanalyticsdb;


/* ============================================================
   STEP 2 — Create Financial Table
   ============================================================ */

CREATE TABLE financial_data (

id INT AUTO_INCREMENT PRIMARY KEY,

segment VARCHAR(50),

country VARCHAR(50),

product VARCHAR(50),

discount_band VARCHAR(20),

units_sold INT,

manufacturing_price DECIMAL(10,2),

sale_price DECIMAL(10,2),

gross_sales DECIMAL(12,2),

discounts DECIMAL(12,2),

sales DECIMAL(12,2),

cogs DECIMAL(12,2),

profit DECIMAL(12,2),

order_date DATE,

month_number INT,

month_name VARCHAR(20),

year INT

);


/* ============================================================
   STEP 3 — Data Cleaning: Find Invalid Records
   ============================================================ */

SELECT *
FROM financial_data
WHERE sales < 0
OR profit < 0
OR units_sold < 0;


/* ============================================================
   STEP 4 — Detect Duplicate Records
   ============================================================ */

SELECT 

segment,
country,
product,
order_date,

COUNT(*) AS duplicate_count

FROM financial_data

GROUP BY

segment,
country,
product,
order_date

HAVING COUNT(*) > 1;


/* ============================================================
   STEP 5 — Create Cleaned Dataset
   ============================================================ */

CREATE TABLE financial_cleaned AS

SELECT *

FROM (

SELECT *,

ROW_NUMBER() OVER (

PARTITION BY

segment,
country,
product,
order_date

ORDER BY order_date

) AS row_num

FROM financial_data

) t

WHERE row_num = 1;


/* ============================================================
   STEP 6 — KPI Calculations
   ============================================================ */

SELECT 

SUM(sales) AS total_revenue,

SUM(profit) AS total_profit,

ROUND(
(SUM(profit)/SUM(sales))*100,
2
) AS profit_margin_percent,

SUM(units_sold) AS total_units_sold,

AVG(discounts) AS avg_discount

FROM financial_cleaned;


/* ============================================================
   STEP 7 — Revenue & Profit by Segment
   ============================================================ */

SELECT 

segment,

SUM(sales) AS total_revenue,

SUM(profit) AS total_profit,

ROUND(
(SUM(profit)/SUM(sales))*100,
2
) AS profit_margin_percent

FROM financial_cleaned

GROUP BY segment

ORDER BY total_revenue DESC;


/* ============================================================
   STEP 8 — Revenue by Country
   ============================================================ */

SELECT 

country,

SUM(sales) AS total_revenue,

SUM(profit) AS total_profit

FROM financial_cleaned

GROUP BY country

ORDER BY total_revenue DESC;


/* ============================================================
   STEP 9 — Monthly Revenue Trend
   ============================================================ */

SELECT 

year,
month_number,
month_name,

SUM(sales) AS monthly_revenue,

SUM(profit) AS monthly_profit

FROM financial_cleaned

GROUP BY 

year,
month_number,
month_name

ORDER BY 

year,
month_number;


/* ============================================================
   STEP 10 — Product Profitability Analysis
   ============================================================ */

SELECT 

product,

SUM(sales) AS total_revenue,

SUM(profit) AS total_profit

FROM financial_cleaned

GROUP BY product

ORDER BY total_profit DESC;


/* ============================================================
   STEP 11 — Discount Impact Analysis
   ============================================================ */

SELECT 

discount_band,

SUM(sales) AS total_revenue,

SUM(profit) AS total_profit,

ROUND(
(SUM(profit)/SUM(sales))*100,
2
) AS profit_margin_percent

FROM financial_cleaned

GROUP BY discount_band

ORDER BY discount_band;


/* ============================================================
   STEP 12 — Create Final Dashboard View
   ============================================================ */

CREATE VIEW financial_dashboard_view AS

SELECT 

segment,
country,
product,
discount_band,
year,
month_number,
month_name,

units_sold,
sales,
cogs,
profit

FROM financial_cleaned;


/* ============================================================
   STEP 13 — Load Dashboard Dataset
   ============================================================ */

SELECT *

FROM financial_dashboard_view;