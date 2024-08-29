SELECT * FROM `sales supermarket`.`supermarket_sales - sheet1`;

DESCRIBE `sales supermarket`.`supermarket_sales - sheet1`;


-- Standarize date format

UPDATE  `sales supermarket`.`supermarket_sales - sheet1`
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE `sales supermarket`.`supermarket_sales - sheet1`
MODIFY COLUMN date date;


--  Standarize time format

UPDATE  `sales supermarket`.`supermarket_sales - sheet1`
SET time = str_to_date(time, '%H:%i:%s');

ALTER TABLE `sales supermarket`.`supermarket_sales - sheet1`
MODIFY COLUMN time time;

ALTER TABLE `sales supermarket`.`supermarket_sales - sheet1`
drop COLUMN DateConverted;




-- Remove Duplicate

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY City, Payment) AS row_num
FROM `sales supermarket`.`supermarket_sales - sheet1`;

WITH duplicate_cte AS
(

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY City,  Payment) AS row_num
FROM `sales supermarket`.`supermarket_sales - sheet1`
)

SELECT * FROM duplicate_cte 
WHERE row_num>1;


SELECT * FROM `sales supermarket`.`supermarket_sales - sheet1`
WHERE city = 'Mandalay';


SELECT DISTINCT(City)
FROM `sales supermarket`.`supermarket_sales - sheet1`;

-- Sales Total

SELECT SUM(`Unit price` * `Quantity`) AS Total_sales
FROM  `sales supermarket`.`supermarket_sales - sheet1`;

-- Total sales in January

SELECT ROUND(SUM(`Unit price` * `Quantity`)) AS Total_sales
FROM  `sales supermarket`.`supermarket_sales - sheet1`
WHERE 
month(date) = 1-- January  month
;

-- TOTAL ORDERS FOR Each respective month

SELECT COUNT(`Invoice ID`) AS Total_orders
FROM  `sales supermarket`.`supermarket_sales - sheet1`
WHERE 
month(date) = 3-- March  month
;


--  TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(date) AS month,
ROUND(COUNT(`Invoice ID`)) AS Total_orders,
(COUNT(`Invoice ID`) - LAG(COUNT(`Invoice ID`), 1) 
OVER (ORDER BY MONTH(date))) /LAG(COUNT(`Invoice ID`), 1) -- (LAG(COUNT(Invoice ID`), 1) OVER (ORDER BY MONTH(date)) the total number of transactions from the previous month
OVER (ORDER BY MONTH(date)) * 100 AS mom_increase_percentage
FROM  
`sales supermarket`.`supermarket_sales - sheet1`
WHERE 
    MONTH(date) IN (2, 3) -- for April and May
GROUP BY 
    MONTH(date)
ORDER BY 
MONTH(date);


-- Total Qunatite sold
SELECT SUM(`Quantity`) AS Quantite_sold
FROM  `sales supermarket`.`supermarket_sales - sheet1`;

--  TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
MONTH(date) AS month,
ROUND(COUNT(`Quantity`)) AS Quantite_sold,
(COUNT(`Quantity`) - LAG(COUNT(`Quantity`), 1) 
OVER (ORDER BY MONTH(date))) /LAG(COUNT(`Quantity`), 1) -- (LAG(COUNT(Invoice ID`), 1) OVER (ORDER BY MONTH(date)) the total number of transactions from the previous month
OVER (ORDER BY MONTH(date)) * 100 AS mom_increase_percentage
FROM  
`sales supermarket`.`supermarket_sales - sheet1`
WHERE 
    MONTH(date) IN (2, 3) -- for April and May
GROUP BY 
    MONTH(date)
ORDER BY 
MONTH(date);

-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS 
SELECT
day(`Invoice ID`) AS Daily_Sales,
SUM(`Unit price` * `Quantity`) AS total_sales
FROM 
  `sales supermarket`.`supermarket_sales - sheet1`
WHERE  MONTH(date) = 2  -- Filter for May
GROUP BY day(date)
ORDER BY date
;
SELECT
day_of_month,
 CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
		END AS sales_status,
         total_sales
FROM (
    SELECT 
        DAY(date) AS day_of_month,
        SUM(`Unit price` * `Quantity`) AS total_sales,
        AVG(SUM(`Unit price` * `Quantity`)) OVER() AVG_SALES
        FROM
        `sales supermarket`.`supermarket_sales - sheet1`
WHERE  MONTH(date) = 5  -- Filter for May
GROUP BY day(date)
) AS Sales_data
ORDER BY 
    day_of_month;  -- Check the resukt
    
    
-- SALES ANALYSIS BY PRODUCT CATEGORIE

SELECT 
    `Product line`,  
    SUM(`Unit price` * `Quantity`) AS total_sales 
FROM 
    `sales supermarket`.`supermarket_sales - sheet1` 
WHERE 
    MONTH(date) = 2 
GROUP BY `Product line`  
 ORDER BY SUM(`Unit price` * `Quantity`) desc
;

-- Top 5 Product By sales 
SELECT
`Product line`,
 SUM(`Unit price` * `Quantity`) AS total_sales 
FROM 
    `sales supermarket`.`supermarket_sales - sheet1` 
WHERE 
    MONTH(date) = 2 
GROUP BY  `Product line`  
 ORDER BY SUM(`Unit price` * `Quantity`) desc
 Limit 5;
 
 -- Sales Analysis by Days and Hours
 
 SELECT
 
 SUM(`Unit price` * `Quantity`) AS total_sales,
 SUM(`Quantity`)  AS Total_qty_sold,
 COUNT(*) AS Total_orders
 FROM 
   `sales supermarket`.`supermarket_sales - sheet1` 
   WHERE month(date) = 3
   AND dayofweek(date) = 3;
  
-- Hours  
  
  SELECT 
    HOUR(time),
    SUM(`Unit price` * `Quantity`) AS total_sales
    FROM
    `sales supermarket`.`supermarket_sales - sheet1` 
    WHERE MONTH(date) = 2
    GROUP BY HOUR(time)
	ORDER BY HOUR(time);
    
    -- SALES FROM MONDAY TO SUNDAY FOR MONTH OF MARCH
    SELECT
    CASE
       WHEN DAYOFWEEK(date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(date) = 7 THEN 'Saturday'
        ELSE  'Sunday'
        END AS DAY_OF_WEEK,
        
    ROUND(SUM(`Unit price` * `Quantity`)) AS total_sales
    FROM `sales supermarket`.`supermarket_sales - sheet1` 
    WHERE MONTH(date) = 3
    GROUP BY CASE 
     WHEN DAYOFWEEK(date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(date) = 7 THEN 'Saturday'
       ELSE  'Sunday'
	   END;
   
 
 
