USE NETFLIX_DB;
GO
CREATE TABLE NETFLIX_MAIN (
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	cast VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(20),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);
GO

SELECT * FROM NETFLIX_TITLES;
GO

SELECT COUNT(*) AS TOTAL_CONTENT FROM NETFLIX_TITLES;
GO

--1.--Count the no.of movies vs TV Shows?--

SELECT TYPE, COUNT(TYPE) AS TOTAL_COUNT FROM NETFLIX_TITLES
GROUP BY TYPE
ORDER BY TOTAL_COUNT DESC;
GO

--2.-- Find the most common ratings for movies and TV shows?--

WITH MOST_RATING AS(
	SELECT TYPE, RATING, COUNT(RATING) AS RATINGS_COUNT, RANK()
	OVER(PARTITION BY TYPE ORDER BY COUNT(RATING) DESC) AS RANK_NO
	FROM NETFLIX_TITLES
	GROUP BY TYPE,RATING
)
SELECT TYPE, RATING, RATINGS_COUNT, RANK_NO FROM MOST_RATING
WHERE RANK_NO<=5;
GO

--3.--List all the movies released in a specific year?--

SELECT * FROM NETFLIX_TITLES
WHERE TYPE= 'Movie' and RELEASE_YEAR = '2021';
GO

--4.--Find the top 5 countries with the most content on netflix?--

SELECT TOP 5 VALUE AS NEW_COUNTRY, COUNT(*) AS TOTAL_CONTENTS
FROM NETFLIX_TITLES
CROSS APPLY STRING_SPLIT(COUNTRY, ',')
GROUP BY VALUE
ORDER BY TOTAL_CONTENTS DESC;
GO

--5.--Identify the longest movie or TV show duration?--
--TV SHOW--
SELECT 
TITLE, MAX(CAST(SUBSTRING(DURATION, 1, CHARINDEX(' ', DURATION) -1)AS INT)) AS MAXIMUM_LENGTH,
RANK() OVER(ORDER BY MAX(CAST(SUBSTRING(DURATION,1, CHARINDEX(' ', DURATION) -1)AS INT)) DESC) AS RANK_NO
FROM netflix_titles
where TYPE='TV Show'
GROUP BY title;
GO

--MOVIE--
SELECT 
    title, 
    MAX(CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT)) AS maximum_length
FROM netflix_titles
WHERE type = 'Movie' 
AND duration IS NOT NULL
GROUP BY title
ORDER BY maximum_length DESC;
GO

--6.--Find the content added in the last 5 years?--

SELECT TITLE, RELEASE_YEAR FROM netflix_titles
WHERE release_year>= (SELECT MAX(RELEASE_YEAR)-5 FROM netflix_titles)
GROUP BY title, release_year
ORDER BY release_year DESC;
GO

--7.--Find all the movies/tv shows directed by 'Rajiv Chilaka'--

SELECT * FROM NETFLIX_TITLES
WHERE DIRECTOR= 'Rajiv Chilaka';
GO

--8.--List all TV shows more than 5 seasons--

SELECT TYPE, TITLE,
MAX(CAST(SUBSTRING(DURATION, 1, CHARINDEX(' ', duration)-1) AS INT)) AS SEASONS
FROM netflix_titles
WHERE TYPE='TV Show' AND 
CAST(SUBSTRING(DURATION, 1, CHARINDEX(' ', duration)-1) AS INT)>5
GROUP BY type, title
ORDER BY SEASONS DESC;
GO

--9.--Count the no. of content items in each genre?--

SELECT VALUE AS GENRE, COUNT(*) AS COUNT_OF_GENRE FROM netflix_titles
CROSS APPLY string_split(listed_in,',')
GROUP BY value
ORDER BY COUNT_OF_GENRE DESC;
GO

--10.--Find the Average release year for content produced in a specific country--

SELECT TRIM(VALUE) AS NEW_COUNTRY, AVG(RELEASE_YEAR) AS AVG_RELEASE_YEAR
FROM netflix_titles 
CROSS APPLY string_split(country, ',')
GROUP BY show_id,TITLE,TRIM(value)
ORDER BY AVG(RELEASE_YEAR) DESC;
GO

--11.--List all movies that are documentaries--

SELECT TYPE,TITLE, VALUE AS GENRE FROM netflix_titles
CROSS APPLY string_split(listed_in,',')
WHERE TYPE='Movie' and listed_in= 'Documentaries'
GROUP BY value, TYPE, title;
GO

--12.--Find each year and the average numbers of content release by india on netflix--
--return top 5 year with highest avg content release--
--BASED ON DATE_ADDED
SELECT YEAR(PARSE(DATE_ADDED AS DATE USING 'en-US')) AS NEW_YEAR,
COUNT(*) AS TOTAL_CONTENT FROM NETFLIX_TITLES
WHERE country='India'
GROUP BY YEAR(PARSE(DATE_ADDED AS DATE USING 'en-US'))
ORDER BY TOTAL_CONTENT DESC;
GO

--13.--Find all the content without a director--

SELECT * FROM netflix_titles
WHERE director IS NULL;
GO

--14.--Find how many movies actor salman khan appeared in the last 10 years--

SELECT TYPE, title, CAST, release_year FROM netflix_titles
WHERE TYPE='Movie' and CAST LIKE '%Salman Khan%' AND
release_year>=(SELECT MAX(release_year)-10 FROM netflix_titles)
GROUP BY TYPE, title, CAST, release_year
ORDER BY release_year DESC;
GO

--15.--Find the top 10 actors who appear in MOVIES produced in India--
WITH TOP_ACTORS AS(
	SELECT VALUE AS cast, COUNT(*) AS COUNT_OF_FILMS,
	DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS RANK_NO FROM netflix_titles
	CROSS APPLY string_split(cast, ',')
	WHERE country LIKE '%India%' AND TYPE='Movie'
	GROUP BY value
	)
SELECT * FROM TOP_ACTORS
WHERE RANK_NO<=10;
GO

--16.--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in the 
--description field. label content containing these keywords as 'Bad' and all other content 
--as 'Good'. count how many items fall into each category

WITH STATUS AS( 
	SELECT type, title, description, 
	CASE WHEN description LIKE '%Kill%' OR description LIKE '%Violence%' THEN 'BAD'
	ELSE 'GOOD' END AS MOVIE_STATUS
	FROM netflix_titles
	)
SELECT * FROM STATUS;
GO