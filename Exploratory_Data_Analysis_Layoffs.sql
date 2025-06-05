-- rentang data layoffs dimulai dari Maret 2020 s.d. Maret 2023 (3 tahun)

-- 1. APA YANG TERJADI?
SELECT SUM(total_laid_off) FROM layoffs_staging2; -- 385,879 karyawan
SELECT COUNT(DISTINCT company) FROM layoffs_staging2; -- 1627 perusahaan
SELECT MIN(`date`), MAX(`date`) FROM layoffs_staging2; -- Maret 2020 s.d. Maret 2023
-- Dalam rentang Maret 2020 s.d. Maret 2023, terdapat total 385,879 karyawan dari 1627 perusahaan yang berbeda mengalami layoff 

/*
2. PERUSAHAAN APA YANG MELAKUKAN LAYOFF TERBESAR?
Dalam rentang 3 tahun, perusahaan dengan total layoff tertinggi berturut-turut adalah 
Amazon, Google, Meta  , Salesforce, dan Microsoft, dengan total layoff sebesar 
18,150, 12,000, 11,000, 10,090    , 10,000
*/
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	company, industry,
    SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2 GROUP BY company, industry
	LIMIT 5;

-- Maret 2020 s.d. Maret 2021, perusahaan dengan total layoff terbanyak secara berturut-turut adalah
-- Uber, Booking.com, Groupon, Swiggy, dan Airbnb
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	company, industry,
    SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2 
    WHERE `date` BETWEEN '2020-03-01' AND '2021-03-01'
    GROUP BY company, industry
	LIMIT 5;
    
-- Maret 2021 s.d. Maret 2022, perusahaan dengan total layoff terbanyak secara berturut-turut adalah
-- Peloton, Katerra, Zillow, Bytedance, dan Better.com
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	company, industry,
    SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2 
	WHERE `date` BETWEEN '2021-03-01' AND '2022-03-01'
	GROUP BY company, industry
	LIMIT 5;

-- Maret 2022 s.d. Maret 2023, perusahaan dengan total layoff terbanyak secara berturut-turut adalah
-- Amazon, Google, Meta, Microsoft, dan Phillips
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	company, industry,
    SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2 
	WHERE `date` BETWEEN '2022-03-01' AND '2023-03-01'
	GROUP BY company, industry
	LIMIT 5;


/*
3. INDUSTRY APA YANG MELAKUKAN LAYOFF TERBESAR?
Dalam rentang 3 tahun, industry dengan total layoff tertinggi berturut-turut adalah 
Consumer, Retail, Other , Transportation, dan Finance, dengan total layoff sebesar
47,082  , 43,613, 35,789, 34,498        , dan 28344
*/
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	industry, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
    GROUP BY industry
    LIMIT 5;

-- Maret 2020 s.d. Maret 2021, industry dengan total layoff paling besar secara berturut-turut adalah
-- Transportation, Travel, Retail, Finance, dan Food
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	industry, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
	WHERE `date` BETWEEN '2020-03-01' AND '2021-03-01'
    GROUP BY industry
    LIMIT 5;

-- Maret 2021 s.d. Maret 2022, industry dengan total layoff paling besar secara berturut-turut adalah
-- Real Estate, Fitness, Construction, Consumer, dan Food
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	industry, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
	WHERE `date` BETWEEN '2021-03-01' AND '2022-03-01'
    GROUP BY industry
    LIMIT 5;

-- Maret 2022 s.d. Maret 2023, industry dengan total layoff paling besar secara berturut-turut adalah
-- Consumer, Other, Retail, Healthcare, dan Transportation
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	industry, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
	WHERE `date` BETWEEN '2022-03-01' AND '2023-03-01'
    GROUP BY industry
    LIMIT 5;


/* 
TOTAL LAYOFF BERDASARKAN NEGARA
dalam rentang 3 tahun, negara dengan total layoff terbanyak secara berturut-turut adalah 
United States, India , Netherlands, Sweden, dan Brazil, dengan jumlah sebesar
257,659	     , 35,993, 17,220     , 11,264, dan 10,691
*/
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	country, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
    GROUP BY country
    LIMIT 5;

-- Maret 2020 s.d. Maret 2021, negara dengan total layoff terbanyak adalah United States, India, Netherlands, Brazil, dan Singapore
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	country, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
	WHERE `date` BETWEEN '2020-03-01' AND '2021-03-01'
    GROUP BY country
    LIMIT 5;
    
-- Maret 2021 s.d. Maret 2022, negara dengan total layoff terbanyak adalah United States, China, Germany, India, dan Sweden
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	country, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
	WHERE `date` BETWEEN '2021-03-01' AND '2022-03-01'
    GROUP BY country
    LIMIT 5;

-- Maret 2022 s.d. Maret 2023, negara dengan total layoff terbanyak adalah United States, India, Netherlands, Sweden, dan Germany
SELECT RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking,
	country, SUM(total_laid_off) AS total_layoff
	FROM layoffs_staging2
	WHERE `date` BETWEEN '2022-03-01' AND '2023-03-01'
    GROUP BY country
    LIMIT 5;

/*
Bagaimana hubungan tahap (stage) terhadap layoff?

Rata-rata persentase laid off tertinggi terdapat pada stage Seed, yaitu 0.7.
Rata-rata persentase laid off pada stage Post-IPO adalah 0.16.

persentase laid off = 1 (100%) artinya perusahaan bangkrut.
Pada dataset, terdapat 116 perusahaan yang bangkrut.
23 dari perusahaan tersebut ada dalam stage seed, sedangkan 3 perusahaan tersebut ada dalam stage Post-IPO.
*/
SELECT stage, ROUND(AVG(percentage_laid_off),2) AS avg_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT stage, COUNT(stage) FROM layoffs_staging2 WHERE percentage_laid_off =1 GROUP BY stage ORDER BY 2 DESC;



-- total laid off berdasarkan perusahaan dan tahun.
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;




-- rolling total layoff berdasarkan bulan dan tahun
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;


