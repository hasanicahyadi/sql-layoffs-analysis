/*
1. Membuat duplikat dari tabel layoffs bernama layoffs_staging. 
Tujuannya adalah agar proses data cleaning tidak dilakukan pada data mentah, sehingga data mentah tidak mengalami perubahan apapun.
*/
CREATE TABLE world_layoffs.layoffs_staging LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;


/*
2. Periksa apakah ada duplikat pada tabel
*/
-- Query untuk menomorkan setiap baris data. 
-- row_num > 1 menandakan baris data tersebut tidak unik dan merupakan duplikat dari baris data yang sudah ada.
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Periksa apakah ada data duplikat (row_num > 1) 
SELECT * FROM
	(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
	`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
	) AS duplicates
WHERE row_num > 1;

-- buat tabel baru bernama layoffs_staging2 yang berisi seluruh data pada tabel layoffs_staging dan menambahkan kolom row_num
-- MySQL -> world_layoffs -> layoffs_staging -> copy to clipboard -> create statement
CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

-- masukkan seluruh data dari layoffs_staging serta kolom yang berisi data query row_num
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- data duplikat adalah baris data dengan row_num > 1. Hapus seluruh data duplikat
DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;


/*
3. Standarisasi Data
*/
SELECT 
    *
FROM
    layoffs_staging2;

-- 3.1 standarisasi semua kolom dengan tipe data string (kecuali date)
UPDATE layoffs_staging2 
SET 
    company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    country = TRIM(country);

-- 3.2 standarisasi semua nilai kosong '' menjadi NULL
UPDATE layoffs_staging2 
SET 
    company = NULL
WHERE
    company = '';
UPDATE layoffs_staging2 
SET 
    location = NULL
WHERE
    location = '';
UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';
UPDATE layoffs_staging2 
SET 
    total_laid_off = NULL
WHERE
    total_laid_off = '';
UPDATE layoffs_staging2 
SET 
    percentage_laid_off = NULL
WHERE
    percentage_laid_off = '';
UPDATE layoffs_staging2 
SET 
    `date` = NULL
WHERE
    `date` = '';
UPDATE layoffs_staging2 
SET 
    stage = NULL
WHERE
    stage = '';
UPDATE layoffs_staging2 
SET 
    country = NULL
WHERE
    country = '';
UPDATE layoffs_staging2 
SET 
    funds_raised_millions = NULL
WHERE
    funds_raised_millions = '';


-- 3.3 standarisasi kolom industry. Kasus pertama adalah terdapat company dengan nama & lokasi yang sama namun kolom industry berbeda,
-- di mana salah satu baris tidak berisi data kolom industry. maka dari itu, dapat diasumsikan bahwa nilai kolom industry nya sama.
-- contoh: Airbnb SF Bay Area
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL;

UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;

-- 3.4 kasus kedua adalah terdapat jenis industry yang sama dengan penamaan berbeda, yaitu Crypto, CryptoCurrency, dan Crypto Currency.
-- periksa jumlah terbanyak dari setiap penamaan.
SELECT DISTINCT
    industry, COUNT(industry)
FROM
    layoffs_staging2
WHERE
    industry LIKE 'Crypto%'
GROUP BY industry;

-- penamaan Crypto yang terbanyak (99), maka penamaan lain akan disesuaikan menjadi Crypto
UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry IN ('CryptoCurrency' , 'Crypto Currency');

-- 3.5 kasus ketiga adalah pada kolom country, terdapat nama negara dengan akhiran titik, contohnya United States.
-- Disesuaikan dengan cara menghilangkan titik di akhir nama country
UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country);


-- 3.6 mengubah kolom date menjadi format TAHUN-BULAN-TANGGAL, lalu ubah tipe data kolom date dari text menjadi date
UPDATE layoffs_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

/*
4. Hapus baris dan kolom yang tidak relevan
*/
-- kolom row_num awalnya dibuat untuk membantu dalam identifikasi data duplikat. Karena seluruh data duplikat sudah dihapus,
-- maka kolom row_num sudah tidak diperlukan
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- baris data dengan nilai total_laid_off dan percentage_laid_off kosong (NULL) dianggap tidak relevan
DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- baris data tanpa date dianggap tidak relevan
DELETE FROM layoffs_staging2
WHERE
	`date` IS NULL;