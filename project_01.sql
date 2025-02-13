-- =======================================================================
-- project_01.sql: první projekt do Engeto Online Datové Akademie
-- author: Simona Menšíková
-- email: mensikxs@gmail.com
-- discord: mensikxs@gmail.com
-- =======================================================================

-- ===========================
-- DESCRIPTION
-- ===========================
-- This script performs various analyses on salary and food price data.
-- It includes the following sections:
-- 1. Creating a main table that combines payroll, food prices, and categories
-- 2. Analyzing salary trends across industries
-- 3. Investigating purchasing power (milk and bread)
-- 4. Identifying the food category with the slowest price growth
-- 5. Comparing wage growth and food price growth
-- 6. Analyzing the effect of GDP growth on salaries and food prices

-- ===========================
-- 1. CREATE MAIN TABLE
-- ===========================
-- This section creates the primary table that combines salary data, food 
-- prices, and food categories into one structured table for analysis.

CREATE TABLE t_simona_mensikova_project_SQL_primary_final AS
SELECT 
    cpayib.name AS industry,
    cpay.value AS average_salary,
    cpay.payroll_year,
    cpay.payroll_quarter,
    cpc.name AS food_category,
    cp.value AS price,
    YEAR(cp.date_from) AS price_year
FROM czechia_payroll AS cpay
INNER JOIN czechia_payroll_industry_branch AS cpayib
    ON cpay.industry_branch_code = cpayib.code
INNER JOIN czechia_price AS cp
    ON YEAR(cp.date_from) = cpay.payroll_year
INNER JOIN czechia_price_category AS cpc
    ON cp.category_code = cpc.code
WHERE cpay.value_type_code = 5958 -- The average gross wage per employee
  AND cpay.unit_code = 200 -- Czech crowns
  AND cpay.calculation_code = 100 -- The average physical number of employees
  AND cpay.value IS NOT NULL
  AND cpayib.name IS NOT NULL
  AND cpc.name IS NOT NULL
  AND cp.value IS NOT NULL;

-- ===========================
-- 2. SALARY TRENDS ANALYSIS
-- ===========================
-- This section analyzes whether salaries are increasing or decreasing 
-- in different industries over the years.

-- Create view for yearly average salaries
CREATE OR REPLACE VIEW yearly_avg_salary AS
SELECT 
    industry,
    payroll_year,
    AVG(average_salary) AS avg_salary_yearly -- Average salary per industry per year
FROM t_simona_mensikova_project_SQL_primary_final
GROUP BY industry, payroll_year;

-- Find industries where wages have decreased between consecutive years
SELECT 
    curr.industry,
    curr.payroll_year,
    curr.avg_salary_yearly,
    prev.avg_salary_yearly AS prev_year_salary
FROM yearly_avg_salary AS curr
INNER JOIN yearly_avg_salary AS prev
    ON curr.industry = prev.industry 
    AND curr.payroll_year = prev.payroll_year + 1
WHERE curr.avg_salary_yearly < prev.avg_salary_yearly
ORDER BY curr.industry, curr.payroll_year;
-- Outcome: Some industries have seen salary decreases.

-- ===========================
-- 3. PURCHASING POWER ANALYSIS
-- ===========================
-- This section answers how many liters of milk and kilograms of bread 
-- can be purchased with the average salary in the first and last available 
-- years of the dataset.

CREATE OR REPLACE VIEW milk_bread_filtered AS (
    SELECT 
        payroll_year,
        food_category,
        AVG(average_salary) AS avg_salary,
        AVG(price) AS avg_price
    FROM t_simona_mensikova_project_SQL_primary_final
    WHERE food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
    	AND payroll_year IN (
            SELECT MIN(payroll_year) FROM t_simona_mensikova_project_SQL_primary_final
            UNION
            SELECT MAX(payroll_year) FROM t_simona_mensikova_project_SQL_primary_final
	)
    GROUP BY payroll_year, food_category
);

SELECT *,
	ROUND(mbf.avg_salary/mbf.avg_price, 0) AS purchasable_quantity
FROM milk_bread_filtered AS mbf
ORDER BY mbf.food_category, mbf.payroll_year
;
-- Outcome: 
-- Bread: 2006 - 1262 kg, 2018 - 1319 kg
-- Milk: 2006 - 1409 l, 2018 - 1614 l

-- ===========================
-- 4. FOOD CATEGORY PRICE GROWTH
-- ===========================
-- This section identifies the food category with the slowest price increase.

CREATE OR REPLACE VIEW yearly_avg_prices AS
SELECT 
    food_category,
    price_year,
    AVG(price) AS avg_price
FROM t_simona_mensikova_project_SQL_primary_final
WHERE price IS NOT NULL -- Excludes records with NULL price values
GROUP BY food_category, price_year;

CREATE OR REPLACE VIEW price_growth AS
SELECT 
    curr.food_category,
    curr.price_year AS current_year,
    prev.price_year AS previous_year,
    curr.avg_price AS avg_price_current_year,
    prev.avg_price AS avg_price_previous_year,
    100 * (curr.avg_price - prev.avg_price) / prev.avg_price AS percent_growth
FROM yearly_avg_prices AS curr, yearly_avg_prices AS prev
WHERE curr.food_category = prev.food_category
  AND curr.price_year = prev.price_year + 1;

-- Output the food category with the lowest average yearly price growth
SELECT 
    food_category,
    AVG(percent_growth) AS avg_yearly_growth
FROM price_growth
GROUP BY food_category
ORDER BY avg_yearly_growth ASC
LIMIT 1;
-- Outcome: Sugar is the food category with the slowest price increase.

-- ===========================
-- 5. COMPARISON OF WAGE GROWTH AND FOOD PRICE GROWTH
-- ===========================
-- This section calculates Year-over-Year wage growth and food price growth,
-- and identifies the years where food price increases were more than 10% greater than wage growth.

-- Create view for yearly salary growth
CREATE OR REPLACE VIEW salary_growth AS
SELECT 
    curr.industry,
    curr.payroll_year AS current_year,
    prev.payroll_year AS previous_year,
    curr.avg_salary_yearly AS avg_salary_current_year,
    prev.avg_salary_yearly AS avg_salary_previous_year,
    100 * (curr.avg_salary_yearly - prev.avg_salary_yearly) / prev.avg_salary_yearly AS percent_growth -- Calculates percentage salary growth
FROM yearly_avg_salary AS curr, yearly_avg_salary AS prev
WHERE curr.industry = prev.industry
  AND curr.payroll_year = prev.payroll_year + 1;

CREATE OR REPLACE VIEW growth_comparison AS
SELECT 
    pg.current_year,
    AVG(pg.percent_growth) AS avg_food_price_growth,
    AVG(sg.percent_growth) AS avg_salary_growth,
    AVG(pg.percent_growth - sg.percent_growth) AS growth_difference
FROM price_growth AS pg
INNER JOIN salary_growth AS sg
    ON pg.current_year = sg.current_year
GROUP BY pg.current_year;

-- Output: The years in which food price growth outpaced salary growth by more than 10 %
SELECT current_year, avg_food_price_growth, avg_salary_growth, growth_difference
FROM growth_comparison
WHERE growth_difference > 10
ORDER BY current_year;
-- Outcome: No, there are no years where food price growth exceeded wage growth by more than 10%.

-- ===========================
-- 6. GDP IMPACT ON SALARIES AND FOOD PRICES
-- ===========================
-- This section analyzes the effect of GDP growth on salaries and food prices.

-- Create secondary table with GDP and country informationCREATE TABLE t_simona_mensikova_project_SQL_secondary_final AS (
SELECT
	economies.country,
	economies.`year` ,
	countries.capital_city,
	economies.GDP ,
	economies.taxes
FROM economies 
LEFT JOIN countries
	ON economies.country = countries.country
);

-- Calculate GDP growth
CREATE OR REPLACE VIEW gdp_growth AS
SELECT 
    year,
    100 * (MAX(GDP) - MIN(GDP)) / MIN(GDP) AS gdp_growth
FROM t_simona_mensikova_project_SQL_secondary_final
GROUP BY year;

-- Calculate salary growth
CREATE OR REPLACE VIEW salary_growth AS
SELECT 
    payroll_year AS year,
    100 * (MAX(avg_salary_yearly) - MIN(avg_salary_yearly)) / MIN(avg_salary_yearly) AS salary_growth
FROM yearly_avg_salary
GROUP BY payroll_year;

-- Calculate food price growth
CREATE OR REPLACE VIEW food_price_growth AS
SELECT 
    price_year AS year,
    100 * (MAX(avg_price) - MIN(avg_price)) / MIN(avg_price) AS price_growth
FROM yearly_avg_prices
GROUP BY price_year;

-- Compare GDP, salary, and food price growth
CREATE OR REPLACE VIEW gdp_salary_food_comparison AS
SELECT 
    g.year AS year,
    g.gdp_growth,
    s.salary_growth,
    f.price_growth
FROM gdp_growth g
LEFT JOIN salary_growth s ON g.year = s.year
LEFT JOIN food_price_growth f ON g.year = f.year;

-- Output years where GDP growth exceeded both salary and food price growth
SELECT 
    year,
    gdp_growth,
    salary_growth,
    price_growth
FROM gdp_salary_food_comparison
WHERE gdp_growth > salary_growth AND gdp_growth > price_growth -- Filters for years with higher GDP growth than both salary and food prices
ORDER BY year;
-- Outcome: Yes, GDP growth can influence changes in wages and food prices. GDP growth exceeded both salary and food price growth in certain years.






