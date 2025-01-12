# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows
```sql
SELECT TYPE, COUNT(TYPE) AS TOTAL_COUNT FROM NETFLIX_TITLES
GROUP BY TYPE
ORDER BY TOTAL_COUNT DESC;
GO
```
### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH MOST_RATING AS(
	SELECT TYPE, RATING, COUNT(RATING) AS RATINGS_COUNT, RANK()
	OVER(PARTITION BY TYPE ORDER BY COUNT(RATING) DESC) AS RANK_NO
	FROM NETFLIX_TITLES
	GROUP BY TYPE,RATING
)
SELECT TYPE, RATING, RATINGS_COUNT, RANK_NO FROM MOST_RATING
WHERE RANK_NO<=5;
GO
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM NETFLIX_TITLES
WHERE TYPE= 'Movie' and RELEASE_YEAR = '2021';
GO
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5 VALUE AS NEW_COUNTRY, COUNT(*) AS TOTAL_CONTENTS
FROM NETFLIX_TITLES
CROSS APPLY STRING_SPLIT(COUNTRY, ',')
GROUP BY VALUE
ORDER BY TOTAL_CONTENTS DESC;
GO
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the longest movie 

```sql
SELECT 
    title, 
    MAX(CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT)) AS maximum_length
FROM netflix_titles
WHERE type = 'Movie' 
AND duration IS NOT NULL
GROUP BY title
ORDER BY maximum_length DESC;
GO
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT TITLE, RELEASE_YEAR FROM netflix_titles
WHERE release_year>= (SELECT MAX(RELEASE_YEAR)-5 FROM netflix_titles)
GROUP BY title, release_year
ORDER BY release_year DESC;
GO
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM NETFLIX_TITLES
WHERE DIRECTOR= 'Rajiv Chilaka';
GO
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT TYPE, TITLE,
MAX(CAST(SUBSTRING(DURATION, 1, CHARINDEX(' ', duration)-1) AS INT)) AS SEASONS
FROM netflix_titles
WHERE TYPE='TV Show' AND 
CAST(SUBSTRING(DURATION, 1, CHARINDEX(' ', duration)-1) AS INT)>5
GROUP BY type, title
ORDER BY SEASONS DESC;
GO
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT VALUE AS GENRE, COUNT(*) AS COUNT_OF_GENRE FROM netflix_titles
CROSS APPLY string_split(listed_in,',')
GROUP BY value
ORDER BY COUNT_OF_GENRE DESC;
GO
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT TOP 5 YEAR(PARSE(DATE_ADDED AS DATE USING 'en-US')) AS NEW_YEAR,
COUNT(*) AS TOTAL_CONTENT FROM NETFLIX_TITLES
WHERE country='India'
GROUP BY YEAR(PARSE(DATE_ADDED AS DATE USING 'en-US'))
ORDER BY TOTAL_CONTENT DESC;
GO
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT TYPE,TITLE, VALUE AS GENRE FROM netflix_titles
CROSS APPLY string_split(listed_in,',')
WHERE TYPE='Movie' and listed_in= 'Documentaries'
GROUP BY value, TYPE, title;
GO
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix_titles
WHERE director IS NULL;
GO
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT TYPE, title, CAST, release_year FROM netflix_titles
WHERE TYPE='Movie' and CAST LIKE '%Salman Khan%' AND
release_year>=(SELECT MAX(release_year)-10 FROM netflix_titles)
GROUP BY TYPE, title, CAST, release_year
ORDER BY release_year DESC;
GO
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH STATUS AS( 
	SELECT type, title, description, 
	CASE WHEN description LIKE '%Kill%' OR description LIKE '%Violence%' THEN 'BAD'
	ELSE 'GOOD' END AS MOVIE_STATUS
	FROM netflix_titles
	)
SELECT * FROM STATUS;
GO
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
