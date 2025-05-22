-- User defined function : 'get_fiscal_year'

CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_year`(
	calendar_date date
) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE fiscal_year INT ;
    SET fiscal_year = year(date_add(calendar_date, INTERVAL 4 month ) ) ;
    RETURN fiscal_year ;
END

-- Stored procedure : market badge based on sold_quantity 

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
	IN in_fiscal_year YEAR,
    IN in_market varchar(45),
    OUT out_market_badge varchar(45)
)
BEGIN
	DECLARE qty INT DEFAULT 0 ;
    SET in_market = IF(in_market="", "INDIA", in_market) ;
    
	SELECT sum(s.sold_quantity) into qty
    FROM fact_sales_monthly s 
	JOIN dim_customer c 
		ON s.customer_code = c.customer_code 
	WHERE c.market = in_market 
		AND get_fiscal_year(s.date) = in_fiscal_year
	GROUP BY c.market ;
     
    SET out_market_badge = IF(qty > 5000000, "Gold", "Silver") ;
    
END
-- Gross Sales Report : Monthly Product Transactions --

SELECT 
	s.date, s.product_code, p.product, p.variant, 
	s.sold_quantity, g.gross_price, 
g.gross_price*s.sold_quantity as gross_price_total
FROM fact_sales_monthly s 
	JOIN dim_product p 
	ON s.product_code = p.product_code
	JOIN fact_gross_price g 
	ON g.product_code = s.product_code  
	AND g.fiscal_year = get_fiscal_year(s.date) 
WHERE customer_code = 90002002 AND 
	get_fiscal_year(s.date) = 2021 ;


-- Monthly Sales Report --

SELECT 
	s.date, 
    sum(g.gross_price*s.sold_quantity) as gross_price_total
FROM fact_sales_monthly s 
	JOIN fact_gross_price g 
	ON get_fiscal_year(s.date) = g.fiscal_year 
	AND s.product_code = g.product_code
WHERE s.customer_code = 90002002
GROUP BY s.date ;


-- Yearly Sales Report

SELECT 
	g.fiscal_year, 
	sum(g.gross_price*s.sold_quantity) as gross_price_total
FROM fact_sales_monthly s 
	JOIN fact_gross_price g 
	ON s.fiscal_year = g.fiscal_year 
    AND g.product_code = s.product_code
WHERE s.customer_code = 90002002
GROUP BY g.fiscal_year ;

SELECT * from fact_sales_monthly
