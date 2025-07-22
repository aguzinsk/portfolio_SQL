-- 1. Creat copy of RAW data
-- 2. Remove duplicats
-- 3. Standardize the data
-- 4. Null Values or blank
-- 5. Remove any Columns


-- 1. Creat copy of RAW data
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 2. Remove duplicats

SELECT *,
ROW_number() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS ROW_NUM
FROM layoffs_staging;

WITH duplicate_cte AS
(SELECT *,
ROW_number() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS ROW_NUM
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- Check if the company was truly a duplicated. Find out they were not, so statement for finding duplicates have to be improved
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';

SELECT *
FROM layoffs_staging;

WITH duplicate_cte2 AS
(SELECT *,
ROW_number() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS ROW_NUM
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte2
WHERE row_num >1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- I had to create new table to be able to delete duplicate rows

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_number() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS ROW_NUM
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE
FROM layoffs_staging2
WHERE row_num >1;

-- deleting column which was needed only for duplicate identification

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- 3. Standardize the data

SELECT  company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT location 
FROM layoffs_staging2
ORDER BY location;

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROm layoffs_staging2
WHERE country LIKE 'United States.';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

# SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
# FROM layoffs_staging2
#ORDER BY 1;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- 4. Null Values or blank

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2 t1
WHERE (t1.industry IS NULL OR t1.industry = '')
AND EXISTS (SELECT 1
            FROM layoffs_staging2 t2
            WHERE t1.company = t2.company
            AND t1.location = t2.location
            AND t2.industry IS NOT NULL
            AND t2.industry != '' -- Added when empty strings also mean "none"
           );
           
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

-- blank values(?) were make problems so I change it into null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
from layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- 5. Remove Columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
