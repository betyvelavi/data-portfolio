SELECT * 
FROM
  `eloquent-victor-405022.movie_data.movies`
-- To  filter by Comedy Genre, we'll use the WHERE clause. To add more conditions such as filtering by revenue, we will use the clause AND 
WHERE
  Genre =  'Comedy'
  AND Revenue > 300000000
-- ORDER BY should be the last clause in the query. It shows ascending order in automatic. However, can type DESC to sort by descending order.
ORDER BY 
  `Release Date` DESC
