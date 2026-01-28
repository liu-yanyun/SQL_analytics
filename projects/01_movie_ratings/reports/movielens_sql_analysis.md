# movielens_sql_analysis.md 

## 1. Introduction

This report presents an exploratory SQL analysis of the MovieLens dataset.
The goal is to demonstrate how SQL can be used to answer practical, real-world questions about movie popularity, user behaviour, and engagement patterns from relational data.

## 2. Dataset

The analysis uses the MovieLens “ml-latest-small” dataset provided by GroupLens.
It contains information on movies, user ratings, and user-generated tags.

- Tables used: movies, ratings, tags
- Number of movies: 9742
- Number of users: 610
- Number of ratings: 100836
- Number of tags: 3683

## 3. Analysis & Key Questions

### **3.1 Dataset Sanity & Context**
Q1. What years do the movies span?

**Why this matters**
Understanding the time range of the dataset provides context for interpreting popularity, rating behaviour, and trends over time.

```sql
SELECT
  MIN(year) AS earliest_year,
  MAX(year) AS latest_year
FROM (
  SELECT
    CAST(substr(title, instr(title, '(') + 1, 4) AS INTEGER) AS year
  FROM movies
  WHERE instr(title, '(') > 0
)
WHERE year BETWEEN 1880 AND 2100;
```

Result:

| earliest_year	| latest_year |
|---------------|-------------|
| 1903 | 2018 |

Interpretation:
The movies in this dataset span from 1903 up until 2018.

### **3.2 Movie Popularity & Rating Quality**
Q2. Which movies are most popular (by number of ratings)?

**Why this matters**
Popularity reflects overall visibility and user engagement, which is often a key metric for content platforms.

```sql
SELECT 
  m.title,
  COUNT(r.rating) AS n_ratings 
FROM movies m
JOIN ratings r
  ON m.movieId = r.movieId
GROUP BY m.movieId
ORDER BY n_ratings DESC
LIMIT 10;
```

Result:

| title | n_ratings |
|-------|-----------|
| Forrest Gump (1994) | 329 |
| The Shawshank Redemption (1994) | 317 |
| Pulp Fiction (1994) | 307 |
| The Silence of the Lambs (1991) | 279 |
| The Matrix (1999) | 278 |
| Star Wars: Episode IV – A New Hope (1977) | 251 |
| Jurassic Park (1993) | 238 |
| Braveheart (1995) | 237 |
| Terminator 2: Judgment Day (1991) | 224 |
| Schindler's List (1993) | 220 |

Interpretation:
These 10 classic movies from the early 90s are the top 10 most popular ones (not surprising!).

Q3. Which movies are the highest rated (with at least 50 ratings)?

**Why this matters**
Filtering out movies with very few ratings improves reliability and avoids misleading averages.

```sql
SELECT 
  m.title,
  ROUND(AVG(r.rating),2) AS avg_rating,
  COUNT(*) AS n_ratings
FROM movies AS m
JOIN ratings AS r
  ON m.movieId = r.movieId
GROUP BY m.movieId
HAVING COUNT(*) >= 50
ORDER BY avg_rating DESC
LIMIT 10;
```

Result:

| title | avg_rating | n_ratings |
|-------|------------|-----------|
| The Shawshank Redemption (1994) | 4.43 | 317 |
| The Godfather (1972) | 4.29 | 192 |
| Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb (1964) | 4.27 | 97 |
| Fight Club (1999) | 4.27 | 218 |
| Cool Hand Luke (1967) | 4.27 | 57 |
| Rear Window (1954) | 4.26 | 84 |
| The Godfather: Part II (1974) | 4.26 | 129 |
| The Departed (2006) | 4.25 | 107 |
| Goodfellas (1990) | 4.25 | 126 |
| Casablanca (1942) | 4.24 | 100 |



Q4. Is there a relationship between popularity (number of ratings) and quality (average rating)?

**Why this matters**
This helps determine whether highly rated movies are also widely watched, or whether high-quality content can remain niche.

```sql
SELECT
  m.title,
  COUNT(r.rating) AS num_ratings,
  ROUND(AVG(r.rating), 2) AS avg_rating
FROM movies m
JOIN ratings r
  ON m.movieId = r.movieId
GROUP BY m.movieId
HAVING COUNT(r.rating) >= 30
ORDER BY num_ratings DESC
LIMIT 10;
```

Result:

| title | num_ratings | avg_rating |
|-------|-------------|------------|
| Forrest Gump (1994) | 329 | 4.16 |
| The Shawshank Redemption (1994) | 317 | 4.43 |
| Pulp Fiction (1994) | 307 | 4.20 |
| The Silence of the Lambs (1991) | 279 | 4.16 |
| The Matrix (1999) | 278 | 4.19 |
| Star Wars: Episode IV – A New Hope (1977) | 251 | 4.23 |
| Jurassic Park (1993) | 238 | 3.75 |
| Braveheart (1995) | 237 | 4.03 |
| Terminator 2: Judgment Day (1991) | 224 | 3.97 |
| Schindler's List (1993) | 220 | 4.22 |

Interpretation:

Movies that are more popular (with a higher number of ratings) tend to have higher average ratings, but the most popular movies are not always the highest rated. They are related, but not strongly correlated.

### **3.3 User Behaviour & Engagement**
Q5. Who are the most active users in terms of ratings submitted?

**Why this matters**
Identifying highly active users helps understand contribution patterns and engagement distribution within the platform.

```sql
SELECT 
  userId,
  COUNT(*)AS num_ratings_submitted
FROM ratings
GROUP BY userId
ORDER BY COUNT(*) DESC
LIMIT 10;  -- top 10
```

Result:

| userId | num_ratings_submitted |
|--------|-----------------------|
| 414 | 2698 |
| 599 | 2478 |
| 474 | 2108 |
| 448 | 1864 |
| 274 | 1346 |
| 610 | 1302 |
| 68 | 1260 |
| 380 | 1218 |
| 606 | 1115 |
| 288 | 1055 |

### **3.4 Tags & User-Generated Metadata**
Q6. How many movies receive user-generated tags?

**Why this matters**
Tags represent deeper user engagement beyond ratings and can highlight movies that stimulate discussion or commentary.

```sql
SELECT 
  m.title, 
  COUNT(t.tag) AS total_tags,
  COUNT(DISTINCT t.tag) AS unique_tags
FROM movies AS m
JOIN tags AS t
  ON m.movieId=t.movieId
GROUP BY m.movieId
ORDER BY total_tags DESC
LIMIT 5;
```

Result:

| title | total_tags | unique_tags |
|-------|------------|-------------|
| Pulp Fiction (1994) | 181 | 173 |
| Fight Club (1999) | 54 | 48 |
| 2001: A Space Odyssey (1968) | 41 | 40 |
| Léon: The Professional (1994) | 35 | 32 |
| Eternal Sunshine of the Spotless Mind (2004) | 34 | 31 |


### **3.5 Recommendation-Oriented Patterns (Advanced)**

This section explores more advanced relational patterns commonly used in recommendation systems.

Q7. Which users have rated the same movies as a given user?

**Why this matters**
Identifying users with overlapping preferences forms the basis of user-similarity analysis and collaborative filtering.

*Note*: we use userId = 2 as the given user in this case.

```sql
SELECT 
  r2.userId,
  COUNT(DISTINCT r2.movieId) AS num_shared_movies
FROM
  (
  SELECT 
  movieId
  FROM ratings 
  WHERE userId = 2
  ) AS r1
  JOIN ratings AS r2
    ON r1.movieId = r2.movieId
WHERE r2.userId <> 2
GROUP BY r2.userId
ORDER BY num_shared_movies DESC
LIMIT 10;
```

Result:

| userId | num_shared_movies |
|--------|-------------------|
| 599 | 22 |
| 448 | 22 |
| 414 | 22 |
| 298 | 21 |
| 68 | 20 |
| 249 | 20 |
| 18 | 20 |
| 105 | 20 |
| 62 | 19 |
| 610 | 18 |


Q8. Which movies are frequently co-rated by the same users?

**Why this matters**
Movies that are often rated together can indicate natural content bundles or hidden associations useful for recommendations.

```sql
SELECT 
  m1.title AS movie_1,
  m2.title AS movie_2,
  COUNT(DISTINCT r1.userId) AS num_users_co_rated
FROM ratings AS r1
JOIN ratings AS r2
  ON r1.userId = r2.userId
  AND r1.movieId < r2.movieId
JOIN movies AS m1
  ON r1.movieId = m1.movieId
JOIN movies AS m2
  ON r2.movieId = m2.movieId
GROUP BY 
  r1.movieId, 
  r2.movieId
ORDER BY num_users_co_rated DESC
LIMIT 10;
```

Result:

| movie_1 | movie_2 | num_users_co_rated |
|---------|---------|-------------------|
| The Shawshank Redemption (1994) | Forrest Gump (1994) | 231 |
| Pulp Fiction (1994) | Forrest Gump (1994) | 230 |
| Pulp Fiction (1994) | The Shawshank Redemption (1994) | 222 |
| Pulp Fiction (1994) | The Silence of the Lambs (1991) | 207 |
| The Shawshank Redemption (1994) | The Silence of the Lambs (1991) | 199 |
| Forrest Gump (1994) | The Silence of the Lambs (1991) | 199 |
| Forrest Gump (1994) | Jurassic Park (1993) | 198 |
| The Matrix (1999) | Forrest Gump (1994) | 194 |
| Star Wars: Episode V – The Empire Strikes Back (1980) | Star Wars: Episode IV – A New Hope (1977) | 190 |
| Braveheart (1995) | Forrest Gump (1994) | 183 |

Q9. Are movies that receive many tags also the ones that receive many ratings?

**Why this matters**
This analysis determines whether tag frequency reflects film popularity (rating volume) or provides independent descriptive information that can enhance recommendation and discovery.

``` sql
SELECT 
  COUNT(*)*1.0/(SELECT COUNT(DISTINCT userId) FROM ratings) AS proportion_of_users_rate_many
FROM (
  SELECT userId
  FROM ratings 
  GROUP BY userId
  HAVING COUNT(*) >= 50 -- assume 50 movies is "many"
);
```

Result:

| title | num_tags | num_ratings |
|-------|----------|-------------|
| Pulp Fiction (1994) | 181 | 307 |
| Fight Club (1999) | 54 | 218 |
| 2001: A Space Odyssey (1968) | 41 | 109 |
| Léon: The Professional (1994) | 35 | 133 |
| Eternal Sunshine of the Spotless Mind (2004) | 34 | 131 |
| The Big Lebowski (1998) | 32 | 106 |
| Donnie Darko (2001) | 29 | 109 |
| Star Wars: Episode IV – A New Hope (1977) | 26 | 251 |
| Inception (2010) | 26 | 143 |
| Suicide Squad (2016) | 19 | 12 |

Interpretation:

Movies that receive more tags tend to have more ratings, but some movies with many ratings do not necessarily have many tags, which might be due to the nature of the movies.


## 4. Future Work

There is a series of questions that were identified as potential extensions but were not fully explored in this analysis, and they will be continued in a later time.


## 5. Conclusion

This analysis demonstrates how SQL can be used to extract meaningful insights from relational data, ranging from basic dataset exploration to more advanced co-rating and user behaviour analyses. The results highlight patterns in movie popularity, user engagement, and rating behaviour that are directly relevant to real-world data analysis tasks.
