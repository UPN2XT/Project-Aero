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
    employee_ID INT IDENTITY(1,1) PRIMARY KEY,
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

CREATE TABLE Employee_Phone--11/14 fixed primary key
(
    emp_ID INT,
    phone_num CHAR(11),
    PRIMARY KEY(emp_ID,phone_num),
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
    emp_ID INT,
    role_name VARCHAR(50),
    PRIMARY KEY(emp_ID,role_name),
    FOREIGN KEY (emp_ID) REFERENCES EMPLOYEE(employee_ID),
    FOREIGN KEY (role_name) REFERENCES Role(role_name)
);

CREATE TABLE Role_existsIn_Department
(
    department_name VARCHAR(50),
    role_name VARCHAR(50),
    PRIMARY KEY(department_name,role_name),
    FOREIGN KEY (department_name) REFERENCES Department(name),
    FOREIGN KEY (Role_name) REFERENCES Role(role_name),
);

CREATE TABLE Leave
(
    request_ID INT PRIMARY KEY IDENTITY(1,1),
    date_of_request DATE,
    start_date DATE,
    end_date DATE,
    num_days AS DATEDIFF(DAY,start_date,end_date) + 1,
    --fixed this as regular subtraction wasnt working
    final_approval_status VARCHAR(50) CHECK (final_approval_status IN ('Approved', 'Rejected', 'Pending')) DEFAULT 'Pending',
);

-- ALL Leave subclasses inheriate thier parent Leave request_id so sperate IDENTITY(1,1) is not require  
CREATE TABLE Annual_Leave
(
    request_ID INT PRIMARY KEY,
    emp_ID INT,
    replacement_emp INT,
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (request_ID) REFERENCES Leave(request_ID),
    FOREIGN KEY (replacement_emp) REFERENCES Employee(employee_ID),
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
    ID INT PRIMARY KEY IDENTITY(1,1),
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
    attendance_ID INT PRIMARY KEY IDENTITY(1,1),
    date DATE,
    check_in_time TIME,
    check_out_time TIME,
    total_duration AS DATEDIFF(minute,check_in_time,check_out_time),--11/14 fixed this
    status VARCHAR(50) CHECK (status IN ('Absent', 'Attended')) Default 'Absent',
    emp_ID INT,
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Deduction
(
    deduction_ID INT IDENTITY(1,1),
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
    FOREIGN KEY (attendance_ID) REFERENCES Attendance(attendance_ID),
);

CREATE TABLE Performance
(
    performance_ID INT PRIMARY KEY IDENTITY(1,1),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments VARCHAR(50),
    semester CHAR(3),
    emp_ID INT,
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
);

CREATE TABLE Employee_Replace_Employee
(
    Table_ID INT IDENTITY(1,1),
    Emp1_ID INT,
    Emp2_ID INT,
    PRIMARY KEY(Table_ID, Emp1_ID,Emp2_ID),
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

USE University_HR_ManagementSystem_Team_97;
GO

CREATE PROC dropAllTables
AS
DROP TABLE IF EXISTS Employee_Approve_Leave
DROP TABLE IF EXISTS Employee_Replace_Employee
DROP TABLE IF EXISTS Performance
DROP TABLE IF EXISTS Deduction
DROP TABLE IF EXISTS Attendance
DROP TABLE IF EXISTS Payroll
DROP TABLE IF EXISTS Document
DROP TABLE IF EXISTS Compensation_Leave
DROP TABLE IF EXISTS Unpaid_Leave
DROP TABLE IF EXISTS Medical_Leave
DROP TABLE IF EXISTS Accidental_Leave
DROP TABLE IF EXISTS Annual_Leave
DROP TABLE IF EXISTS Leave
DROP TABLE IF EXISTS Role_existsIn_Department
DROP TABLE IF EXISTS Employee_Role
DROP TABLE IF EXISTS Role
DROP TABLE IF EXISTS Employee_Phone
DROP TABLE IF EXISTS Employee
DROP TABLE IF EXISTS Department
GO

CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    DROP FUNCTION IF EXISTS HRLoginValidation
    DROP FUNCTION IF EXISTS Bonus_amount
    DROP FUNCTION IF EXISTS EmployeeLoginValidation
    DROP FUNCTION IF EXISTS MyPerformance
    DROP FUNCTION IF EXISTS MyAttendance
    DROP FUNCTION IF EXISTS Last_month_payroll
    DROP FUNCTION IF EXISTS Deductions_Attendance
    DROP FUNCTION IF EXISTS Is_On_Leave
    DROP FUNCTION IF EXISTS Status_leaves
    DROP FUNCTION IF EXISTS get_approval_status
    DROP FUNCTION IF EXISTS get_approval_status_pres
    DROP FUNCTION IF EXISTS get_rank

    DROP VIEW IF EXISTS allEmployeeProfiles
    DROP VIEW IF EXISTS NoEmployeeDept
    DROP VIEW IF EXISTS allPerformance
    DROP VIEW IF EXISTS allRejectedMedicals
    DROP VIEW IF EXISTS allEmployeeAttendance

    DROP PROCEDURE IF EXISTS createAllTables
    DROP PROCEDURE IF EXISTS dropAllTables
    DROP PROCEDURE IF EXISTS clearAllTables
    DROP PROCEDURE IF EXISTS Update_Status_Doc
    DROP PROCEDURE IF EXISTS Remove_Deductions
    DROP PROCEDURE IF EXISTS Update_Employment_Status
    DROP PROCEDURE IF EXISTS Create_Holiday
    DROP PROCEDURE IF EXISTS Add_Holiday
    DROP PROCEDURE IF EXISTS Intitiate_Attendance
    DROP PROCEDURE IF EXISTS Update_Attendance
    DROP PROCEDURE IF EXISTS Remove_Holiday
    DROP PROCEDURE IF EXISTS Remove_DayOff
    DROP PROCEDURE IF EXISTS Remove_Approved_Leaves
    DROP PROCEDURE IF EXISTS Replace_employee
    DROP PROCEDURE IF EXISTS HR_approval_an_acc
    DROP PROCEDURE IF EXISTS HR_approval_unpaid
    DROP PROCEDURE IF EXISTS HR_approval_comp
    DROP PROCEDURE IF EXISTS Deduction_hours
    DROP PROCEDURE IF EXISTS Deduction_days
    DROP PROCEDURE IF EXISTS Deduction_unpaid
    DROP PROCEDURE IF EXISTS Add_Payroll
    DROP PROCEDURE IF EXISTS Submit_annual
    DROP PROCEDURE IF EXISTS Upperboard_approve_annual
    DROP PROCEDURE IF EXISTS Submit_accidental
    DROP PROCEDURE IF EXISTS Submit_medical
    DROP PROCEDURE IF EXISTS Submit_unpaid
    DROP PROCEDURE IF EXISTS Upperboard_approve_unpaids
    DROP PROCEDURE IF EXISTS Submit_compensation
    DROP PROCEDURE IF EXISTS Dean_andHR_Evaluation
    DROP PROCEDURE IF EXISTS auto_update_accedintal_leave
    DROP PROCEDURE IF EXISTS auto_update_Medical_leave
    DROP PROCEDURE IF EXISTS auto_update_Unpaid_leave
    DROP PROCEDURE IF EXISTS auto_update_annual
END
GO

CREATE PROC clearAllTables
AS
DELETE FROM Deduction
DELETE FROM Document
DELETE FROM Employee_Approve_Leave
DELETE FROM Employee_Replace_Employee
DELETE FROM Performance
DELETE FROM Payroll
DELETE FROM Employee_Phone
DELETE FROM Employee_Role
DELETE FROM Role_existsIn_Department
DELETE FROM Annual_Leave
DELETE FROM Accidental_Leave
DELETE FROM Compensation_Leave
DELETE FROM Medical_Leave
DELETE FROM Unpaid_Leave
DELETE FROM Attendance
DELETE FROM Leave
DELETE FROM Employee
DELETE FROM Role
DELETE FROM Department
GO



