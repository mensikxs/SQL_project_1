# Analýza mezd a cen potravin

## Úvod 
Tento projekt se zabývá analýzou dynamiky mezi mzdami, cenami potravin a růstem HDP v Česku, přičemž se zaměřuje na identifikaci trendů v různých odvětvích a kategoriích potravin.

## Použité technologie
Projekt byl realizován v prostředí DBeaver s využitím databázového systému MariaDB. SQL dotazy byly psány a testovány v tomto prostředí. Data byla zpracována pomocí relačních operací, agregací a výpočtů meziročních změn.

## Cíl
Cílem projektu je připravit sadu SQL, která poskytne datový podklad k odpovězení na několik následujících otázek:
   1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
   2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
   3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
   4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
   5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

## Použité datové sady:
-  czechia_payroll: obsahuje údaje o mzdách v různých průmyslových odvětvích v ČR
-  czechia_payroll_calculation: číselník kalkulací v tabulce mezd
-  czechia_payroll_industry_branch:  číselník průmyslových odvětví
-  czechia_payroll_unit: číselník jednotek hodnot v tabulce mezd
-  czechia_payroll_value_type: číselník typů hodnot v tabulce mezd
-  czechia_price: obsahuje údaje o cenách vybraných potravin v ČR (Portál otevřených dat ČR)
-  czechia_price_category: číselník kategorií potravin
-  economies: obsahuje údaje o HDP, GINI, daňové zátěži atd. pro daný stát a rok
-  countries: obsahuje informace o různých zemích (hlavní město, měna, atd.)

## Obsah repozitáře
Projekt je uložen v repozitáři se třemi hlavními soubory:
    - README.md – obsahuje úvod k projektu, popis datových sad a metodologie
    - project_01_simona_mensikova.sql – SQL skript obsahující všechny dotazy a výpočty použité v analýze
    - pruvodni_listina.md – dokument popisující projekt, jeho cíle, metodiku a odpovědi na výzkumné otázky

## Postup analýzy
1. Vytvoření hlavní tabulky (t_simona_mensikova_project_SQL_primary_final)
   - sloučení dat o mzdách, cenách potravin a kategoriích potravin
   - filtrování relevantních dat:
       - value_type_code = 5958 – pouze průměrné hrubé mzdy
       - unit_code = 200 – hodnoty pouze v CZK
       - calculation_code = 100 – fyzický počet zaměstnanců
2. Analýza růstu mezd (yearly_avg_salary)
   - výpočet průměrné mzdy pro každé odvětví a rok
   - srovnání meziročního růstu/klesání mezd
3. Analýza kupní síly (milk_bread_filtered)
   - výpočet množství chleba a mléka, které lze koupit za průměrnou mzdu
4. Analýza růstu cen potravin (yearly_avg_prices)
   - výpočet průměrné ceny potravin podle kategorií
   - identifikace nejpomalejšího meziročního růstu
5. Srovnání růstu mezd a cen potravin (growth_comparison)
   - výpočet meziročního růstu mezd
   - detekce let s vyšším růstem cen potravin než mezd (>10 %)
6. Analýza vlivu HDP na mzdy a ceny potravin (t_simona_mensikova_project_SQL_secondary_final)
   - spojení dat o HDP se mzdami a cenami potravin
   - výpočet meziročního růstu HDP (gdp_growth), mezd (salary_growth) a cen potravin (food_price_growth)
   - zjištění souvislostí mezi růstem HDP a růstem mezd a cen potravin (gdp_salary_food_comparison)

## Odpovědi na zadané otázky
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
    - Odpověď: Mzdy v průběhu let obecně rostou, ale v některých odvětvích dochází k meziročním poklesům. Jednalo se například o odvětví Zemědělství, lesnictví, rybářství z roku 2008 na 2009.
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
    - Odpověď: Pro výpočet byla srovnána průměrná mzda s průměrnou cenou mléka a chleba v prvním a posledním dostupném roce v datech. Výsledky ukazují:
        - Chléb: 2006- 1262 kg; 2018- 1319 kg
        - Mléko: 2006- 1409 litrů; 2018- 1614 litrů
    - kupní síla se v případě chleba a mléka zvýšila, protože za průměrnou mzdu si v roce 2018 bylo možné koupit více chleba i mléka než v roce 2006
3. Která kategorie potravin zdražuje nejpomaleji (má nejnižší procentuální meziroční nárůst)?
    - Odpověď: Nejnižší průměrný meziroční procentuální nárůst cen vykazuje cukr.
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
    - Odpověď: V žádném roce nebyl rozdíl mezi růstem cen potravin a růstem mezd větší než 10 %. To znamená, že i když ceny potravin rostly, nikdy nerostly o tolik rychleji než mzdy, aby překročily tuto hranici.
5. Má výška HDP vliv na změny ve mzdách a cenách potravin?
    - Odpověď: Výsledky ukázaly, že v letech s výraznějším růstem HDP došlo ve většině případů také k vyššímu růstu mezd a cen potravin. To naznačuje, že pokud HDP výrazně vzroste v jednom roce, projeví se to v následujících obdobích také na mzdách a cenách potravin.

## Závěr
Tento projekt ukazuje možnosti analýzy ekonomických dat pomocí SQL a nabízí základ pro případné rozšíření, například o analýzu dalších faktorů, jako jsou inflace nebo nezaměstnanost.
