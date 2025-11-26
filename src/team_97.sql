CREATE DATABASE University_HR_ManagementSystem_Team_97
GO

USE University_HR_ManagementSystem_Team_97
GO

-- 2.1

CREATE PROC createAllTables
AS
CREATE TABLE Department
(
    name VARCHAR(50) PRIMARY KEY,
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
    employment_status VARCHAR(50) CHECK (employment_status IN ('active', 'onleave', 'notice_period', 'resigned')),
    type_of_contract VARCHAR(50) CHECK (type_of_contract IN ('full_time', 'part_time')),
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
    percentage_YOE DECIMAL(4,2),
    percentage_overtime DECIMAL(4,2),
    annual_balance INT,
    accidental_balance INT,
);

CREATE TABLE Employee_Role
(
    emp_ID INT,
    role_name VARCHAR(50),
    PRIMARY KEY(emp_ID,role_name),
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (role_name) REFERENCES Role(role_name)
);

CREATE TABLE Role_existsIn_Department
(
    department_name VARCHAR(50),
    role_name VARCHAR(50),
    PRIMARY KEY(department_name,role_name),
    FOREIGN KEY (department_name) REFERENCES Department(name),
    FOREIGN KEY (role_name) REFERENCES Role(role_name),
);

CREATE TABLE Leave
(
    request_ID INT PRIMARY KEY IDENTITY(1,1),
    date_of_request DATE,
    start_date DATE,
    end_date DATE,
    num_days AS DATEDIFF(DAY,start_date,end_date) + 1,
    --fixed this as regular subtraction wasnt working
    final_approval_status VARCHAR(50) CHECK (final_approval_status IN ('approved', 'rejected', 'pending')) DEFAULT 'pending',
);

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
    type VARCHAR (50) CHECK (type IN ('sick', 'maternity')),
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
    document_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    type VARCHAR(50),
    description VARCHAR(50),
    file_name VARCHAR(50),
    creation_date DATE DEFAULT GETDATE(),
    expiry_date DATE,
    status VARCHAR(50) CHECK (status IN ('valid', 'expired')),
    emp_ID INT,
    medical_ID INT,
    unpaid_ID INT,
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (medical_ID) REFERENCES Medical_Leave(request_ID),
    FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_Leave(request_ID),
);

CREATE TABLE Payroll
(
    ID INT PRIMARY KEY IDENTITY(1,1),
    payment_date DATE,
    final_salary_amount DECIMAL(10,2),
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
    status VARCHAR(50) CHECK (status IN ('absent', 'attended')) Default 'absent',
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
    type VARCHAR(50) CHECK (type IN ('unpaid', 'missing_hours', 'missing_days')),
    status VARCHAR(50) CHECK (status IN ('pending', 'finalized')) Default 'pending',
    unpaid_ID INT,
    attendance_ID INT,
    FOREIGN KEY (emp_ID) REFERENCES Employee(employee_ID),
    FOREIGN KEY (unpaid_ID) REFERENCES Unpaid_Leave(request_ID),
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
    status VARCHAR(50) default 'pending',
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
    DROP FUNCTION IF EXISTS GET_ID_Replacment_IF_ON_LEAVE

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
    DROP PROCEDURE IF EXISTS auto_update_annual_compensation
    DROP PROCEDURE IF EXISTS auto_update_status
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
DBCC CHECKIDENT ('Deduction', RESEED, 1)
DBCC CHECKIDENT ('Document', RESEED, 1)
DBCC CHECKIDENT ('Performance', RESEED, 1)
DBCC CHECKIDENT ('Payroll', RESEED, 1)
DBCC CHECKIDENT ('Attendance', RESEED, 1)
DBCC CHECKIDENT ('Leave', RESEED, 1)
DBCC CHECKIDENT ('Employee', RESEED, 1)
GO


EXEC createAllTables

--EXEC dropAllTables

EXEC clearAllTables
GO

-- 2.2

CREATE VIEW allEmployeeProfiles
AS
    SELECT *
    FROM Employee;
GO

CREATE VIEW NoEmployeeDept
AS
    SELECT count(*) AS 'count'
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
    SELECT Ml.*
    FROM Medical_Leave Ml
        INNER JOIN Leave l on Ml.request_ID = l.request_ID
    where final_approval_status = 'rejected';
GO

CREATE VIEW allEmployeeAttendance
AS
    SELECT *
    FROM Attendance
    where date = GETDATE()-1
GO

-- 2.3

USE University_HR_ManagementSystem_Team_97;
GO

CREATE PROCEDURE Update_Status_Doc
AS
UPDATE Document SET status = 'expired' WHERE GETDATE() > expiry_date;
GO

CREATE PROCEDURE Remove_Deductions
AS
DELETE d FROM Deduction d
    INNER JOIN Employee e on d.emp_ID = e.employee_ID
WHERE e.employment_status ='resigned';
GO

CREATE PROCEDURE Update_Employment_Status
    @Employee_ID int
AS
BEGIN
    UPDATE Employee
    SET employment_status = CASE
            WHEN employment_status In ('notice_period', 'resigned') THEN employment_status
            WHEN dbo.Is_On_Leave(@Employee_ID, GETDATE(), GETDATE()) = 1 THEN 'onleave' 
            ELSE 'active'
        END 
    WHERE employee_ID = @Employee_ID;
END
GO

CREATE PROCEDURE Create_Holiday
AS
BEGIN
    IF OBJECT_ID('Holiday', 'U') IS NULL
    BEGIN
        CREATE TABLE Holiday
        (
            Holiday_ID INT PRIMARY KEY IDENTITY,
            name VARCHAR(50),
            from_date date,
            to_date date
        );
    END
END
GO

CREATE PROCEDURE Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date date,
    @to_date date
AS
INSERT INTO Holiday
    (name,from_date,to_date)
VALUES(@holiday_name, @from_date, @to_date);
GO

CREATE PROCEDURE Intitiate_Attendance
AS
BEGIN
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    INSERT INTO Attendance
        ([date], [status], emp_ID)
    SELECT @CurrentDate, 'absent', E.employee_ID
    FROM Employee E
    WHERE E.employment_status = 'active'
        AND E.employee_ID NOT IN (SELECT emp_ID
        FROM Attendance
        WHERE [date] = @CurrentDate);
END 
GO

CREATE PROCEDURE Update_Attendance
    @Employee_id int,
    @check_in time,
    @check_out time
AS
UPDATE Attendance
SET status = 'attended', check_in_time = @check_in, check_out_time = @check_out
WHERE emp_ID = @Employee_id AND date = CAST(GETDATE() AS DATE);
GO

CREATE PROCEDURE Remove_Holiday
AS
BEGIN
    DECLARE @AttendanceToRemove TABLE (ID INT);

    INSERT INTO @AttendanceToRemove
        (ID)
    SELECT A.attendance_ID
    FROM Attendance A
        INNER JOIN Holiday h ON A.date BETWEEN h.from_date AND h.to_date;

    DELETE FROM Deduction
    WHERE attendance_ID IN (SELECT ID
    FROM @AttendanceToRemove);

    DELETE FROM Attendance
    WHERE attendance_ID IN (SELECT ID
    FROM @AttendanceToRemove);
END
GO

CREATE PROCEDURE Remove_DayOff
    @Employee_id int
AS
DELETE FROM Attendance 
WHERE emp_ID = @Employee_id
    AND DATENAME(WEEKDAY, Attendance.date) IN (
    SELECT official_day_off
    FROM Employee
    WHERE @Employee_id = Employee.employee_ID
);
GO

CREATE PROCEDURE Remove_Approved_Leaves
    @Employee_id int
AS
DELETE FROM Attendance
WHERE emp_ID = @Employee_id
    AND EXISTS (
    SELECT 1
    FROM LEAVE l
        INNER JOIN (                                                       
                                            SELECT request_ID, emp_ID
            FROM Annual_Leave
        UNION ALL
            SELECT request_ID, emp_ID
            FROM Accidental_Leave
        UNION ALL
            SELECT request_ID, emp_ID
            FROM Medical_Leave
        UNION ALL
            SELECT request_ID, emp_ID
            FROM Unpaid_Leave
        UNION ALL
            SELECT request_ID, emp_ID
            FROM Compensation_Leave
    ) AS subleaves ON l.request_ID = subleaves.request_ID
    WHERE subleaves.emp_ID = @Employee_id
        AND l.final_approval_status = 'approved'
        AND Attendance.date BETWEEN l.start_date AND l.end_date
);
GO

CREATE PROCEDURE Replace_employee
    @Emp1_ID int,
    @Emp2_ID int,
    @from_date date,
    @to_date date
AS
BEGIN
    IF @from_date > @to_date BEGIN
        PRINT 'Error: Start > End';
        RETURN;
    END
    IF @Emp1_ID = @Emp2_ID BEGIN
        PRINT 'Error: Same Emp';
        RETURN;
    END

    IF EXISTS (SELECT 1
    FROM Employee
    WHERE employee_ID = @Emp2_ID AND employment_status = 'resigned')
    BEGIN
        PRINT 'Error: Emp2 resigned';
        RETURN;
    END

    DECLARE @Dept1 varchar(50), @Dept2 varchar(50);
    SELECT @Dept1 = dept_name
    FROM Employee
    WHERE employee_ID = @Emp1_ID;
    SELECT @Dept2 = dept_name
    FROM Employee
    WHERE employee_ID = @Emp2_ID;

    IF @Dept1 <> @Dept2 BEGIN
        PRINT 'Error: Different Depts';
        RETURN;
    END

    IF dbo.Is_On_Leave(@Emp1_ID, @from_date, @to_date) = 0
    BEGIN
        PRINT 'Error: Emp1 is not on leave';
        RETURN;
    END

    IF dbo.Is_On_Leave(@Emp2_ID, @from_date, @to_date) = 1
    BEGIN
        PRINT 'Error: Emp2 is on leave';
        RETURN;
    END;

    INSERT INTO Employee_Replace_Employee
        (Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES
        (@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO

-- 2.4

--2.5
CREATE FUNCTION EmployeeLoginValidation(@employee_ID int, @password varchar(50))
RETURNS bit
BEGIN
    DECLARE @ISVALID BIT = 0;
    IF EXISTS(SELECT *
    FROM Employee e
    where @employee_ID= e.employee_ID AND @password = e.[password])
 SET @ISVALID = 1;
    return @ISVALID
END
GO

CREATE FUNCTION MyPerformance(@employee_ID INT, @semester CHAR(3))
RETURNS TABLE
AS
RETURN
(
    SELECT
    performance_ID,
    rating,
    comments,
    semester
FROM Performance
WHERE emp_ID = @employee_ID
    AND semester = @semester
)
GO

CREATE FUNCTION Last_month_payroll(@employee_ID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
    ID AS payroll_ID,
    payment_date,
    final_salary_amount,
    from_date,
    to_date,
    comments,
    bonus_amount,
    deductions_amount
FROM Payroll
WHERE emp_ID = @employee_ID
    AND MONTH(payment_date) = MONTH(DATEADD(MONTH, -1, GETDATE()))
    AND YEAR(payment_date) = YEAR(DATEADD(MONTH, -1, GETDATE()))
);
GO

CREATE FUNCTION MyAttendance(@employee_ID int)
RETURNS TABLE
AS
RETURN(
    SELECT a.*
FROM Attendance a
    INNER JOIN Employee e ON a.emp_ID = e.employee_id
WHERE
        a.emp_ID = @employee_ID
    AND MONTH(a.date) = MONTH(GETDATE())
    AND YEAR(a.date) = YEAR(GETDATE())
    AND DATENAME(weekday, a.date) != e.official_day_off
);
GO


CREATE FUNCTION Deductions_Attendance (@employee_ID int, @month int)
RETURNS TABLE
AS
RETURN(
SELECT d.*
FROM Deduction d
    INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
WHERE @employee_ID = d.emp_ID AND MONTH(a.[date]) = @month
    AND d.[type] = 'missing_days'
)
GO

CREATE FUNCTION Is_On_Leave(@employee_ID INT, @from DATE, @to DATE)
RETURNS BIT
AS
BEGIN
    DECLARE @Onleave BIT = 0;
    IF EXISTS (
        SELECT 1
    FROM LEAVE AS l
        INNER JOIN (
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        SELECT request_id
            FROM Annual_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id
            FROM Accidental_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id
            FROM Medical_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id
            FROM Unpaid_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id
            FROM Compensation_Leave
            WHERE emp_id = @Employee_ID
        ) AS subleaves ON l.request_id = subleaves.request_id
        INNER JOIN Employee e ON e.employee_id = @employee_ID
    WHERE 
            l.start_date <= @to AND l.end_date >= @from
        AND NOT (e.employment_status = 'resigned')
        AND l.final_approval_status IN ('approved', 'pending')
    )
    SET @Onleave = 1;

    RETURN @Onleave;
END
GO

CREATE FUNCTION get_rank (@Employee_ID INT)
RETURNS INT
BEGIN
    DECLARE @rank INT;
    SELECT @rank = MIN(rank)
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_id = @Employee_ID;
    RETURN @rank;
END
GO

CREATE FUNCTION GET_ID_Replacment_IF_ON_LEAVE(@employee_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @ID INT = @employee_id
    SELECT TOP 1
        @ID = e.Emp2_ID
    FROM Employee_Replace_Employee e
    WHERE e.from_date <= GETDATE() AND e.to_date >= GETDATE()
    RETURN CASE WHEN dbo.Is_On_Leave(@employee_ID, GETDATE(), GETDATE()) = 1
    THEN @ID ELSE @employee_ID END
END
GO

CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
DECLARE @dep_name_replacement varchar(50);
DECLARE @my_dept varchar(50);
BEGIN
    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);
    SET @rank = dbo.get_rank(@employee_id);

    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_ID = @employee_id;

    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);
    SET @request_ID = SCOPE_IDENTITY();
    INSERT INTO Annual_Leave
        (request_id, emp_id, replacement_emp)
    VALUES
        (@request_id, @employee_id, @replacement_emp);

    PRINT @request_id

    IF EXISTS(
        SELECT type_of_contract
    FROM Employee
    WHERE @employee_ID = employee_ID AND type_of_contract = 'part_time'
    )
    BEGIN
        PRINT 'Part time employees are not eligble for annual leave';
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

    SELECT @my_dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;
    SELECT @dep_name_replacement = dept_name
    FROM Employee e
    WHERE e.employee_ID = @replacement_emp

    IF dbo.is_on_leave(@replacement_emp, @start_date, @end_date) = 1
    BEGIN
        PRINT 'replacment employee is on leave'
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

    IF @my_dept <> @dep_name_replacement
    BEGIN
        PRINT 'replacement employee is not from the same department'
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

    IF EXISTS(
        SELECT employee_ID
    FROM Employee
    WHERE employee_ID = @employee_ID
        AND dept_name='HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = 'HR'
        AND r.rank < @rank
    GROUP BY employee_ID
    ELSE IF EXISTS (
        SELECT employee_ID
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE r.rank = 1 OR r.role_name = 'HR_Representative_' + @dept_name
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT
        dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id),
        @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE (r.role_name = 'Dean' AND e.dept_name=@my_dept)
        OR r.role_name = 'HR_Representative_' + @dept_name
END 
GO

CREATE FUNCTION Status_leaves(@employee_ID INT)
RETURNS TABLE
AS
RETURN (                                                                                                                                                     SELECT al.request_ID,
        l.date_of_request,
        l.final_approval_status AS status
    FROM Annual_Leave aL
        INNER JOIN Leave l ON al.request_ID = l.request_ID
    WHERE al.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), l.date_of_request) = 0
UNION
    SELECT acl.request_ID,
        le.date_of_request,
        le.final_approval_status AS status
    FROM Accidental_Leave acl
        INNER JOIN Leave le ON acl.request_ID = le.request_ID
    WHERE acl.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), le.date_of_request) = 0
)
GO

CREATE PROCEDURE Upperboard_approve_annual
    @request_ID INT,
    @Upperboard_ID INT,
    @replacement_ID INT
AS
UPDATE Employee_Approve_Leave
        SET status =
                CASE WHEN EXISTS (
                    SELECT e.employee_ID
FROM Employee e
    INNER JOIN Leave l ON l.request_id = @request_ID
    INNER JOIN Annual_Leave al ON al.request_id = @request_ID
    INNER JOIN Employee e1 ON e1.employee_ID = al.emp_ID
WHERE e.dept_name = e1.dept_name
    AND e.employee_ID = @replacement_ID
    AND dbo.Is_On_Leave(@replacement_ID, l.start_date, end_date) = 0
                ) then 'Approved' ELSE 'Rejected'
            END
            WHERE Emp1_ID = @Upperboard_ID AND Leave_ID=@request_id
EXEC dbo.auto_update_annual_compensation @request_id;
GO

CREATE PROCEDURE Dean_andHR_Evaluation
    @employee_ID INT,
    @rating INT,
    @comment VARCHAR(50),
    @semester CHAR(3)
AS
BEGIN
    IF @rating < 1 OR @rating > 5
    BEGIN
        PRINT 'Error: Rating must be between 1 and 5.';
        RETURN;
    END
    INSERT INTO Performance
        (emp_ID, rating, comments, semester)
    VALUES
        (@employee_ID, @rating, @comment, @semester);
END
GO

CREATE PROCEDURE Submit_accidental
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    IF @start_date <> @end_date
    BEGIN
        PRINT 'Error: Accidental leaves can only be for 1 day.';
        RETURN;
    END

    INSERT INTO Leave
        (date_of_request, start_date, end_date, final_approval_status)
    VALUES
        (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Accidental_Leave
        (request_id, emp_id)
    VALUES
        (@ReqID, @employee_ID);

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;
    IF (@Dept = 'HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR Manager';
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Submit_medical
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type varchar(50),
    @insurance_status bit,
    @disability_details varchar(50),
    @document_description varchar(50),
    @file_name varchar(50)
AS
BEGIN
    IF @type = 'maternity'
    BEGIN
        DECLARE @contract_type VARCHAR(50);
        SELECT @contract_type = type_of_contract
        FROM Employee
        WHERE employee_ID = @employee_ID;
        IF @contract_type = 'part_time'
        BEGIN
            PRINT 'Error: Part-time employees are not eligible for maternity leave.';
            RETURN;
        END
    END

    INSERT INTO Leave
        (date_of_request, start_date, end_date, final_approval_status)
    VALUES
        (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Medical_Leave
        (request_id, emp_id, type, insurance_status, disability_details)
    VALUES
        (@ReqID, @employee_ID, @type, @insurance_status, @disability_details);

    IF @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document
            (medical_ID, emp_id, description, file_name, status, type, creation_date)
        VALUES
            (@ReqID, @employee_ID, @document_description, @file_name, 'valid', 'Medical', GETDATE());
    END

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    IF (@Dept = 'HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR Manager';
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Submit_unpaid
    -- TODO://to be tested
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF EXISTS (
        SELECT 1
    FROM Employee
    WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time'
    )
    BEGIN
        PRINT 'Error: Part-time employees are not eligible for unpaid leaves.';
        RETURN;
    END

    IF DATEDIFF(DAY, @start_date, @end_date) > 30
    BEGIN
        PRINT 'Error: Unpaid leave cannot exceed 30 days.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
    FROM Unpaid_Leave ul
        INNER JOIN Leave l ON ul.request_id = l.request_id
    WHERE ul.emp_ID = @employee_ID
        AND l.final_approval_status = 'Approved'
        AND YEAR(l.start_date) = YEAR(GETDATE())
    )
    BEGIN
        PRINT 'Error: You can only have one approved unpaid leave per year.';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @dept_name VARCHAR(50);

    SELECT @dept_name = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    SET @request_ID = SCOPE_IDENTITY();

    INSERT INTO Unpaid_Leave
        (request_id, emp_id)
    VALUES
        (@request_ID, @employee_ID);

    IF @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document
            (unpaid_ID, emp_id, description, file_name, status, type, creation_date)
        VALUES
            (@request_ID, @employee_ID, @document_description, @file_name, 'valid', 'Memo', GETDATE());
    END

    IF @dept_name = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE r.[rank] = 1
            OR (r.rank = 3 AND e.dept_name = 'HR');
    END

    ELSE IF EXISTS (
        SELECT 1
    FROM Employee_Role er
        INNER JOIN Role r ON er.role_name = r.role_name
    WHERE er.emp_id = @employee_ID AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank = 1 OR r.role_name = 'HR_Representative_' + @dept_name
    END

    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name)
            OR r.role_name = 'HR_Representative_' + @dept_name OR r.[rank] = 1;
    END
END
GO


CREATE PROCEDURE Upperboard_approve_unpaids
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    UPDATE Employee_Approve_Leave
    SET status = CASE 
                    WHEN EXISTS (
                        SELECT 1
    FROM Document
    WHERE Leave_ID = @request_ID
        AND status = 'valid' 
                    ) THEN 'Approved' 
                    ELSE 'Rejected' 
                 END
    WHERE Emp1_ID = @Upperboard_ID
        AND Leave_ID = @request_ID;
    EXECUTE dbo.auto_update_status @request_id
END
GO

CREATE PROCEDURE Submit_compensation
    @employee_ID INT,
    @compensation_date DATE,
    @reason VARCHAR(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
BEGIN
    INSERT INTO Leave
        (date_of_request, start_date, end_date, final_approval_status)
    VALUES
        (GETDATE(), @compensation_date, @compensation_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Compensation_Leave
        (request_id, emp_id, reason, date_of_original_workday, replacement_emp)
    VALUES
        (@ReqID, @employee_ID, @reason, @date_of_original_workday, @replacement_emp);

    IF dbo.Is_On_Leave(@replacement_emp, @compensation_date, @compensation_date) = 1
    BEGIN
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        RETURN;
    END

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    IF (@Dept = 'HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR Manager';
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO
