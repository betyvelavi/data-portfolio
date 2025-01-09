/* This is a solution to P1 where we seek to retrieve the top 10 highest spending states in the US on political campaings */
SELECT -- ensures the output includes a column for state and their total spent. 
  country_subdivision_primary AS state, -- the column country_subdivision_primary includes values for state. We will rename it by using an alias through the AS command. 
  SUM(spend_usd) AS total_spent -- we use the SUM function to calculate the total spent on ads 
FROM -- from all tables in google_political_ads dataset, advetiser_geo_spend is the one containing information for the US by states and total amount spent on ads. 
  `bigquery-public-data.google_political_ads.advertiser_geo_spend`
WHERE
  country = 'US' -- filter only for US data
GROUP BY
  country_subdivision_primary -- to ensure daata grouped by state, and the SUM function adds the data on state criteria. 
ORDER BY
  SUM(spend_usd) DESC -- by spcifying descending, we ensurer the calculations for total amounts spent by state are listed from hightest to lowest
LIMIT 10 -- ensures only the top 10 states are shown in the query. 
