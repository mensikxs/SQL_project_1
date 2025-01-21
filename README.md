# Salary and Food Price Analysis Project

This project analyzes the relationship between wages, food prices, and GDP growth in Czechia. It examines how average salaries in various industries change over the years, tracks the prices of staple foods, and compares the growth rates of salaries and food prices. The data is sourced from payrolls, food price categories, and GDP records. This project aims to identify trends, including periods when food prices grew faster than wages or when GDP growth outpaced wage and food price changes.

## Project Description
This project is a comprehensive analysis of Czechia's salary and food price data. The SQL queries and views were designed to answer the following questions:
1. Are wages growing or declining in different industries over the years?
2. How much milk and bread can be purchased with the average salary in the first and last years of available data?
3. Which food category has the slowest annual price growth?
4. In which years did food price increases outpace wage growth by more than 10%?
5. Is there a correlation between GDP growth and changes in salaries and food prices?

## Requirements
- SQL database (e.g., MySQL, PostgreSQL, etc.)
- Data tables from Czechia's payroll, food price, and economic data sources
- Basic understanding of SQL for running queries and views

Ensure you have the required data tables in your SQL database. You will need the following data sources:
- czechia_payroll: Information on salaries across industries over multiple years (Open Data Portal of the Czech Republic).
- czechia_payroll_calculation: Codes for calculations in the payroll table.
- czechia_payroll_industry_branch: Codes for industries in the payroll table.
- czechia_payroll_unit: Codes for units of values in the payroll table.
- czechia_payroll_value_type: Codes for value types in the payroll table.
- czechia_price: Information on prices of selected food items over multiple years (Open Data Portal of the Czech Republic).
- czechia_price_category: Codes for food categories included in the dataset.
- countries: Various information about countries worldwide, such as capitals, currencies, national dishes, or average population heights.
- economies: GDP, GINI index, tax burdens, etc., for specific countries and years.

## Files and Outputs
SQL Script: Includes data preparation, analysis queries, and views.
### Intermediate Data:
- yearly_avg_salary: Average yearly salary by industry.
- milk_bread_filtered: Purchasing power data for milk and bread.
- price_growth: Yearly percentage growth of food prices.
- salary_growth: Yearly percentage growth of salaries.
- gdp_growth: Yearly GDP growth.
- gdp_salary_food_comparison: Combined data on GDP, salary, and food price growth.
### Output Data:
Insights on salary trends, purchasing power, slowest price growth category, and GDP influence.

### Data Notes
- Missing values are excluded during calculations.
- Comparisons are based only on available data; some years or categories may be incomplete.

## Usage:
- Open the SQL script in your SQL client.
- Run each section of the script to create tables and views.
- Execute the queries to get results on salary and food price analysis.
