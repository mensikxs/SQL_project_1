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
   czechia_payroll: obsahuje údaje o mzdách v různých průmyslových odvětvích v ČR
   czechia_payroll_calculation: číselník kalkulací v tabulce mezd
   czechia_payroll_industry_branch:  číselník průmyslových odvětví
   czechia_payroll_unit: číselník jednotek hodnot v tabulce mezd
   czechia_payroll_value_type: číselník typů hodnot v tabulce mezd
   czechia_price: obsahuje údaje o cenách vybraných potravin v ČR (Portál otevřených dat ČR).
   czechia_price_category: číselník kategorií potravin
   economies: obsahuje údaje o HDP, GINI, daňové zátěži atd. pro daný stát a rok
   countries: obsahuje informace o různých zemích (hlavní město, měna, atd.)

Krok 1: Vytvoření hlavní tabulky - t_simona_mensikova_project_SQL_primary_final
   Tabulka spojuje data o mzdách v jednotlivých odvětvích, cenách potravin a kategoriích potravin. Vyloučeny byly záznamy s hodnotami NULL a byla         použita následující kritéria pro filtrování dat: 
      "value_type_code" 5958 -  pro hodnoty průměrných hrubých mezd
      "unit_code" 200 - pro hodnoty v CZK
      "calculation_code" 100 - pro hodnoty fyzického počtu zaměstnanců

      
