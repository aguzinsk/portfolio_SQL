-- I had to change column total death from text to numerical values since it did not order correctly

ALTER TABLE coviddeaths1_csv
ADD COLUMN total_death_num int SIGNED;

UPDATE coviddeaths1_csv
SET total_death_num = 
	CASE
		WHEN total_deaths = '' THEN NULL
        ELSE CAST(total_deaths AS SIGNED)
        END;
        
SELECT * 
FROM coviddeaths1_csv;

-- Ranking of selected countries from each continent with the most deaths at the end of 2020, and end of April 2021

SELECT continent, location, population, total_cases, `date`, total_death_num, (total_death_num/ total_cases)*100 as percent_of_deaths, human_development_index
FROM coviddeaths1_csv
WHERE `date` = '2020-12-31'
AND TRIM(human_development_index) != ''
ORDER BY total_death_num DESC;

--
WITH ranking_continent AS
(
SELECT continent, location, population, total_cases, `date`, total_death_num, (total_death_num/ total_cases)*100 as percent_of_deaths, human_development_index
FROM coviddeaths1_csv
WHERE `date` = '2020-12-31'
AND TRIM(human_development_index) != ''

), ranking_continent2 AS
(
SELECT *, dense_rank() OVER(PARTITION BY continent ORDER BY percent_of_deaths DESC) as ranking
FROM ranking_continent

), ranking_continent3 AS
(
SELECT continent, location, population, total_cases, `date`, total_death_num, (total_death_num/ total_cases)*100 as percent_of_deaths, human_development_index
FROM coviddeaths1_csv
WHERE `date` = '2021-04-30'
AND TRIM(human_development_index) != ''

), ranking_continent4 AS
(
SELECT *, dense_rank() OVER(PARTITION BY continent ORDER BY percent_of_deaths DESC) as ranking
FROM ranking_continent3

)
-- I wanted to see next to each other the results separately for 2020 and 2021 so i decide to join two tables
SELECT rc4.continent, 
rc4.location,
rc4.percent_of_deaths as percent_of_deaths_2021_04,
rc4.ranking,
rc2.continent, 
rc2.location,
rc2.percent_of_deaths as percent_of_deaths_2020_12,
rc2.ranking
FROM ranking_continent4 as rc4
JOIN ranking_continent2 as rc2
	ON rc4.continent = rc2.continent
     AND rc4.ranking = rc2.ranking
WHERE rc4.ranking <=5 AND rc2.ranking <=5;


-- looking at data
SELECT continent, location, population,population_density, (total_death_num/ total_cases)*100 as percent_of_deaths, 
cardiovasc_death_rate, diabetes_prevalence,median_age, life_expectancy, human_development_index
FROM coviddeaths1_csv
WHERE `date` = '2020-12-31'
AND TRIM(human_development_index) != ''
AND continent ='Europe'
ORDER BY percent_of_deaths DESC;

SELECT continent, location, population,population_density, (total_death_num/ total_cases)*100 as percent_of_deaths, 
cardiovasc_death_rate, diabetes_prevalence,median_age, life_expectancy, human_development_index
FROM coviddeaths1_csv
WHERE `date` = '2020-12-31'
AND TRIM(human_development_index) != ''
AND continent ='Europe'
ORDER BY percent_of_deaths DESC;

SELECT continent, location, MAX(total_cases), MAX(total_death_num)/MAX(total_cases)*100 as percent_of_deaths
FROM coviddeaths1_csv
WHERE continent !='' 
GROUP BY continent, location
ORDER BY  percent_of_deaths DESC;

SELECT location, MAX(total_death_num)
FROM coviddeaths1_csv
GROUP BY location
ORDER BY MAX(total_death_num) desc
;

-- Number of cases each day

SELECT `date`, SUM(total_cases) 
FROM coviddeaths1_csv
WHERE total_cases IS NOT NULL  -- AND location ='Poland'
GROUP BY `date`
ORDER BY `date`;