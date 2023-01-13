----CREATE TABLE(
----    ShipMode VARCHAR,
----	Segment VARCHAR,
----	Country VARCHAR,
----	City VARCHAR,
----	State VARCHAR,
----	Code VARCHAR,
----	Region VARCHAR,
----	Category VARCHAR,
----	SubCategory VARCHAR,
----	Sales FLOAT,
----	Quantity INTEGER,
----	Discount FLOAT,
----	Profit FLOAT);

-- Checking unique values
SELECT DISTINCT segment FROM superstore;
SELECT DISTINCT country FROM superstore;
SELECT DISTINCT city FROM superstore;
SELECT DISTINCT state FROM superstore;
SELECT COUNT (DISTINCT code) FROM superstore;
SELECT DISTINCT region FROM superstore;
SELECT DISTINCT category FROM superstore;
SELECT DISTINCT subCategory FROM superstore;

-- 1. Explanatory analysis: total orders, total sales, 
-- total profit, total discount, total items, average order value,
-- sales by category and subcategory, top 10 seling subcategory and their profit.
----SELECT 
----	COUNT(*) as total_orders,
----	SUM(sales) as total_sales,
----	SUM(profit) as total_profit,
----	SUM(discount) as total_discount,
----	SUM(quantity) as total_items,
----	AVG(sales) as average_order_value,
----	COUNT (DISTINCT category) as total_category,
----	COUNT (DISTINCT subcategory) as total_subcategory
----FROM superstore;

----SELECT 
----	category,
----	SUM(sales) as total_sales
----FROM superstore
----GROUP BY category
----ORDER BY SUM(sales) DESC;

----SELECT 
----	subcategory,
----	SUM(sales) as total_sales,
----	SUM(profit) as total_profit,
----	SUM(profit)/SUM(sales) as ratio
----FROM superstore
----GROUP BY subcategory
----ORDER BY SUM(sales) DESC
----LIMIT 10;

-- 2. Which region has the highest sales? 
-- Which customer segment has the highest sales?
----SELECT 
----	region,
----	SUM(sales) as total_sales
----FROM superstore
----GROUP BY 1
----ORDER BY total_sales DESC;

----SELECT 
----	segment,
----	SUM(sales) as total_sales
----FROM superstore
----GROUP BY 1
----ORDER BY total_sales DESC;

-- 3.Top 5 most profitable and Top 5 most unprofitable sub-categories.
----SELECT
----	subcategory,
----	SUM(profit) as total_profit
----FROM superstore
----GROUP BY subcategory
----ORDER BY SUM(profit) DESC
----LIMIT 5;

----SELECT
----	subcategory,
----	SUM(profit) as total_profit
----FROM superstore
----GROUP BY subcategory
----ORDER BY SUM(profit) ASC
----LIMIT 5;

-- 4.Sales by city of the country. 
-- Which postcode has the highest average price per sales?

----SELECT 
----    city, COUNT(1) as sales_count, SUM(sales) as total_sales, 
----	SUM(sales)/COUNT(1) as average_order 
----FROM superstore 
----GROUP BY city
----ORDER BY SUM(sales) DESC;

----SELECT code, AVG(sales) as average_order, COUNT(1) as sales_count
----FROM superstore
----GROUP BY code
----ORDER BY average_order DESC
----LIMIT 10;

-- 5.Quantity in table by customer segment and sub-category. 
-- Average Sales in table by customer segment and sub-category.
----SELECT subcategory, 
----    SUM(CASE WHEN segment = 'Consumer' then 1 else 0 end) as consumer_seg,
----	SUM(CASE WHEN segment = 'Home Office' then 1 else 0 end) as home_office_seg,
----	SUM(CASE WHEN segment = 'Corporate' then 1 else 0 end) as corporate_seg,
----	COUNT (subcategory) as total
----FROM superstore
----GROUP BY subcategory
----ORDER BY total DESC;

----SELECT subcategory, 
----    AVG(CASE WHEN segment = 'Consumer' then sales else null end) as consumer_seg,
----	AVG(CASE WHEN segment = 'Home Office' then sales else null end) as home_office_seg,
----	AVG(CASE WHEN segment = 'Corporate' then sales else null end) as corporate_seg,
----	AVG(sales) as total_average
----FROM superstore
----GROUP BY subcategory
----ORDER BY total DESC;

-- 6.The top selling subcategory is 'Binders'. Detailed consideration: sales by city and consumer segments, 
-- the level of discounts and the final profit.

----SELECT segment, city, 
----    SUM(sales) as total_sales,
----	SUM(discount) as total_discount,
----	SUM(profit) as total_profit
----FROM superstore
----WHERE subcategory = 'Binders'
----GROUP BY segment, city
----ORDER BY total_sales DESC;

-- 7.Analysis to determine the best sub category in sales.
WITH rfm as
(
	SELECT subcategory, 
  	    SUM(sales) as monetary_value,
		AVG(sales) as avg_monetary_value,
		COUNT(subcategory) as frequency
	FROM superstore
	GROUP BY subcategory
),
rfm_calc as
(
		SELECT r.*,
		NTILE(4) OVER (order by avg_monetary_value desc) rfm_recency,
		NTILE(4) OVER (order by frequency) rfm_frequency,
		NTILE(4) OVER (order by monetary_value) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into rfm
from rfm_calc as c