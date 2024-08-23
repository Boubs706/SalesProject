SELECT * FROM `coffee shop sales`.`coffee shop sales`;


DESCRIBE `coffee shop sales`.`coffee shop sales`;



-- Convert it in date( the code is not correct please review it)

UPDATE `coffee shop sales`.`coffee shop sales`
SET transaction_date = STR_TO_DATE(transaction_date, '%m-%d-%Y');

ALTER TABLE  `coffee shop sales`.`coffee shop sales`
MODIFY COLUMN transaction_date date;


DESCRIBE `coffee shop sales`.`coffee shop sales`;



-- Convert it in Time

UPDATE `coffee shop sales`.`coffee shop sales`
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE `coffee shop sales`.`coffee shop sales`
MODIFY COLUMN transaction_time time;


DESCRIBE `coffee shop sales`.`coffee shop sales`;


SELECT * FROM `coffee shop sales`.`coffee shop sales`;

ALTER TABLE `coffee shop sales`.`coffee shop sales`
CHANGE COLUMN ï»¿transaction_id transaction_id int;




SELECT * FROM `coffee shop sales`.`coffee shop sales`;


-- TOTAL SALES

SELECT SUM(unit_price*transaction_qty) AS Total_sales
FROM  `coffee shop sales`.`coffee shop sales`;


-- TOTAL SALES IN MAY

SELECT ROUND(SUM(t_price*transaction_qty)) AS Total_sales
FROM  `coffee shop sales`.`coffee shop sales`
WHERE 
month(transaction_date) = 3-- March  month
;


-- TOTAL ORDERS FOR Each respective month

SELECT COUNT(transaction_id) AS Total_Orders
FROM  `coffee shop sales`.`coffee shop sales`
WHERE 
month(transaction_date) = 3-- March  month
;

--  TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
`coffee shop sales`.`coffee shop sales`  
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
MONTH(transaction_date);

-- Total Qunatite sold

SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM `coffee shop sales`.`coffee shop sales`  
WHERE MONTH(transaction_date) = 5 -- for month of (CM-May)
;

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
 `coffee shop sales`.`coffee shop sales` 
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS (chek the result

    
    SELECT     concat(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_sales,     
    concat(ROUND(SUM(transaction_qty)/1000,1), 'k') AS total_quantity_sold,     
    concat(ROUND(COUNT(transaction_id)/1000,1), 'K') AS total_orders 
    FROM      
    `coffee shop sales`.`coffee shop sales` 
    WHERE      transaction_date = '2023-03-27' 
    
    -- Sales Weekday and weekened
    -- Sun = 1
    --Mon = 2
    -- Sat = 7
    ;
    -- We should have weekend and wekkday to the query bellow
    
    SELECT 
     CASE WHEN DAYOFWEEK(transaction_date) IN(1,7) THEN 'Weekends'
     ELSE 'Weekdays'
     END AS day_type,
     CONCAT(round(SUM(unit_price * transaction_qty)/1000,1), 'k') As Total_sales
	FROM      
    `coffee shop sales`.`coffee shop sales` 
    WHERE MONTH   (transaction_date) = 2 -- February month
    GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
	END 
    
    --  Sales Analysis by store location
    
    SELECT
      store_location,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS TOTAL_SALES
     FROM    `coffee shop sales`.`coffee shop sales` 
     WHERE(transaction_date) = 2 -- February
     GROUP BY store_location
     ORDER BY SUM(unit_price * transaction_qty)DESC
     
     -- AVERAGE sales
    
  SELECT 
  CONCAT(ROUND(AVG(total_sales)/1000, 1), 'k') AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
`coffee shop sales`.`coffee shop sales` 
	WHERE 
        MONTH(transaction_date) = 4  -- Filter for May
    GROUP BY 
        transaction_date
) AS internal_query

    
    
-- DAILY SALES FOR the particular M

   
   SELECT 
    DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM 
   `coffee shop sales`.`coffee shop sales` 
WHERE  MONTH(transaction_date) = 5  -- Filter for May
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date)
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
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        `coffee shop sales`.`coffee shop sales`   
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    -- SALES ANALYSIS BY PRODUCT CATEGOORIE
    
    SELECT
    product_category,
    SUM(unit_price * transaction_qty) AS total_sales
    FROM   `coffee shop sales`.`coffee shop sales`   
    WHERE   MONTH(transaction_date) = 5
    GROUP BY   product_category
    ORDER BY SUM(unit_price * transaction_qty) desc
    ;
    
    -- Top 10 Product By sales 
	SELECT
    product_type,
    SUM(unit_price * transaction_qty) AS total_sales
    FROM   `coffee shop sales`.`coffee shop sales`   
    WHERE   MONTH(transaction_date) = 5
    GROUP BY   product_type
    ORDER BY SUM(unit_price * transaction_qty) desc
    LIMIT 10;
    
   -- Sales Analysis by Days and Hours
   
   SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) as Total_qty_sold,
    COUNT(*) AS Total_orders
	FROM   `coffee shop sales`.`coffee shop sales`      
	WHERE MONTH(transaction_date) = 5 -- Filter for May
    AND DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    ;
    
  -- Hours  
  
  SELECT 
    HOUR(transaction_time),
    SUM(unit_price * transaction_qty) AS total_sales
    FROM  `coffee shop sales`.`coffee shop sales`
    WHERE MONTH(transaction_date) = 5
    GROUP BY HOUR(transaction_time)
	ORDER BY HOUR(transaction_time);
    
-- SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY(we should get each day)
   SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
 `coffee shop sales`.`coffee shop sales`
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
 
    
    
    


   
   
     
