/* This is a practice on sorting using Google's BigQuery on a dataset containing movie data.*/
SELECT * 
FROM
  `eloquent-victor-405022.movie_data.movies`
-- ORDER BY should be the last clause in the query. It shows ascending order in automatic. However, can type DESC to sort by descending order. 
ORDER BY 
  `Release Date` DESC
