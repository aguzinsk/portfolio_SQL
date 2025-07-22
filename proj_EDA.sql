SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off desc;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;


-- CREATE TABLE IN WHICH MONTH THE MOST PEOPLE GET FIRED

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off) as total
FROM layoffs_staging2
WHERE SUBSTRING(`date`,6,2) IS NOT NULL
AND SUBSTRING(`date`,1,4) != 2023
GROUP BY `MONTH`
ORDER BY total desc;


-- I couldn't add two different totals in one line so i had to prepare CTE for 
-- SUM of total laid off then I could use window function to create SUM of SUM total laid off
WITH Rolling AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH` 
ORDER BY `MONTH` DESC  
)
SELECT `MONTH`,total_off, SUM(total_off) OVER(ORDER BY `MONTH`)
FROM Rolling;

-- RANKING 

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;


WITH Company_Year (company, `year`, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, dense_rank() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) as ranking
FROM Company_Year
WHERE `year` IS NOT NULL
ORDER BY ranking;

WITH Company_Year (company, `year`, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Ranking AS
(
SELECT *, dense_rank() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) as ranking
FROM Company_Year
WHERE `year` IS NOT NULL
)
SELECT *
FROM Company_Year_Ranking
WHERE ranking <=10;

-- Country - TOP  10 companies from each country which fired the most people in 4 years

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

WITH company_total_off (company, country, total_laid_off) AS
(
SELECT company, country, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT null
GROUP BY company, country
ORDER BY country
), country_ranking AS
(
SELECT *, dense_rank() OVER (PARTITION BY country ORDER BY total_laid_off DESC) AS ranking
FROM company_total_off
)
SELECT *
FROM country_ranking
WHERE ranking <=5
;

-- TOP 5 industries with the most laid offs


SELECT industry, SUM(total_laid_off), dense_rank() OVER(ORDER BY SUM(total_laid_off) DESC)
FROM layoffs_staging2
WHERE industry is not null
GROUP BY industry;