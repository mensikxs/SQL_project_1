# Analýza mezd a cen potravin

## Úvod 
Tento projekt se zabývá analýzou dynamiky mezi mzdami, cenami potravin a růstem HDP v Česku, přičemž se zaměřuje na identifikaci trendů v různých odvětvích a kategoriích potravin.

## Cíl
Cílem projektu je připravit sadu SQL, která poskytne datový podklad k odpovězení na několik následujících otázek:
   1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
   2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
   3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
   4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
   5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Použité datové sady:
-  czechia_payroll: obsahuje údaje o mzdách v různých průmyslových odvětvích v ČR
-  czechia_payroll_calculation: číselník kalkulací v tabulce mezd
-  czechia_payroll_industry_branch:  číselník průmyslových odvětví
-  czechia_payroll_unit: číselník jednotek hodnot v tabulce mezd
-  czechia_payroll_value_type: číselník typů hodnot v tabulce mezd
-  czechia_price: obsahuje údaje o cenách vybraných potravin v ČR (Portál otevřených dat ČR)
-  czechia_price_category: číselník kategorií potravin
-  economies: obsahuje údaje o HDP, GINI, daňové zátěži atd. pro daný stát a rok
-  countries: obsahuje informace o různých zemích (hlavní město, měna, atd.)

#### Krok 1: Vytvoření hlavní tabulky
Tabulka: t_simona_mensikova_project_SQL_primary_final
- sloučení dat o mzdách, cenách potravin a kategoriích potravin
- vyloučení záznamů s hodnotami NULL
- použité filtry:
    - value_type_code = 5958 – pouze průměrné hrubé mzdy
    - unit_code = 200 – hodnoty pouze v CZK
    - calculation_code = 100 – fyzický počet zaměstnanců

#### Krok 2: Analýza růstu mezd
Pohled: yearly_avg_salary
- výpočet průměrné mzdy pro každé odvětví a rok
- srovnání meziročního růstu/klesání mezd

#### Krok 3: Analýza kupní síly
Pohled: milk_bread_filtered
- zaměřeno na mléko a chléb
- výpočet, kolik jednotek lze koupit za průměrnou mzdu v prvním a posledním roce

#### Krok 4: Analýza růstu cen potravin
Pohled: yearly_avg_prices
- výpočet průměrné ceny potravin podle kategorií
- identifikace nejpomalejšího meziročního růstu

#### Krok 5: Srovnání růstu mezd a cen potravin
Pohled: growth_comparison
 - výpočet meziročního růstu mezd
 - SQL dotaz pro detekci let s vyšším růstem cen potravin než mezd (o 10 %)

#### Krok 6: Analýza vlivu HDP na mzdy a ceny potravin
Tabulka: t_simona_mensikova_project_SQL_secondary_final
- spojení dat o HDP se mzdami a cenami potravin

Pohled:
- gdp_growth - výpočet meziročního růstu HDP 
- salary_growth – výpočet meziročního růstu průměrné mzdy
- food_price_growth - výpočet meziročního růstu cen potravin na základě průměrné ceny
- gdp_salary_food_comparison - spojení pohledů gdp_growth, salary_growth a food_price_growth na základě roku
    - SQL dotaz pro detekci let, ve kterých růst HDP převýšil růst mezd a cen potravin


  

      
