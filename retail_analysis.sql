create table df_orders (
[order_id] int primary key,
[order_date] date,
[ship_mode] varchar(20),
[segment] varchar(20),
[country] varchar(20),
[city] varchar(20),
[state] varchar(20),
[postal_code] varchar(20),
[region] varchar(20),
[category] varchar(20),
[sub_category] varchar(20),
[product_id] varchar(20),
[quantity] int,
[discount] decimal(7,2),
[sale_price] decimal(7,2),
[profit] decimal(7,2))

use retail_order;
select * from df_orders;

-- Q1. Top  10 Highest Revenue generating products

SELECT top 10 product_id,
           sum(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;

--Q2. Top 5 highest selling proudcts in each region
WITH cte AS
  (SELECT region,
          product_id,
          sum(sale_price) AS sales
   FROM df_orders
   GROUP BY region,
            product_id)
SELECT *
FROM
  (SELECT *,
          ROW_NUMBER() over(PARTITION BY region
                            ORDER BY sales DESC) AS rn
   FROM cte) AS A
WHERE rn <=5 ;

--Q3. MoM growth comparision for 2022 and 2023 sales eg; jan 2022 vs jan 2023
WITH cte AS
  (SELECT year(order_date) AS order_year,
		  FORMAT(order_date, 'MMMM') as Months,
          month(order_date) AS order_month,
          sum(sale_price) AS sales
   FROM df_orders
   GROUP BY year(order_date),
            month(order_date),
			FORMAT(order_date, 'MMMM'))
SELECT Months,
       sum(CASE
               WHEN order_year = 2022 THEN sales
               ELSE 0
           END) AS sales_2022,
       sum(CASE
               WHEN order_year = 2023 THEN sales
               ELSE 0
           END) AS sales_2023
FROM cte
GROUP BY Months,order_month
ORDER BY order_month;

--Q3. Highest sales by month for each category
WITH cte AS
  (SELECT category,
          format(order_date, 'yyyy MMM') AS order_year_month,
          sum(sale_price) AS sales
   FROM df_orders
   GROUP BY category,
            format(order_date, 'yyyy MMM'))
SELECT *
FROM
  (SELECT *,
          ROW_NUMBER() over(PARTITION BY category
                            ORDER BY sales DESC) AS rn
   FROM cte) AS a
WHERE rn =1;

-- Q4. Sub category has highest growth by profit in 2023 compare to 2022
WITH cte AS
  (SELECT sub_category,
          year(order_date) AS order_year,
          sum(sale_price) AS sales
   FROM df_orders
   GROUP BY sub_category,
            year(order_date)),
     cte2 AS
  (SELECT sub_category,
          sum(CASE
                  WHEN order_year = 2022 THEN sales
                  ELSE 0
              END) AS Sales_2022,
          sum(CASE
                  WHEN order_year = 2023 THEN sales
                  ELSE 0
              END) AS Sales_2023
   FROM cte
   GROUP BY sub_category)
SELECT top 1 *,
             (Sales_2023 - Sales_2022)*100 /Sales_2022 AS Growth
FROM cte2
ORDER BY (Sales_2023 - Sales_2022)*100 /Sales_2022 DESC 

--Q5. Average Discount Percentage by Sub-Category

SELECT sub_category,
       count(*) AS total_orders,
       ROUND(AVG(discount*100.0 / (sale_price + discount)), 2) AS avg_discount_percent
FROM df_orders
GROUP BY sub_category
ORDER BY avg_discount_percent;

--Q6. Profit Margin Percentage by Product Category

SELECT category,
       sum(sale_price) AS total_sales,
       sum(profit) AS total_profit,
       ROUND(sum(profit) * 100.0 / nullif(sum(sale_price), 0), 2) AS profit_margin_percent
FROM df_orders
GROUP BY category
ORDER BY profit_margin_percent DESC;

--Q7. Top 5 Cities by Number of orders

SELECT top 5 city,
           count(order_id) AS total_orders,
           sum(sale_price) AS total_sales,
           sum(profit) AS total_profit
FROM df_orders
GROUP BY city
ORDER BY total_orders DESC;


SELECT top 5 city,
           count(order_id) AS total_orders,
           sum(sale_price) AS total_sales,
           sum(profit) AS total_profit
FROM df_orders
GROUP BY city
ORDER BY total_profit DESC;

--Q8. Yearly Sales and Profit by Customer Segment

SELECT SEGMENT,
       year(order_date) AS order_year,
       sum(sale_price) AS total_sales,
       sum(profit) AS total_profit
FROM df_orders
GROUP BY SEGMENT,
         year(order_date)
ORDER BY SEGMENT,
         order_year;

--Q9. Average Order Value by Year

SELECT year(order_date) AS order_year,
       count(DISTINCT order_id) AS total_orders,
       sum(sale_price) AS total_sales,
       round((sum(sale_price)/ COUNT(DISTINCT order_id)),2) AS avg_order_value
FROM df_orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

--Q10. Top 10 Days with Highest Total Sales

SELECT top 10 order_date,
           sum(sale_price) AS total_sales
FROM df_orders
GROUP BY order_date
ORDER BY total_sales DESC;

