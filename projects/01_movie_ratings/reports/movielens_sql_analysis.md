# movielens_sql_analysis.md 

## 1. Introduction

This report presents an exploratory SQL analysis of the MovieLens dataset.
The goal is to demonstrate how SQL can be used to answer practical,
real-world questions about movie popularity, user behaviour, and engagement
patterns from relational data.

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
SELECT ...
```

### **3.2 Movie Popularity & Rating Quality**
Q2. Which movies are most popular (by number of ratings)?

**Why this matters**
Popularity reflects overall visibility and user engagement, which is often a key metric for content platforms.

(SQL + top 10 table)
```sql
SELECT ...
```

Q3. Which movies are the highest rated (after excluding movies with very few ratings)?

**Why this matters**
Filtering out movies with very few ratings improves reliability and avoids misleading averages.

(SQL + result table)
```sql
SELECT ...
```

Q4. Is there a relationship between popularity (number of ratings) and quality (average rating)?

**Why this matters**
This helps determine whether highly rated movies are also widely watched, or whether high-quality content can remain niche.

(SQL + result table)
```sql
SELECT ...
```

### **3.3 User Behaviour & Engagement**
Q5. Who are the most active users in terms of ratings submitted?

**Why this matters**
Identifying highly active users helps understand contribution patterns and engagement distribution within the platform.

(SQL + result table)
```sql
SELECT ...
```

### **3.4 Tags & User-Generated Metadata**
Q6. How many movies receive user-generated tags, and which movies receive the most tags?

**Why this matters**
Tags represent deeper user engagement beyond ratings and can highlight movies that stimulate discussion or commentary.

(SQL + result table)
```sql
SELECT ...
```
Interpretation
Short insight on engagement vs popularity.

### **3.5 Recommendation-Oriented Patterns (Advanced)**

This section explores more advanced relational patterns commonly used in recommendation systems.

Q7. Which users have rated the same movies as a given user?

**Why this matters**
Identifying users with overlapping preferences forms the basis of user-similarity analysis and collaborative filtering.

(SQL + example result)
```sql
SELECT ...
```
Q8. Which movies are frequently co-rated by the same users?

**Why this matters**
Movies that are often rated together can indicate natural content bundles or hidden associations useful for recommendations.

(SQL + result table)
```sql
SELECT ...
```
Q9. Which movies receive the most tags?

**Why this matters**
Highly tagged movies often generate more discussion and can be strong candidates for featured content or discovery-driven recommendations.

(SQL + result table)
```sql
SELECT ...
```
## 4. Future Work

The following questions were identified as potential extensions but were not
fully explored in this analysis:

- Do users who tag movies rate more than average users?
- Which users tend to rate movies significantly higher or lower than others?
- How sensitive are “top-rated movies” lists to different rating thresholds?

## 5. Conclusion

This analysis demonstrates how SQL can be used to extract meaningful insights from relational data, ranging from basic dataset exploration to more advanced co-rating and user behaviour analyses. The results highlight patterns in movie popularity, user engagement, and rating behaviour that are directly relevant to real-world data analysis tasks.
