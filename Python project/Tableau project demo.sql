-- Tableau project
-- Task 1 number of employees hired each year from 1990 by gender
Select Year(d.from_date) date_year, e.gender, Count(e.emp_no) num_employees
From t_employees e
Join t_dept_emp d
	On e.emp_no = d.emp_no
-- Where Year(d.from_date) >= 1990
Group by 1, 2
Having date_year >= 1990
Order by 1, 2; 

-- Task 2
-- Average salary over the years by gender
SELECT e.gender, d.dept_name, ROUND(AVG(s.salary), 2) salary, YEAR(s.from_date) date_year
FROM t_salaries s
JOIN t_employees e 
	ON s.emp_no = e.emp_no
JOIN t_dept_emp de 
	ON de.emp_no = e.emp_no
JOIN t_departments d 
	ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender , date_year
HAVING date_year <= 2002
ORDER BY date_year, d.dept_no, e.gender;

-- Task 3 
-- Stored procedure for salary range by department and gender
DROP PROCEDURE IF EXISTS salary_filter;
DELIMITER $$
CREATE PROCEDURE salary_filter (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
	SELECT e.gender, d.dept_name, Round(AVG(s.salary),2) avg_salary
	FROM t_salaries s
	JOIN t_employees e 
		ON s.emp_no = e.emp_no
	JOIN t_dept_emp de 
		ON de.emp_no = e.emp_no
	JOIN t_departments d 
		ON d.dept_no = de.dept_no
	WHERE s.salary BETWEEN p_min_salary AND p_max_salary
	GROUP BY d.dept_no, e.gender
    Order by d.dept_name;
END$$
DELIMITER ;
CALL salary_filter(50000, 100000);
