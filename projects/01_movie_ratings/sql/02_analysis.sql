-- ======================================================
-- SECTION 1 — Dataset Overview & Sanity Checks
-- ======================================================

-- Q1. Dataset preview
SELECT * FROM movies LIMIT 5;
SELECT * FROM links LIMIT 5;
SELECT * FROM tags LIMIT 5;
SELECT * FROM ratings LIMIT 5;

-- Q2. Dataset size (movies, users, ratings, tags)
SELECT
  (SELECT COUNT(*) FROM movies)  AS num_movies,
  (SELECT COUNT(*) FROM ratings) AS num_ratings,
  (SELECT COUNT(DISTINCT userId) FROM ratings) AS num_users,
  (SELECT COUNT(*) FROM tags) AS num_tags;

-- Q3. What years do the movies span?
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

-- ======================================================
-- SECTION 2 — Movie Popularity & Rating Quality
-- ======================================================

-- Q4. Which movies are most popular (by number of ratings)?
SELECT 
  m.title,
  COUNT(r.rating) AS n_ratings 
FROM movies m
JOIN ratings r
  ON m.movieId = r.movieId
GROUP BY m.movieId
ORDER BY n_ratings DESC
LIMIT 10;

-- Q5. Which movies are the highest rated (with at least 50 ratings)?
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

-- Q6. How many ratings does a typical movie receive?
SELECT AVG(n_ratings) AS avg_ratings
FROM (
  SELECT movieId, COUNT(rating) AS n_ratings
  FROM ratings
  GROUP BY movieId
);

-- Q7. Q4. Is there a relationship between popularity (number of ratings) and quality (average rating)??
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


-- ======================================================
-- SECTION 3 — User Behaviour & Engagement
-- ======================================================

-- Q8. Who are the most active users in terms of number of ratings submitted?
SELECT 
  userId,
  COUNT(*)AS num_ratings_submitted
FROM ratings
GROUP BY userId
ORDER BY COUNT(*) DESC
LIMIT 10;  -- top 10

-- Q9. What proportion of users rate many movies versus only a few?
SELECT 
  COUNT(*)*1.0/(SELECT COUNT(DISTINCT userId) FROM ratings) AS proportion_of_users_rate_many
FROM (
  SELECT userId
  FROM ratings 
  GROUP BY userId
  HAVING COUNT(*) >= 50 -- assume 50 movies is "many"
);


-- Q8. What movies have ratings but no tags?
SELECT DISTINCT
  m.title AS moveis_have_ratings_no_tags
FROM movies AS m
JOIN ratings AS r
  ON m.movieId = r.movieId
LEFT JOIN tags t
  ON m.movieId = t.movieId
WHERE t.tag ISNULL;

-- ======================================================
-- SECTION 4 — Tags & Metadata Usage
-- ======================================================

-- Q10. How many movies have at least one tag?
SELECT
  COUNT(DISTINCT movieId) AS num_movies_with_tags
FROM tags;

-- Q11. Which movies receive the most tags?
-- practical use:
-- which movies generate the most user engagement
-- which titles attract discussion / commentary
-- candidates for featured content or recommendations
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

-- Q12. What are the most commonly used tags overall?
SELECT 
  tag, 
  COUNT(*) num_times_used,
  COUNT(DISTINCT userId) AS num_users
FROM tags
GROUP BY tag
ORDER BY num_times_used DESC;

-- Q13. Are there movies that are frequently rated but never tagged?
SELECT 
  m.title, 
  COUNT(*) AS n_ratings
FROM movies AS m
JOIN ratings AS r
ON m.movieId = r.movieId
LEFT JOIN tags AS t
  ON r.movieId = t.movieId
WHERE t.tag ISNULL
GROUP BY m.movieId
HAVING COUNT(r.rating) >= 100; -- 100 ratings is considered as frequency threshold

-- ======================================================
-- SECTION 5 — Co-rating & Similarity (Advanced)
-- ======================================================

-- Q14. Which users have rated the same movies as a given user?
-- Recommendation systems: “Users similar to you also liked…”
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

-- Q15. Which user pairs have the most movies in common?
-- User similarity
-- Collaborative filtering logic
-- Finding clusters of similar behaviour
SELECT 
  r1.userId AS user_1, 
  r2.userId AS user_2,
  COUNT(DISTINCT r1.movieId) AS num_shared_movies
FROM ratings AS r1
JOIN ratings AS r2
  ON r1.movieId = r2.movieId
  AND r1.userId < r2.userId
GROUP BY 
  r1.userId,
  r2.userId
ORDER BY num_shared_movies DESC
LIMIT 10;

-- Q16. Which movies are frequently co-rated by the same users?
-- Bundle recommendations
-- Discover hidden associations

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

-- ======================================================
-- SECTION 6 — Time-based Trends
-- ======================================================

-- Q17. How has the number of ratings changed over time (e.g. by year)?
SELECT 
  strftime('%Y',timestamp,'unixepoch') AS year,
  COUNT(*) AS num_ratings
FROM ratings
GROUP BY year
ORDER BY year;

-- Q18. Which years had the highest average ratings?
SELECT 
  strftime('%Y', timestamp, 'unixepoch') AS year,
  ROUND(AVG(rating), 2) AS avg_rating,
  COUNT(*) AS num_ratings
FROM ratings
GROUP BY year
ORDER BY avg_rating DESC;

-- ======================================================
-- SECTION 7 — Rating Reliability & Edge Cases
-- ======================================================

-- Q19. How many movies have only a single rating?
SELECT COUNT(movieId) AS total_num_of_movies_with_1_rating
FROM (
  SELECT 
    movieId,
    COUNT(rating) AS n_ratings
  FROM ratings
  GROUP BY movieId
  HAVING n_ratings = 1
);

-- Q20. How does the number of “top-rated” movies change with different threshold?
SELECT COUNT(movieId) AS total_num_of_movies_with_1_rating
FROM (
  SELECT 
    movieId,
    COUNT(rating) AS n_ratings
  FROM ratings
  GROUP BY movieId
  HAVING n_ratings >= 10
);

SELECT COUNT(movieId) AS total_num_of_movies_with_1_rating
FROM (
  SELECT 
    movieId,
    COUNT(rating) AS n_ratings
  FROM ratings
  GROUP BY movieId
  HAVING n_ratings >= 50
);

SELECT COUNT(movieId) AS total_num_of_movies_with_1_rating
FROM (
  SELECT 
    movieId,
    COUNT(rating) AS n_ratings
  FROM ratings
  GROUP BY movieId
  HAVING n_ratings >= 200
);

-- ======================================================
-- SECTION 8 — Combined insights
-- ======================================================

-- Q21. Is there a relationship between popularity (number of ratings) and quality (average rating)?
SELECT
  m.title,
  COUNT(*) AS num_of_ratings,
  ROUND(AVG(r.rating),2) AS avg_rating
FROM
  movies AS m
JOIN ratings AS r
  ON m.movieId = r.movieId
GROUP BY m.movieId
HAVING num_of_ratings >= 10
ORDER BY num_of_ratings DESC;

-- Q22. Are movies that receive many tags also the ones that receive many ratings?
SELECT 
  m.title,
  t.num_tags,
  r.num_ratings
FROM movies AS m
LEFT JOIN (
  SELECT 
    movieId,
    COUNT(*) AS num_tags
  FROM tags
  GROUP BY movieId
) AS t
  ON m.movieId = t.movieId
LEFT JOIN (
  SELECT 
    movieId,
    COUNT(*) AS num_ratings
  FROM ratings
  GROUP BY movieId
) AS r
  ON t.movieId = r.movieId
ORDER BY t.num_tags DESC
LIMIT 10;

-- ======================================================
-- SECTION 9 — Open Questions & Future Work
-- ======================================================

-- Q23. Do certain genres tend to receive higher ratings on average?
SELECT 
  m.genres,
  AVG(r.rating) AS avg_rating
FROM movies AS m
JOIN ratings AS r
  ON m.movieId = r.movieId
GROUP BY m.genres
ORDER BY avg_rating DESC;

WITH RECURSIVE split_genres AS (
  -- base case: take the first genre
  SELECT
    movieId,
    substr(genres, 1, instr(genres || '|', '|') - 1) AS genre,
    substr(genres || '|', instr(genres || '|', '|') + 1) AS rest
  FROM movies

  UNION ALL

  -- recursive step: keep splitting the rest
  SELECT
    movieId,
    substr(rest, 1, instr(rest, '|') - 1) AS genre,
    substr(rest, instr(rest, '|') + 1) AS rest
  FROM split_genres
  WHERE rest <> ''
)
SELECT movieId, genre
FROM split_genres;

WITH RECURSIVE split_genres AS (
  SELECT
    movieId,
    substr(genres, 1, instr(genres || '|', '|') - 1) AS genre,
    substr(genres || '|', instr(genres || '|', '|') + 1) AS rest
  FROM movies

  UNION ALL

  SELECT
    movieId,
    substr(rest, 1, instr(rest, '|') - 1) AS genre,
    substr(rest, instr(rest, '|') + 1) AS rest
  FROM split_genres
  WHERE rest <> ''
)
SELECT
  sg.genre,
  ROUND(AVG(r.rating), 2) AS avg_rating,
  COUNT(*) AS num_ratings
FROM split_genres sg
JOIN ratings r
  ON sg.movieId = r.movieId
GROUP BY sg.genre
HAVING COUNT(*) >= 100
ORDER BY avg_rating DESC;

-- Are there movies that appear in the catalogue but have never been rated?
-- Do highly active users rate movies differently from less active users?
-- Do users who tag movies rate more than average users?
-- Which users tend to rate movies much higher or lower than others?
-- Detect harsh vs generous raters
-- Normalising ratings in recommender systems
-- Which movies receive very different ratings from different users?
-- Polarising movies
-- Risky recommendation
-- Which users have similar average ratings across the same set of movies?
-- Taste similarity
-- Peer grouping
-- Are there users who always rate higher than another specific user?
-- Rating bias detection
-- Personalisation calibration
-- Which movies tend to be rated later than others by the same users?
-- Engagement patterns
-- Watch-order analysis
-- Are users becoming more positive or more critical over time? 
-- Are there years with unusually high or low rating activity?
-- Do movies with tags tend to receive higher ratings than movies without tags?
-- Do users who add tags rate movies differently from users who never tag?
-- Are highly rated movies more likely to be tagged?
-- Are some genres more likely to be tagged by users?
-- Do highly rated movies attract more user engagement overall?
