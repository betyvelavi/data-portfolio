/* This is a practice on sorting and filtering data in SQL */
SELECT *
FROM
  `bigquery-public-data.sdoh_cdc_wonder_natality.county_natality`
WHERE -- to filter
  County_of_Residence = 'Erie County, NY'
  OR County_of_Residence = 'Niagara County, NY'
  OR County_of_Residence = 'Chautauqua County, NY'
ORDER BY --to sort 
  Births DESC
