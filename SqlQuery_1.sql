CREATE DATABASE University_HR_ManagementSystem_Team_97
GO

USE University_HR_ManagementSystem_Team_97
GO

CREATE PROC createAllTables
AS
CREATE TABLE Department(
	name VARCHAR(50) PRIMARY KEY CHECK (name IN ('MET', 'IET', 'HR', 'Medical','civil','BI','Management','Law','Pharmacy','Dentistry')),
	building_location VARCHAR(50),
);
	
CREATE TABLE Employee(
	employee_ID INT PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(50),
	password VARCHAR(50),
	address VARCHAR(50),
	gender CHAR(1),
	official_day_off VARCHAR(50),
	years_of_experience INT,
	national_ID CHAR(16),
	employment_status VARCHAR(50) CHECK (employment_status IN ('Active', 'Onleave', 'Notice Period', 'Resigned')),
	type_of_contract VARCHAR(50) CHECK (type_of_contract IN ('Full time', 'Part time')),
	emergency_contact_name VARCHAR(50),
	emergency_contact_phone CHAR(11),
	annual_balance INT,
	accidental_balance INT,
	salary DECIMAL(10,2),
	hire_date DATE,
	last_working_date DATE,
	dept_name VARCHAR(50),
	FOREIGN KEY (dept_name) REFERENCES Department(name),
);

CREATE TABLE Employee_Phone(
	emp_ID INT PRIMARY KEY,
	phone_num CHAR(11) PRIMARY KEY,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Role(
	role_name VARCHAR(50) PRIMARY KEY,
	title VARCHAR(50),
	description VARCHAR(50),
	rank INT,
	base_salary DECIMAL(10,2),
	percentage_YOE DECIMAL(10,2),
	percentage_overtime DECIMAL(4,2),
	annual_balance INT,
	accidental_balance INT,
);

CREATE TABLE Employee_Role(
	emp_ID INT PRIMARY KEY,
	role_name VARCHAR(50) PRIMARY KEY,
	FOREIGN KEY (emp_ID) REFERENCES EMPLOYEE(employee_ID),
	FOREIGN KEY (role_name) REFERENCES Role(role_name)
);

CREATE TABLE Role_existsIn_Department(
	department_name VARCHAR(50) PRIMARY KEY,
	role_name VARCHAR(50) PRIMARY KEY,
	FOREIGN KEY (department_name) REFERENCES Department(name),
	FOREIGN KEY (Role_name) REFERENCES Role(role_name),
);

CREATE TABLE Leave(
		request_ID INT PRIMARY KEY, 
		date_of_request DATE, 
		start_date DATE, 
		end_date DATE,
		num_days AS (end_date) - (start_date), 
		final_approval_status VARCHAR(50) CHECK (final_approval_status IN ('Approved', 'Rejected', 'Pending')) DEFAULT 'Pending',
);

CREATE TABLE Annual_Leave(
	request_ID INT PRIMARY KEY,
    emp_ID INT,
    replacement_emp INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
	FOREIGN KEY (replacement_emp) REFERENCES Employee( employee_ID),
);

CREATE TABLE Accidental_Leave(
	request_ID INT PRIMARY KEY,
	emp_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
);

CREATE TABLE Medical_Leave(
	request_ID INT PRIMARY KEY,
	insurance_status BIT, 
	disability_details VARCHAR(50),
	type VARCHAR (50) CHECK (type IN ('Sick', 'Maternity')),
	Emp_ID INT,
	FOREIGN KEY (Emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
);

CREATE TABLE Unpaid_Leave(
	request_ID INT PRIMARY KEY,
	Emp_ID INT,
	FOREIGN KEY (Emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
);

CREATE TABLE Compensation_Leave(
	request_ID INT PRIMARY KEY,
	reason VARCHAR(50),
	date_of_original_workday DATE,
	emp_ID INT, 
	replacement_emp INT,
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
	FOREIGN KEY (emp_id) REFERENCES Employee(employee_ID),
	FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID),
);

CREATE TABLE Document(
	document_ID INT PRIMARY KEY, 
	type VARCHAR(50),
	description VARCHAR(50), 
	file_name VARCHAR(50), 
	creation_date DATE,
	expiry_date DATE, 
	status VARCHAR(50) CHECK (status IN ('Valid', 'Expired')), 
	emp_ID INT,
	medical_ID INT, 
	unpaid_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (medical_ID) REFERENCES medical_leave(request_ID),
	FOREIGN KEY (unpaid_ID) REFERENCES unpaid_leave(request_ID),
);

CREATE TABLE Payroll(
	ID INT, 
	payment_date DATE, 
	final_salary_amount DECIMAL(10,1), 
	from_date DATE,
	to_date DATE, 
	comments VARCHAR(150), 
	bonus_amount DECIMAL(10,2), 
	deductions_amount DECIMAL(10,2), 
	emp_ID INT,
	FOREIGN KEY(emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Attendance(
	attendance_ID INT PRIMARY KEY, 
	date DATE, 
	check_in_time TIME, 
	check_out_time TIME, 
	total_duration AS (check_out_time) - (check_in_time), 
	status VARCHAR(50) CHECK (status IN ('Absent', 'Attended')) Default 'Absent', 
	emp_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Deduction(
	deduction_ID INT, 
	emp_ID INT, 
	PRIMARY KEY(deduction_ID,emp_ID),
	date DATE, 
	amount DECIMAL(10,2), 
	type VARCHAR(50) CHECK (type IN ('Unpaid', 'Missing hours', 'Missing days')), 
	status VARCHAR(50) CHECK (status IN ('Pending', 'Finalized')) Default 'Pending', 
	unpaid_ID INT, 
	attendance_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_leave(request_ID),
	FOREIGN KEY (attendance_ID) REFERENCES Attendance(attendance_id),
);

CREATE TABLE Performance(
	performance_ID INT PRIMARY KEY, 
	rating INT CHECK (rating BETWEEN 1 AND 5), 
	comments VARCHAR(50), 
	semester CHAR(3), 
	emp_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Employee_Replace_Employee(
	Emp1_ID INT, 
	Emp2_ID INT, 
	PRIMARY KEY(Emp1_ID,Emp2_ID),
	from_date DATE, 
	to_date DATE,
	FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (Emp2_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Employee_Approve_Leave(
	Emp1_ID INT, 
	Leave_ID INT, 
	PRIMARY KEY(Emp1_ID,Leave_ID),
	status VARCHAR(50),
	FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (Leave_ID) REFERENCES Leave(request_ID),
);
GO

CREATE PROC CalculateEmployeeSalary/*not sure if we need to update in case employee changes roles or gets a salary change*/
@Employee_ID int
AS
DECLARE 
@base_salary DECIMAL(10,2),
@years_exp int,
@years_exp_perc DECIMAL(5,2),
@final_salary DECIMAL(10,2)
SELECT @base_salary = r.base_salary, @years_exp=e.years_of_experience,@years_exp_perc = r.percentage_YOE FROM Employee e
JOIN Employee_Role er ON er.emp_ID = e.employee_ID
JOIN Role r ON r.role_name =er.role_name
WHERE @Employee_ID = e.employee_ID
SET @final_salary = @base_salary+(@years_exp_perc/100)*@years_exp*@base_salary
UPDATE Employee
    SET e.salary = @final_salary
GO

CREATE PROC Role_Name_Change/*this is just gut feeling, not sure if using procedures for these is the correct approach or not*/
AS
DECLARE
@role_name VARCHAR(50),
@dep_name VARCHAR(50)
select @role_name = r.role_name,@dep_name = rd.department_name FROM Role r
JOIN Role_existsIn_Department rd ON r.role_name = rd.role_name
WHERE r.role_name = 'HR Representative'
SET @role_name = r.role_name+'_'+rd.department_name
UPDATE Role
	SET r.role_name = @role_name

GO

CREATE PROC dropAllTables
AS
DROP TABLE Employee_Approve_Leave
DROP TABLE Employee_Replace_Employee
DROP TABLE Performance
DROP TABLE Deduction
DROP TABLE Attendance
DROP TABLE Payroll
DROP TABLE Document
DROP TABLE Compensation_Leave
DROP TABLE Unpaid_Leave
DROP TABLE Medical_Leave
DROP TABLE Accidental_Leave
DROP TABLE Annual_Leave
DROP TABLE Medical_Leave
DROP TABLE Leave
DROP TABLE Role_existsIn_Department
DROP TABLE Employee_Role
DROP TABLE Role
DROP TABLE Employee_Phone
DROP TABLE Employee
DROP TABLE Department
GO

CREATE PROC dropAllProceduresFunctionsViews/*still needs to add more procs and views as we continue*/
AS
DROP PROC dropAllTables
DROP PROC createAllTables
DROP VIEW allEmploteeProfiles
DROP VIEW NoEmployeeDept
DROP VIEW allPerformance
DROP VIEW allRejectedMedicals
DROP VIEW allEmployeeAttendance
DROP PROC clearAllTables
DROP PROC CalculateEmployeeSalary
GO

CREATE PROC  clearAllTables
AS
TRUNCATE TABLE Employee_Approve_Leave
TRUNCATE TABLE Employee_Replace_Employee
TRUNCATE TABLE Performance
TRUNCATE TABLE Deduction
TRUNCATE TABLE Attendance
TRUNCATE TABLE Payroll
TRUNCATE TABLE Document
TRUNCATE TABLE Compensation_Leave
TRUNCATE TABLE Unpaid_Leave
TRUNCATE TABLE Medical_Leave
TRUNCATE TABLE Accidental_Leave
TRUNCATE TABLE Annual_Leave
TRUNCATE TABLE Medical_Leave
TRUNCATE TABLE Leave
TRUNCATE TABLE Role_existsIn_Department
TRUNCATE TABLE Employee_Role
TRUNCATE TABLE Role
TRUNCATE TABLE Employee_Phone
TRUNCATE TABLE Employee
TRUNCATE TABLE Department
GO

CREATE VIEW allEmployeeProfiles
AS
SELECT * FROM Employee;
GO

CREATE VIEW NoEmployeeDept
AS
SELECT count(*) FROM Employee
GROUP BY dept_name;
GO

CREATE VIEW  allPerformance
AS
SELECT * FROM Performance
WHERE semester ='W%';
GO

CREATE VIEW allRejectedMedicals
AS
SELECT * FROM Medical_Leave Ml
INNER JOIN Leave l on Ml.request_ID = l.request_ID
where final_approval_status = 'Rejected';
GO

CREATE VIEW allEmployeeAttendance
AS
SELECT * FROM Attendance
where date = GETDATE()-1;/*double check later*/
GO