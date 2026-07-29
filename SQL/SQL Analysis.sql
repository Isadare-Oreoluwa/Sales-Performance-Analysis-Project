-- 1. Monthly Sales Trend
SELECT
  year,
  month_number,
  month_name,
  SUM(sales) AS monthly_sales
FROM sales_data
GROUP BY year, month_number, month_name
ORDER BY year, month_number;


-- 2. Monthly Profit Trend
SELECT
  year,
  month_number,
  month_name,
  SUM(profit) AS monthly_profit
FROM sales_data
GROUP BY year, month_number, month_name
ORDER BY year, month_number;


-- 3. Total Sales and Profit by Country
SELECT
  country,
  SUM(sales) AS total_sales,
  SUM(profit) AS total_profit
FROM sales_data
GROUP BY country
ORDER BY total_sales DESC;


-- 4. MoM % Change in Sales and Profit
WITH monthly_totals AS (
  SELECT
    year,
    month_number,
    month_name,
    SUM(sales) AS sales,
    SUM(profit) AS profit
  FROM sales_data
  GROUP BY year, month_number, month_name
)
SELECT
  *,
  LAG(sales) OVER (ORDER BY year, month_number) AS prev_sales,
  LAG(profit) OVER (ORDER BY year, month_number) AS prev_profit,
  ROUND((sales - LAG(sales) OVER (ORDER BY year, month_number)) / NULLIF(LAG(sales) OVER (ORDER BY year, month_number), 0) * 100, 2) AS sales_mom_change_pct,
  ROUND((profit - LAG(profit) OVER (ORDER BY year, month_number)) / NULLIF(LAG(profit) OVER (ORDER BY year, month_number), 0) * 100, 2) AS profit_mom_change_pct
FROM monthly_totals
ORDER BY year, month_number;


-- 5. Gross Profit Margin Trend
SELECT
  year,
  month_number,
  month_name,
  SUM(profit) AS total_gross_profit,
  SUM(sales) AS total_sales,
  ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS gross_profit_margin
FROM sales_data
GROUP BY year, month_number, month_name
ORDER BY year, month_number;


-- 6. Profit Margin by Product
SELECT
  product,
  ROUND(100 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS product_gross_profit_margin
FROM sales_data
GROUP BY product
ORDER BY product_gross_profit_margin DESC;


-- 7. Product Sales Contribution
WITH product_sales AS (
  SELECT product, SUM(sales) AS total_sales
  FROM sales_data
  GROUP BY product
),
all_sales AS (
  SELECT SUM(total_sales) AS grand_total FROM product_sales
)
SELECT 
  ps.product,
  ps.total_sales,
  ROUND(100.0 * ps.total_sales / a.grand_total, 2) AS sales_percentage_contribution
FROM product_sales ps, all_sales a
ORDER BY sales_percentage_contribution DESC;


-- 8. Product profit Contribution
WITH product_profit AS (
  SELECT product, SUM(profit) AS total_profit
  FROM sales_data
  GROUP BY product
),
all_profit AS (
  SELECT SUM(total_profit) AS grand_total FROM product_profit
)
SELECT 
  pp.product,
  pp.total_profit,
  ROUND(100.0 * pp.total_profit / a.grand_total, 2) AS profit_percentage_contribution
FROM product_profit pp, all_profit a
ORDER BY profit_percentage_contribution DESC;


-- 9. COGS/Unit and Revenue/Unit Trend
WITH monthly_values AS (
  SELECT
    year,
    month_number,
    month_name,
    SUM(units_sold) AS total_units,
    ROUND(SUM(cogs) / NULLIF(SUM(units_sold), 0), 2) AS avg_cogs_per_unit,
    ROUND(SUM(sales) / NULLIF(SUM(units_sold), 0), 2) AS avg_revenue_per_unit
  FROM sales_data
  GROUP BY year, month_number, month_name
)
SELECT *
FROM monthly_values
ORDER BY year, month_number;


-- 10. MoM % Change in COGS per Unit vs Revenue per Unit
WITH monthly_values AS (
  SELECT
    year,
    month_number,
    month_name,
    SUM(units_sold) AS total_units,
    ROUND(SUM(cogs/NULLIF(units_sold, 0)), 2) AS cogs_per_unit,
    ROUND(SUM(sales/NULLIF(units_sold, 0)), 2) AS revenue_per_unit
  FROM sales_data
  GROUP BY year, month_number, month_name
),
lagged_values AS (
  SELECT
    *,
    LAG(cogs_per_unit) OVER (ORDER BY year, month_number) AS prev_cogs_per_unit,
    LAG(revenue_per_unit) OVER (ORDER BY year, month_number) AS prev_revenue_per_unit
  FROM monthly_values
)
SELECT
  *,
  ROUND((cogs_per_unit - prev_cogs_per_unit) / NULLIF(prev_cogs_per_unit, 0) * 100, 2) AS cogs_per_unit_mom_change_pct,
  ROUND((revenue_per_unit - prev_revenue_per_unit) / NULLIF(prev_revenue_per_unit, 0) * 100, 2) AS revenue_per_unit_mom_change_pct
FROM lagged_values
ORDER BY year, month_number;