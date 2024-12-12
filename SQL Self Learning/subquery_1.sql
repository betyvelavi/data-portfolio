/* Practice with subqueries */
SELECT -- this outer SELECT statement lists the columns to retrieve from the citibike_stations table
  station_id,
  num_bikes_available,
  (SELECT -- subquery (envlosed in parentheses) created to calcuate avg of num_bikes_available
    AVG(num_bikes_available)
  FROM bigquery-public-data.new_york.citibike_stations) AS avg_num_bikes_available 
FROM bigquery-public-data.new_york.citibike_stations;
