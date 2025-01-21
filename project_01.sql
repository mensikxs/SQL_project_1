-- Creating main table for the project
-- Combines salary data, food prices, and food categories into a single table.
-- NOTE: This table excludes records with NULL values in salary, price, or category names.

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

-- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Are salaries increasing across industries over the years or decreasing in some?

CREATE OR REPLACE VIEW yearly_avg_salary AS
SELECT 
    industry,
    payroll_year,
    AVG(average_salary) AS avg_salary_yearly -- Average salary per industry per year
FROM t_simona_mensikova_project_SQL_primary_final
GROUP BY industry, payroll_year;

-- Output: Industries and years where wages have decreased between consecutive years
-- The query compares the average salary of the current year with the previous year for each industry.
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
-- Answer: No, in some industries, wages are decreasing.

/* 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první 
a poslední srovnatelné období v dostupných datech cen a mezd?
*/
-- How much milk and bread can be bought in the first and last comparable periods in the available data?

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

/*Output: The quantity of milk and bread (in liters and kilograms) that can be bought with 
 the average salary for the first and last years?
 */
SELECT *,
	ROUND(mbf.avg_salary/mbf.avg_price, 0) AS purchasable_quantity
FROM milk_bread_filtered AS mbf
ORDER BY mbf.food_category, mbf.payroll_year
;
-- answer: bread: 2006-1262, 2018-1319; milk: 2006-1409, 2018-1614

-- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- Which food category has the slowest price increase (lowest annual percentage growth)?

CREATE OR REPLACE VIEW yearly_avg_prices AS
SELECT 
    food_category,
    price_year,
    AVG(price) AS avg_price
FROM t_simona_mensikova_project_SQL_primary_final
WHERE price IS NOT NULL -- Excludes records with NULL price values
GROUP BY food_category, price_year;

-- Intermediate Result: `price_growth`
-- Calculates the annual percentage price growth for each food category.
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

-- Output: The food category with the lowest average yearly price growth.
SELECT 
    food_category,
    AVG(percent_growth) AS avg_yearly_growth
FROM price_growth
GROUP BY food_category
ORDER BY avg_yearly_growth ASC
LIMIT 1;
-- answer: Sugar

-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- Is there a year in which the annual increase in food prices was significantly higher than wage growth (greater than 10 %)?

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
-- Filters for years where the difference exceeds 10 %
SELECT current_year, avg_food_price_growth, avg_salary_growth, growth_difference
FROM growth_comparison
WHERE growth_difference > 10
ORDER BY current_year;
-- answer: No

/* 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin 
či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
Does GDP growth influence changes in wages and food prices? If GDP grows significantly 
in one year, does it lead to a significant increase in salaries or food prices in the same 
or following year?
*/

-- Creates a secondary table with GDP data and country information.
CREATE TABLE t_simona_mensikova_project_SQL_secondary_final AS (
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

-- GDP Growth Calculation
CREATE OR REPLACE VIEW gdp_growth AS
SELECT 
    year,
    100 * (MAX(GDP) - MIN(GDP)) / MIN(GDP) AS gdp_growth
FROM t_simona_mensikova_project_SQL_secondary_final
GROUP BY year;

-- Salary Growth Calculation
CREATE OR REPLACE VIEW salary_growth AS
SELECT 
    payroll_year AS year,
    100 * (MAX(avg_salary_yearly) - MIN(avg_salary_yearly)) / MIN(avg_salary_yearly) AS salary_growth
FROM yearly_avg_salary
GROUP BY payroll_year;

-- Food Price Growth Calculation
CREATE OR REPLACE VIEW food_price_growth AS
SELECT 
    price_year AS year,
    100 * (MAX(avg_price) - MIN(avg_price)) / MIN(avg_price) AS price_growth
FROM yearly_avg_prices
GROUP BY price_year;

-- Comparison between GDP growth, salary growth, and food price growth
CREATE OR REPLACE VIEW gdp_salary_food_comparison AS
SELECT 
    g.year AS year,
    g.gdp_growth,
    s.salary_growth,
    f.price_growth
FROM gdp_growth g
LEFT JOIN salary_growth s ON g.year = s.year
LEFT JOIN food_price_growth f ON g.year = f.year;

-- Output: Years when GDP growth exceeded both salary and food price growth
SELECT 
    year,
    gdp_growth,
    salary_growth,
    price_growth
FROM gdp_salary_food_comparison
WHERE gdp_growth > salary_growth AND gdp_growth > price_growth -- Filters for years with higher GDP growth than both salary and food prices
ORDER BY year;
-- answer: Yes















