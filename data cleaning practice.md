# Data Cleaning Functions 
## About the data

## Methodology 
SQL queries were ran using BigQuery 

## Problem 1

```
SELECT
  purchase_price 
FROM
  eloquent-victor-405022.customer_data.customer_purchase
ORDER BY
  purchase_price DESC #to organize in descending order
```
Which yields the following result
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/841055b2-b122-42da-825a-363acc7c5628)
From the result, the query looks like it is not in descending order. Number 2 is greater than Number 1. 

However, looking at the schema we see that the reason for this mistake is because `purchase_price` is taken as a string value when it should be a float. The database sorted the strings in descending order by looking only at the first number. 
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/c613448a-1197-4487-bf8e-51bd8eb76272)

We fix this by typecasting the data, which means that we convert it from one type to another. 

### Data Typecasting 
To change the data type using SQL , we use the `CAST(expr AS typename)` function. 
```
SELECT
  CAST(purchase_price AS FLOAT64) 
FROM
  eloquent-victor-405022.customer_data.customer_purchase
ORDER BY
  CAST(purchase_price AS FLOAT64) DESC
```
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/3a0d23ef-d721-421f-b44e-84bce491ce47)

## Problem 2
Changing from datetime to date data type using `CAST()` 
```
SELECT 
  date,
  purchase_price
FROM
  eloquent-victor-405022.customer_data.customer_purchase
WHERE 
  date BETWEEN '2020-12-01' AND '2020-12-31'
```
Yields the results: 
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/3f1dfa99-4aa3-42a8-a816-8fffc0fe64f5)

Now changing the data type from datetime to date

```
SELECT
  CAST(date AS date) AS date_only,
  purchase_price
FROM
  eloquent-victor-405022.customer_data.customer_purchase
WHERE
  date BETWEEN '2020-12-1' AND '2020-12-31'
```
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/05e35470-62a8-4a5a-afa6-994855507f8b)

## Using the CONCAT() function
Concat function allows us to add strings together 
```
/* Figuring out how to organize products by colors. */

SELECT
  CONCAT(product_code, product_color) AS new_product_code
FROM
  eloquent-victor-405022.customer_data.customer_purchase
WHERE
  product = 'couch'
```
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/7ae714ad-f9e1-458c-9246-636839c152a3)

## Using COALESCE() function 
`COALESCE()` returns non-null values in a list. 
```
/* This query uses coalesce */
SELECT
  COALESCE(product, product_code) AS product_info #checks product first and if value is null, it checks product_code
FROM
  eloquent-victor-405022.customer_data.customer_purchase
```
![image](https://github.com/betyvelavi/data-portfolio/assets/70249199/87562072-28f9-475b-9425-372ba2a57873)

