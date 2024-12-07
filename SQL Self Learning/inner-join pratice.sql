/* This is a practice on JOIN clauses */
 SELECT
  employees.name AS employee_name, -- table.column and AS as an alias
  employees.role AS employee_role,
  departments.name AS department_name
FROM
  `eloquent-victor-405022.employee_data.employees` AS employees --FROM to specify where this data is obtained from 
INNER JOIN -- as this is default JOIN, it could also just be written as JOIN 
  `eloquent-victor-405022.employee_data.departments` AS departments
  ON employees.department_id = departments.department_id --matching key. 
