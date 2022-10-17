-- Procedure without parameters returning average salary for all employees
Drop Procedure if exists avg_salary;
Delimiter $$
Create procedure avg_salary()
Begin
	Select Round(AVG(Salary), 2) average_salary
	From salaries;
End$$
Delimiter ;
Call avg_salary();

-- Procedure with input parameter returning full name and average salary of a given employee
Delimiter $$
Create procedure emp_avg_salary(IN p_emp_no Int)
Begin
	Select e.first_name, e.last_name, AVG(s.salary) average_salary
	From employees e
    Join salaries s on e.emp_no = s.emp_no
    Where e.emp_no = p_emp_no
    Group by e.first_name, e.last_name;
End$$
Delimiter ;

-- Procedure with input and output parameter returning an employee number
Delimiter $$
Create procedure emp_info(IN p_first_name varchar(255), IN p_last_name varchar(255), OUT p_emp_no Int)
Begin
	Select e.emp_no INTO p_emp_no
	From employees e
    Where e.first_name = p_first_name and e.last_name = p_last_name; 
End$$
Delimiter ;
