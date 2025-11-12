CREATE DATABASE University_HR_ManagementSystem_Team_97
GO

USE University_HR_ManagementSystem_Team_97
GO

CREATE PROC createAllTables
AS
CREATE TABLE Department
(
	name VARCHAR(50) PRIMARY KEY CHECK (name IN ('MET', 'IET', 'HR', 'Medical','civil','BI','Management','Law','Pharmacy','Dentistry')),
	building_location VARCHAR(50),
);

CREATE TABLE Employee
(
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

CREATE TABLE Employee_Phone
(
	emp_ID INT PRIMARY KEY,
	phone_num CHAR(11) PRIMARY KEY,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Role
(
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

CREATE TABLE Employee_Role
(
	emp_ID INT PRIMARY KEY,
	role_name VARCHAR(50) PRIMARY KEY,
	FOREIGN KEY (emp_ID) REFERENCES EMPLOYEE(employee_ID),
	FOREIGN KEY (role_name) REFERENCES Role(role_name)
);

CREATE TABLE Role_existsIn_Department
(
	department_name VARCHAR(50) PRIMARY KEY,
	role_name VARCHAR(50) PRIMARY KEY,
	FOREIGN KEY (department_name) REFERENCES Department(name),
	FOREIGN KEY (Role_name) REFERENCES Role(role_name),
);

CREATE TABLE Leave
(
	request_ID INT PRIMARY KEY,
	date_of_request DATE,
	start_date DATE,
	end_date DATE,
	num_days AS (end_date) - (start_date),
	final_approval_status VARCHAR(50) CHECK (final_approval_status IN ('Approved', 'Rejected', 'Pending')) DEFAULT 'Pending',
);

CREATE TABLE Annual_Leave
(
	request_ID INT PRIMARY KEY,
	emp_ID INT,
	replacement_emp INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
	FOREIGN KEY (replacement_emp) REFERENCES Employee( employee_ID),
);

CREATE TABLE Accidental_Leave
(
	request_ID INT PRIMARY KEY,
	emp_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
);

CREATE TABLE Medical_Leave
(
	request_ID INT PRIMARY KEY,
	insurance_status BIT,
	disability_details VARCHAR(50),
	type VARCHAR (50) CHECK (type IN ('Sick', 'Maternity')),
	Emp_ID INT,
	FOREIGN KEY (Emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
);

CREATE TABLE Unpaid_Leave
(
	request_ID INT PRIMARY KEY,
	Emp_ID INT,
	FOREIGN KEY (Emp_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
);

CREATE TABLE Compensation_Leave
(
	request_ID INT PRIMARY KEY,
	reason VARCHAR(50),
	date_of_original_workday DATE,
	emp_ID INT,
	replacement_emp INT,
	FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
	FOREIGN KEY (emp_id) REFERENCES Employee(employee_ID),
	FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID),
);

CREATE TABLE Document
(
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

CREATE TABLE Payroll
(
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

CREATE TABLE Attendance
(
	attendance_ID INT PRIMARY KEY,
	date DATE,
	check_in_time TIME,
	check_out_time TIME,
	total_duration AS (check_out_time) - (check_in_time),
	status VARCHAR(50) CHECK (status IN ('Absent', 'Attended')) Default 'Absent',
	emp_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Deduction
(
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

CREATE TABLE Performance
(
	performance_ID INT PRIMARY KEY,
	rating INT CHECK (rating BETWEEN 1 AND 5),
	comments VARCHAR(50),
	semester CHAR(3),
	emp_ID INT,
	FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Employee_Replace_Employee
(
	Emp1_ID INT,
	Emp2_ID INT,
	PRIMARY KEY(Emp1_ID,Emp2_ID),
	from_date DATE,
	to_date DATE,
	FOREIGN KEY (Emp1_ID) REFERENCES Employee(employee_ID),
	FOREIGN KEY (Emp2_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Employee_Approve_Leave
(
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
SELECT @base_salary = r.base_salary, @years_exp=e.years_of_experience, @years_exp_perc = r.percentage_YOE
FROM Employee e
	JOIN Employee_Role er ON er.emp_ID = e.employee_ID
	JOIN Role r ON r.role_name =er.role_name
WHERE @Employee_ID = e.employee_ID
SET @final_salary = @base_salary+(@years_exp_perc/100)*@years_exp*@base_salary
UPDATE Employee
    SET e.salary = @final_salary
	where @Employee_ID = e.employee_id
GO

CREATE PROC Role_Name_Change/*this is just gut feeling, not sure if using procedures for these is the correct approach or not*/
AS
DECLARE
@role_name VARCHAR(50),
@dep_name VARCHAR(50)
select @role_name = r.role_name, @dep_name = rd.department_name
FROM Role r
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
	SELECT *
	FROM Employee;
GO

CREATE VIEW NoEmployeeDept
AS
	SELECT count(*)
	FROM Employee
	GROUP BY dept_name;
GO

CREATE VIEW  allPerformance
AS
	SELECT *
	FROM Performance
	WHERE semester ='W%';
GO

CREATE VIEW allRejectedMedicals
AS
	SELECT *
	FROM Medical_Leave Ml
		INNER JOIN Leave l on Ml.request_ID = l.request_ID
	where final_approval_status = 'Rejected';
GO

CREATE VIEW allEmployeeAttendance
AS
	SELECT *
	FROM Attendance
	where date = GETDATE()-1;/*double check later*/
GO

/*all the stuff the admin can do will be under here*/
CREATE PROCEDURE Update_Status_Doc
AS
UPDATE Document
SET status = 'Expired'
where GETDATE() >expiry_date;
GO

CREATE PROCEDURE  Remove_Deductions/*not sure if we need to remove the record or just set the amount to 0*/
AS
UPDATE Deduction
SET amount = 0
FROM Deduction d
	INNER JOIN Employee e on d.emp_ID = e.employee_ID
where e.employment_status ='Resigned'
GO

CREATE PROCEDURE Update_Employment_Status
	/*will probably need to use an upcoming procedure to help us but if someone has an idea do write*/
	@Employee_ID int
AS
GO

CREATE PROCEDURE Create_Holiday
AS
CREATE TABLE Holiday
(
	Holiday_ID INT PRIMARY KEY IDENTITY,
	name VARCHAR(50),
	from_date date,
	to_date date
);
GO

CREATE PROCEDURE  Add_Holiday
	@holiday_name VARCHAR(50),
	@from_date date,
	@to_date date
AS
INSERT INTO Holiday
	(name,from_date,to_date)
VALUES(@holiday_name, @from_date, to_date);
GO

CREATE PROCEDURE Intitiate_Attendance/*check later*/
AS
GO

CREATE PROCEDURE Update_Attendance/*could be done with if else but not sure*/
	@Employee_id int,
	@check_in time,
	@check_out time
AS
UPDATE Attendance
SET status = 'Attended',
check_in_time = @check_in,
check_out_time = @check_out
FROM Attendance
	INNER JOIN Employee on Attendance.emp_ID = Employee.employee_ID
WHERE (@Employee_id = emp_ID AND Attendance.total_hours >=8 AND Employee.type_of_contract = 'Full time')
	OR (total_hours<8 AND type_of_contract<>'Part time')
GO

CREATE PROCEDURE Remove_Holiday/*asked gpt here so not 100% if there is a better way*/
AS
DELETE FROM Attendance
where EXISTS(
SELECT *
FROM Holiday
where Attendance.[date] between h.from_date and h.to_date)
GO

CREATE PROCEDURE Remove_DayOff/*based on the previous one so double check*/
	@Employee_id int
AS
DELETE FROM Attendance 
where EXISTS(
SELECT official_day_off
FROM Employee
where @Employee_id = Employee.employee_ID)
GO

CREATE PROCEDURE  Remove_Approved_Leaves
	@Employee_id int
AS
DELETE FROM Attendance
WHERE EXISTS(
SELECT final_approval_status
from leave l
	INNER JOIN Employee_Approve_Leave ea ON ea.Leave_ID = l.request_ID
	INNER JOIN Employee e ON e.employee_ID = ea.Emp1_ID
where Attendance.[date] >=l.start_date AND Attendance.[date]<=end_date)
GO

CREATE PROCEDURE Replace_employee/*not sure if its just let emp1 from the table be 2 and 2 be 1 or not so will check later*/
	@Emp1_ID int,
	@Emp2_ID int,
	@from_date date,
	@to_date date
AS
GO
/*end of admin section*/

/*start of HR section*/
CREATE FUNCTION HRLoginValidation(@Employee_ID int, @Password varchar(50))
RETURNS bit
BEGIN
	DECLARE @ISVALID BIT = 0;
	IF EXISTS(SELECT *
	FROM Employee e
	where @Employee_ID= e.employee_ID AND @Password = e.[password])
 SET @ISVALID = 1;
	return @ISVALID
END
GO

CREATE PROCEDURE HR_approval_an_acc
	@request_ID int,
	@HR_ID int
AS
BEGIN
	IF @request_ID IN (								
														SELECT request_id
		FROM Accidental_Leave
	UNION
		SELECT request_id
		FROM Annual_Leave)
INSERT INTO Employee_Approve_Leave
		(Emp1_ID, Leave_ID, status)
	VALUES
		(
			@request_ID,
			@HR_ID,
			CASE WHEN EXISTS (SELECT request_id
			FROM Accidental_Leave) 
		THEN CASE WHEN
			EXISTS (
				SELECT employee_id
			FROM Employee
				INNER JOIN Accidental_Leave ON Accidental_Leave.emp_ID = Employee.employee_id
					AND @request_ID = Accidental_Leave.request_id
			WHERE Employee.accidental_balance > 0
			) THEN 'Approved'
			ELSE 'Rejected'
		END
		WHEN EXISTS (SELECT request_id
			FROM Annual_Leave) 
		THEN CASE WHEN
			EXISTS (
				SELECT employee_id
			FROM Employee
				INNER JOIN Annual_Leave ON Annual_Leave.emp_ID = Employee.employee_id
					AND @request_ID = Annual_Leave.request_id
			WHERE Employee.annual_balance > 0
			) THEN 'Approved'
			ELSE 'Rejected'
		END
		ELSE 'Rejected'
		END	
)
END
GO

CREATE PROCEDURE HR_approval_unpaid
	@request_ID int,
	@HR_ID int
AS
BEGIN
	IF @request_ID IN (SELECT request_id
	FROM Unpaid_Leave)
INSERT INTO Employee_Approve_Leave
		(Emp1_ID, Leave_ID, status)
	VALUES
		(
			@request_ID,
			@HR_ID,
			CASE WHEN 30 > (
				SELECT COUNT(*)
			FROM Unpaid_Leave
				INNER JOIN Leave ON Unpaid_Leave.request_id = Leave.request_id
			WHERE Unpaid_Leave.emp_ID IN (
					SELECT emp_id
				FROM Unpaid_Leave u
				WHERE u.request_id = @request_id
				) AND YEAR(CURRENT_DATE) = YEAR(Leave.start_date) -- Need to check if max unpaid leave is in the same year or not
			) THEN 'Approved'
			ELSE 'Rejected'
			END
		)
END
GO

CREATE PROCEDURE HR_approval_comp
	@request_ID int,
	@HR_ID int
AS
BEGIN
	IF @request_ID IN (SELECT request_id
	FROM Compensation_Leave)
INSERT INTO Employee_Approve_Leave
		(Emp1_ID, Leave_ID, status)
	VALUES
		(
			@request_ID,
			@HR_ID,
			CASE WHEN EXISTS (
				SELECT cl.request_id
			FROM Compensation_Leave cl
			WHERE cl.request_id = @request_id
				AND EXISTS (
					SELECT attendance_ID
				FROM Attendance
				WHERE DATENAME(WEEKDAY, cl.date_of_original_workday) IN (
						SELECT official_day_off
					FROM Employee
					WHERE Employee.emp_id = cl.emp_id
					) AND MONTH(Attendance.date) = MONTH(cl.date_of_original_workday)
					AND YEAR(Attendance.date) = YEAR(cl.date_of_original_workday)
				)
			) THEN 'Approved'
			ELSE 'Rejected'
			END
		)
END
GO

-- 3.4 (e, f, g) TODO

CREATE PROCEDURE Deduction_days
	@employee_ID int
AS
BEGIN
	INSERT INTO Deduction
		(emp_ID, )
END
GO
/*
	Questions?
	is the overtime calulated for last 30 days? month? this month? this needs answering
	is overtime calculated if an employee stays more than 8 hours for a day or is it for total hours

*/

CREATE FUNCTION Get_Salary(@employee_id INT)
RETURNS DECIMAL(10,2)
BEGIN
	DECLARE @Salary DECIMAL(10,2);
	SELECT @Salary = e.salary
	FROM Employee e
	WHERE e.employee_id = @employee_id;
	RETURN @Salary;
END
GO

CREATE FUNCTION Bonus_amount(@employee_ID INT)
RETURNS DECIMAL(10,2)
BEGIN
	DECLARE @TotalAmount DECIMAL(10, 2);
	DECLARE @Salary DECIMAL(10,2);
	DECLARE @BaseRate DECIMAL(10,2);
	DECLARE @OvertimeFactor DECIMAL(10,2);

	SELECT @TotalAmount = SUM (total_duration)
	FROM Attendance a
	WHERE a.emp_ID = @Employee_id
		AND a.date >= DATEADD(day, -30, GETDATE());


	SELECT @Salary = e.salary
	FROM Employee e
	WHERE e.employee_id = @employee_id;

	SET @BaseRate = @Salary / 176;

	SELECT TOP 1
		@OvertimeFactor = percentage_overtime
	FROM Role r
		INNER JOIN Employee_Role er ON er.role_name = r.role_name AND er.emp_id = @employee_id
	ORDER BY rank DESC;

	RETURN @BaseRate * (@OvertimeFactor * (@TotalAmount-176) / 100);

--SET @TotalAmount = 22 * 
END
GO

/*
	Questions:
		1- does payroll finalize deduction ie does it change its status
		2- again as above does what does the deduction dureation do exactly
*/
CREATE PROCEDURE Add_Payroll
	@Employee_ID INT,
	@From DATE,
	@TO DATE
AS
BEGIN
	DECLARE @Bouns_amount_val DECIMAL(10,2);
	DECLARE @Deduction_amount_val DECIMAL(10,2);
	SET @Bouns_amount_val = Bonus_amount(@Employee_ID);

	SELECT @Deduction_amount_val = SUM(amount)
	FROM Deduction
	WHERE emp_ID = @Employee_id AND date BETWEEN @TO AND @FROM;

	INSERT INTO Payroll
		(payment_date, final_salary_amount, from_date, to_date, bonus_amount, deductions_amount)
	VALUES
		(
			CURRENT_DATE, (Get_Salary(@Employee_id) + @Bouns_amount_val - @Deduction_amount_val),
			@From,
			@To,
			@Bouns_amount_val,
			@Deduction_amount_val
	)
END
GO





