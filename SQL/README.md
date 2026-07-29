# 🧠 SQL – Advanced Analysis

## Purpose  
SQL was used to perform structured, in-depth analysis of the dataset, focusing on trends, comparisons, and economic efficiency over time.

## Key Queries  
- Monthly and yearly profit and sales trends  
- Gross profit margin by product and segment  
- Month-on-month % changes in:
  - Sales  
  - Profit  
  - COGS per unit vs Revenue per unit  
- Product profit and sales contribution breakdown

## Optimizations  
- Common Table Expressions (CTEs) and window functions were used for clean, efficient querying  
- Designed to scale with larger datasets

## Insights Gained  
- Sales and profit moved in a similar pattern
- The COGS per unit was stable at around 0 with very few distortions  
- The Product Paeso had high revenue but unimpressive margins
- Each product's Contribution to sales was similar to their contribution to profits

### Key SQL Queries
 **MoM % Change in COGS per Unit vs Revenue per Unit**
   ```sql
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
   ```

 **Product Sales Contribution**
   ```sql
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
   ```

