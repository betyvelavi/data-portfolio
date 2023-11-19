/* This is a practice on cleaning data using SQL on a dataset containing historical sales data.*/

-- Here, the column type can only have two possible vales: gas or diesel. The use the DISTINCT command to check all the different values listed in fuel_type column.

SELECT
  DISTINCT fuel_type
FROM
  eloquent-victor-405022.cars.car_info
LIMIT 1000

-- Here, we are filling in missing data 

SELECT
  * #selects all 
FROM
  eloquent-victor-405022.cars.car_info
WHERE
  num_of_doors IS NULL; #checking for missing data in num_of_doors column 

-- Now, updating the missing values we have: 
UPDATE
  eloquent-victor-405022.cars.car_info
SET
  num_of_doors = "four"
WHERE
  make = "mazda"
  AND fuel_type = "gas"
  AND body_style = "sedan";
