CREATE DATABASE omar_trial3
GO

USE omar_trial3
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
    num_days AS DATEDIFF(DAY,start_date,end_date), --fixed this as regular subtraction wasnt working
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

EXEC createAllTables; 
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

CREATE PROC dropAllProceduresFunctionsViews--not sure if the auto_update procs need to be added here as well
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
DROP PROC Update_Status_Doc
DROP PROC Remove_Deductions
DROP PROC Update_Employment_Status
DROP PROC Create_Holiday
DROP PROC Add_Holiday
DROP PROC Intitiate_Attendance
DROP PROC Update_Attendance
DROP PROC Remove_Holiday
DROP PROC Remove_DayOff
DROP PROC Remove_Approved_Leaves
DROP PROC Replace_employee
DROP PROC HR_approval_an_acc
DROP PROC HR_approval_unpaid
DROP PROC HR_approval_comp
DROP PROC Deduction_hours
DROP PROC Deduction_days
DROP PROC Add_Payroll
DROP PROC Replace_employee
DROP PROC HR_approval_an_acc
DROP PROC HR_approval_unpaid
DROP PROC HR_approval_comp
DROP PROC Deduction_hours
DROP PROC Deduction_days
DROP PROC  Deduction_unpaid
DROP PROC Bonus_amount
DROP PROC Add_Payroll
DROP PROC Submit_annual
DROP PROC  Status_leaves
DROP PROC Upperboard_approve_annual
DROP PROC Submit_accidental
DROP PROC Submit_medical
DROP PROC  Submit_unpaid
DROP PROC Upperboard_approve_unpaids
DROP PROC  Submit_compensation
DROP PROC Dean_andHR_Evaluation
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
    -- 2. ADDED ALIAS 'AS EmployeeCount'
    SELECT count(*) AS EmployeeCount, dept_name
    FROM Employee
    GROUP BY dept_name;
GO

CREATE VIEW  allPerformance
AS
    SELECT *
    FROM Performance
    -- 3. CHANGED '=' TO 'LIKE'
    WHERE semester LIKE 'W%';
GO

CREATE VIEW allRejectedMedicals
AS
    SELECT Ml.*, l.final_approval_status -- Changed to specific columns to avoid ambiguity
    FROM Medical_Leave Ml
        INNER JOIN Leave l on Ml.request_ID = l.request_ID
    where final_approval_status = 'Rejected';
GO

CREATE VIEW allEmployeeAttendance
AS
    SELECT *
    FROM Attendance
    where date = CAST(GETDATE()-1 AS DATE); -- Cast ensures time doesn't mess up comparison
GO

CREATE ROLE admin --assumed we will need something like this for admin.employee and hr
GO
CREATE PROCEDURE Update_Status_Doc
AS
UPDATE Document
SET status = 'Expired'
where GETDATE() > expiry_date;
GO

-- changed it to delete as it says remove
CREATE PROCEDURE  Remove_Deductions
AS
DELETE d FROM Deduction d
    INNER JOIN Employee e on d.emp_ID = e.employee_ID
    where e.employment_status ='Resigned'
GO


-- Different from OG code
CREATE PROCEDURE Update_Employment_Status
    @Employee_ID int
AS
BEGIN
    DECLARE @check_leave bit;

    -- Check if on leave (Pass current date for both start and end)
    SET @check_leave = dbo.Is_On_Leave(@Employee_ID, GETDATE(), GETDATE());

    IF @check_leave = 1
    BEGIN
        UPDATE Employee
        SET employment_status = 'onleave'
        -- ERROR FIX: Changed Employee_ID to ID (Check your specific column name)
        WHERE employee_ID = @Employee_ID; 
    END
    ELSE
    BEGIN
        -- If active, ensure we don't overwrite resigned/notice_period statuses
        UPDATE Employee
        SET employment_status = 'active'
        -- ERROR FIX: Changed Employee_ID to ID
        WHERE employee_ID = @Employee_ID 
          AND employment_status NOT IN ('resigned', 'notice_period');
    END
END;
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
VALUES(@holiday_name, @from_date, @to_date);
GO


-- Different from OG code
CREATE PROCEDURE Intitiate_Attendance
AS
BEGIN
    -- Insert a record for every valid employee for the current date.
    -- The default status is set to 'Absent' as per schema constraints.
    
    INSERT INTO Attendance (emp_ID, date, status)
    SELECT employee_ID, CAST(GETDATE() AS DATE), 'Absent'
    FROM Employee
    WHERE employment_status <> 'resigned'; 
    -- Excluding 'resigned' employees is a logical necessity to prevent 
    -- creating records for people who no longer work there.
END;
GO


--Different from OG code
CREATE PROCEDURE Update_Attendance
    @Employee_id int,
    @check_in time,
    @check_out time
AS
BEGIN
    -- Update the specific row for this employee on the current date.
    -- We update the check-in/out times and change status to 'Attended'
    -- because they have now shown up.
    
    UPDATE Attendance
    SET check_in_time = @check_in,
        check_out_time = @check_out,
        status = 'Attended'
    WHERE emp_ID = @Employee_id 
      AND date = CAST(GETDATE() AS DATE);
END;
GO

CREATE PROCEDURE Remove_Holiday/*asked gpt here so not 100% if there is a better way*/
AS
DELETE FROM Attendance
where EXISTS(
SELECT *
FROM Holiday
where Attendance.[date] between h.from_date and h.to_date)
GO

/*
    based on the previous one so double check
    as2: orginal would have deleted all attendance this should fix that
*/
CREATE PROCEDURE Remove_DayOff
    @Employee_id int
AS
DELETE FROM Attendance 
WHERE DATENAME(WEEKDAY, Attendance.date) IN (
SELECT official_day_off
FROM Employee e
where @Employee_id = e.employee_ID)
GO


-- Different from OG code (slight chganges)
CREATE PROCEDURE Remove_Approved_Leaves
    @Employee_id int
AS
BEGIN
    WITH ApprovedLeave AS (
        SELECT l.request_ID, l.start_date, l.end_date
        FROM [Leave] l -- Added brackets in case of reserved keyword
        INNER JOIN (
            SELECT request_id, emp_ID FROM Annual_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_ID FROM Accidental_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_ID FROM Medical_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_ID FROM Unpaid_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_ID FROM Compensation_Leave WHERE emp_id = @Employee_ID
        ) AS subleaves ON l.request_ID = subleaves.request_ID
        WHERE l.[final_approval_status] = 'Approved'
    )
    
    -- Delete from Attendance where the date falls within an approved leave period
    DELETE FROM Attendance
    WHERE emp_ID = @Employee_id
    AND EXISTS (
        SELECT 1 
        FROM ApprovedLeave al 
        WHERE Attendance.date BETWEEN al.start_date AND al.end_date
    );
END;
GO


-- Different from OG code
-- New
CREATE PROCEDURE Replace_employee
    @Emp1_ID int,
    @Emp2_ID int,
    @from_date date,
    @to_date date
AS
BEGIN
    -- 1. CHECK FOR ISSUE: Invalid Date Range
    IF @from_date > @to_date
    BEGIN
        PRINT 'Error: The start date cannot be after the end date.';
        RETURN;
    END

    -- 2. CHECK FOR ISSUE: Self-Replacement
    IF @Emp1_ID = @Emp2_ID
    BEGIN
        PRINT 'Error: An employee cannot replace themselves.';
        RETURN;
    END

    -- 3. CHECK FOR ISSUE: Employment Status ((Emp2) must be an ACTIVE employee)
    IF EXISTS (
        SELECT 1 
        FROM Employee 
        WHERE employee_ID = @Emp2_ID AND employment_status = 'resigned'
    )
    BEGIN
        PRINT 'Error: The replacement employee has resigned and cannot be assigned tasks.';
        RETURN;
    END

    -- 4. CHECK FOR ISSUE: Department Mismatch
    DECLARE @Dept1 varchar(50);
    DECLARE @Dept2 varchar(50);
    
    SELECT @Dept1 = dept_name FROM Employee WHERE employee_ID = @Emp1_ID;
    SELECT @Dept2 = dept_name FROM Employee WHERE employee_ID = @Emp2_ID;
    

    IF @Dept1 <> @Dept2
    BEGIN
        PRINT 'Error: Employees must belong to the same department.';
        RETURN;
    END

    -- 5. CHECK FOR ISSUE: Emp1 is NOT on Leave
    IF dbo.Is_On_Leave(@Emp1_ID, @from_date, @to_date) = 0
    BEGIN
        PRINT 'Error: Employee 1 is not on approved/pending leave during this period, so they cannot be replaced.';
        RETURN;
    END

    -- 6. CHECK FOR ISSUE: Emp2 IS on Leave
    IF dbo.Is_On_Leave(@Emp2_ID, @from_date, @to_date) = 1
    BEGIN
        PRINT 'Error: The replacement employee (Emp2) is on leave during this period.';
        RETURN;
    END

    -- 7. CHECK FOR ISSUE: Emp2 is already replacing someone else (Overlap)
    -- I am not sure about this one. If i remeber correctly an employee is allowed to replace several employees so in that case this condition should be removed.
    IF EXISTS (
        SELECT 1 
        FROM Employee_Replace_Employee 
        WHERE replacement_id = @Emp2_ID 
          AND (from_date <= @to_date AND to_date >= @from_date)
    )
    BEGIN
        PRINT 'Error: The replacement employee is already busy replacing someone else during this period.';
        RETURN;
    END

    -- 8. CHECK FOR ISSUE: Emp1 is already being replaced by someone else
    IF EXISTS (
        SELECT 1 
        FROM Employee_Replace_Employee 
        WHERE employee_id = @Emp1_ID 
          AND (from_date <= @to_date AND to_date >= @from_date)
    )
    BEGIN
        PRINT 'Error: Employee 1 already has a replacement registered for this period.';
        RETURN;
    END

    -- NO ISSUES FOUND: Insert the values
    INSERT INTO Employee_Replace_Employee (employee_id, replacement_id, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);

END;
GO

/*
CREATE PROCEDURE Replace_employee
    @Emp1_ID int, -- The employee being replaced
    @Emp2_ID int, -- The replacement employee
    @from_date date,
    @to_date date
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. CHECK FOR ISSUE: Invalid Date Range
    IF @from_date > @to_date
    BEGIN
        PRINT 'Error: The start date cannot be after the end date.';
        RETURN;
    END

    -- 2. CHECK FOR ISSUE: Self-Replacement
    IF @Emp1_ID = @Emp2_ID
    BEGIN
        PRINT 'Error: An employee cannot replace themselves.';
        RETURN;
    END

    -- 3. CHECK FOR ISSUE: Employment Status (Replacement must be Active)
    -- Note: We exclude 'resigned'. 'notice_period' is technically valid but risky; 
    -- however, resigned is definitely invalid[cite: 35].
    IF EXISTS (
        SELECT 1 
        FROM Employee 
        WHERE ID = @Emp2_ID AND employment_status = 'resigned'
    )
    BEGIN
        PRINT 'Error: The replacement employee has resigned and cannot be assigned tasks.';
        RETURN;
    END

    -- 4. CHECK FOR ISSUE: Department Mismatch
    DECLARE @Dept1 varchar(50);
    DECLARE @Dept2 varchar(50);
    
    SELECT @Dept1 = Dept_Name FROM Employee WHERE ID = @Emp1_ID; 
    SELECT @Dept2 = Dept_Name FROM Employee WHERE ID = @Emp2_ID;

    IF @Dept1 <> @Dept2
    BEGIN
        PRINT 'Error: Employees must belong to the same department.';
        RETURN;
    END

    -- 5. CHECK FOR ISSUE: Emp1 is NOT on Leave
    -- Emp1 must be on approved/pending leave[cite: 25, 30].
    IF dbo.Is_On_Leave(@Emp1_ID, @from_date, @to_date) = 0
    BEGIN
        PRINT 'Error: Employee 1 is not on approved/pending leave during this period, so they cannot be replaced.';
        RETURN;
    END

    -- 6. CHECK FOR ISSUE: Emp2 IS on Leave
    -- Emp2 must be available.
    IF dbo.Is_On_Leave(@Emp2_ID, @from_date, @to_date) = 1
    BEGIN
        PRINT 'Error: The replacement employee (Emp2) is on leave during this period.';
        RETURN;
    END

    -- 7. CHECK FOR ISSUE: Emp2 is already replacing someone else (Overlap)
    IF EXISTS (
        SELECT 1 
        FROM Employee_Replace_Employee 
        WHERE replacement_id = @Emp2_ID 
          AND (from_date <= @to_date AND to_date >= @from_date)
    )
    BEGIN
        PRINT 'Error: The replacement employee is already busy replacing someone else during this period.';
        RETURN;
    END

    -- 8. CHECK FOR ISSUE: Emp1 is already being replaced by someone else
    IF EXISTS (
        SELECT 1 
        FROM Employee_Replace_Employee 
        WHERE employee_id = @Emp1_ID 
          AND (from_date <= @to_date AND to_date >= @from_date)
    )
    BEGIN
        PRINT 'Error: Employee 1 already has a replacement registered for this period.';
        RETURN;
    END

    -- 9. CHECK FOR ISSUE: Cascading Replacement Conflict (NEW)
    -- Check if Emp1 is currently supposed to be replacing someone else (Employee X).
    -- If Emp1 is now on leave and being replaced, Employee X becomes uncovered.
    IF EXISTS (
        SELECT 1 
        FROM Employee_Replace_Employee 
        WHERE replacement_id = @Emp1_ID
          AND (from_date <= @to_date AND to_date >= @from_date)
    )
    BEGIN
        PRINT 'Error: The employee being replaced (Emp1) was assigned to cover another employee during this period. That record must be resolved first.';
        RETURN;
    END

    -- 10. CHECK FOR WARNING: Capacity Mismatch (NEW)
    -- Check if a Part-time employee is replacing a Full-time employee.
    DECLARE @Contract1 varchar(50);
    DECLARE @Contract2 varchar(50);

    SELECT @Contract1 = type_of_contract FROM Employee WHERE ID = @Emp1_ID;
    SELECT @Contract2 = type_of_contract FROM Employee WHERE ID = @Emp2_ID;

    IF @Contract1 = 'full_time' AND @Contract2 = 'part_time'
    BEGIN
        PRINT 'Warning: A Part-time employee is replacing a Full-time employee. Ensure hours capacity is sufficient.';
        -- We do NOT return here; we allow the insert with a warning.
    END

    -- NO ISSUES FOUND: Insert the values
    INSERT INTO Employee_Replace_Employee (employee_id, replacement_id, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);

END;
GO
*/

CREATE ROLE HR
GO
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
    DECLARE @Emp_ID int;
    DECLARE @Duration int;
    DECLARE @CurrentBalance int;
    DECLARE @ContractType varchar(50);

    -- 1. Retrieve dates from the parent Leave table (Assuming dates are here)
    SELECT @Duration = num_days
    FROM [Leave]
    WHERE request_ID = @request_ID;

    -- 2. Check if it is an ANNUAL Leave
    IF EXISTS (SELECT 1 FROM Annual_Leave WHERE request_ID = @request_ID)
    BEGIN
        -- Retrieve Employee ID specifically from the Annual_Leave table
        SELECT @Emp_ID = emp_ID
        FROM Annual_Leave
        WHERE request_ID = @request_ID;

        -- Retrieve Balance AND Contract Type
        SELECT @CurrentBalance = annual_balance,
               @ContractType = type_of_contract
        FROM Employee
        WHERE employee_ID = @Emp_ID;

        -- Logic: Must be Full Time AND have enough balance
        IF @ContractType = 'part_time'
        BEGIN
            -- Reject if part-time (Source: 1.4 Leaves Guidelines)
            UPDATE [Leave] SET final_approval_status = 'Rejected' WHERE request_ID = @request_ID;
        END
        ELSE IF @CurrentBalance >= @Duration
        BEGIN
            -- Approve and Deduct
            UPDATE [Leave] SET final_approval_status = 'Approved' WHERE request_ID = @request_ID;
            UPDATE Employee SET annual_balance = annual_balance - @Duration WHERE employee_ID = @Emp_ID;
        END
        ELSE
        BEGIN
            -- Reject if insufficient balance
            UPDATE [Leave] SET final_approval_status = 'Rejected' WHERE request_ID = @request_ID;
        END
    END

    -- 3. Check if it is an ACCIDENTAL Leave
    ELSE IF EXISTS (SELECT 1 FROM Accidental_Leave WHERE request_ID = @request_ID)
    BEGIN
        -- Retrieve Employee ID specifically from the Accidental_Leave table
        SELECT @Emp_ID = emp_ID 
        FROM Accidental_Leave
        WHERE request_ID = @request_ID;

        -- Retrieve Balance (No contract restriction for Accidental in guidelines)
        SELECT @CurrentBalance = accidental_balance FROM Employee WHERE employee_ID = @Emp_ID;

        IF @CurrentBalance >= @Duration
        BEGIN
            -- Approve and Deduct
            UPDATE [Leave] SET final_approval_status = 'Approved' WHERE request_ID = @request_ID;
            UPDATE Employee SET accidental_balance = accidental_balance - @Duration WHERE employee_ID = @Emp_ID;
        END
        ELSE
        BEGIN
            -- Reject if insufficient balance
            UPDATE [Leave] SET final_approval_status = 'Rejected' WHERE request_ID = @request_ID;
        END
    END
END;
GO


-- Different from OG code
CREATE PROCEDURE HR_approval_unpaid
    @request_ID int,
    @HR_ID int
AS
BEGIN
    DECLARE @Emp_ID int;
    DECLARE @StartDate date;
    DECLARE @EndDate date;
    DECLARE @Duration int;
    DECLARE @ContractType varchar(50);
    DECLARE @Year int;

    -- 1. Retrieve Leave Details
    -- We join Unpaid_Leave with Leave (parent) to get dates.
    SELECT @Emp_ID = u.emp_ID, 
           @StartDate = l.start_date,
           @EndDate = l.end_date
    FROM Unpaid_Leave u
    INNER JOIN [Leave] l ON u.request_ID = l.request_ID
    WHERE u.request_ID = @request_ID;

    -- 2. Retrieve Contract Type
    SELECT @ContractType = type_of_contract 
    FROM Employee 
    WHERE employee_ID = @Emp_ID;

    -- 3. Calculations
    SET @Duration = DATEDIFF(DAY,@StartDate,@EndDate);
    SET @Year = YEAR(@StartDate);

    -- 4. Validation Logic
    
    -- Constraint: Part-time employees are not eligible
    IF @ContractType = 'part_time'
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'Rejected' WHERE request_ID = @request_ID;
    END

    -- Constraint: Maximum duration is 30 days 
    ELSE IF @Duration > 30
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'Rejected' WHERE request_ID = @request_ID;
    END

    -- Constraint: Only one approved unpaid leave per year 
    -- Check if there is ALREADY an approved unpaid leave for this employee in the same year
    ELSE IF EXISTS (
        SELECT 1 
        FROM Unpaid_Leave u2
        INNER JOIN [Leave] l2 ON u2.request_ID = l2.request_ID
        WHERE u2.emp_ID = @Emp_ID 
          AND l2.final_approval_status = 'Approved'
          AND YEAR(l2.start_date) = @Year
          AND u2.request_id <> @request_ID -- Exclude current request
    )
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'Rejected' WHERE request_ID = @request_ID;
    END

    -- If all checks pass: Approve
    ELSE
    BEGIN
        UPDATE [Leave] SET final_approval_status = 'Approved' WHERE request_ID = @request_ID;
    END
END;
GO


-- Different from OG code
CREATE PROCEDURE HR_approval_comp--TODO this needs to check if there exists an employee to replace the employee on leave
    @request_ID int,
    @HR_ID int
AS
BEGIN
    DECLARE @Emp_ID int;
    DECLARE @OriginalWorkDate date;
    DECLARE @RequestDate date;
    DECLARE @OfficialDayOff varchar(50);
    DECLARE @HoursWorked int = 0;

    -- 1. Retrieve Details from Compensation_Leave and Leave (Parent)
    SELECT @Emp_ID = c.emp_ID,
           @OriginalWorkDate = c.date_of_original_workday,
           @RequestDate = l.date_of_request
    FROM Compensation_Leave c
    INNER JOIN [Leave] l ON c.request_ID = l.request_ID
    WHERE c.request_ID = @request_ID;

    -- 2. Retrieve Employee's Official Day Off
    SELECT @OfficialDayOff = official_day_off
    FROM Employee 
    WHERE employee_ID = @Emp_ID;

    -- 3. Calculate Hours Worked on the Original Work Day
    SELECT @HoursWorked = total_duration
    FROM Attendance
    WHERE emp_ID = @Emp_ID 
      AND date = @OriginalWorkDate
      AND status = 'Attended';

    -- 4. Validation Logic
    -- A: Must have worked >= 8 hours 
    -- B: The work day must have been their official day off 
    -- C: Request must be in the same month as the work day
    
    IF (@HoursWorked >= 8) 
       AND (DATENAME(WEEKDAY, @OriginalWorkDate) = @OfficialDayOff)
       AND (MONTH(@RequestDate) = MONTH(@OriginalWorkDate))
       AND (YEAR(@RequestDate) = YEAR(@OriginalWorkDate))
    BEGIN
        -- Approve
        UPDATE [Leave] 
        SET final_approval_status = 'Approved' 
        WHERE request_ID = @request_ID;
    END
    ELSE
    BEGIN
        -- Reject
        UPDATE [Leave] 
        SET final_approval_status = 'Rejected' 
        WHERE request_ID = @request_ID;
    END
END;
GO


-- Different from OG code
-- Done 100% using AI (I don't understand it. It is probably wrong)
-- new
CREATE PROCEDURE Deduction_hours
    @employee_ID int
AS
BEGIN
    -- 1. Calculate Hourly Rate (Source 53)
    DECLARE @HourlyRate DECIMAL(10, 2);
    DECLARE @Salary DECIMAL(10, 2);

    SELECT @Salary = salary 
    FROM Employee 
    WHERE employee_ID = @employee_ID;

    -- Formula: (Salary / 22 days) / 8 hours
    SET @HourlyRate = (@Salary / 22.0) / 8.0;

    -- 2. Calculate Deductions based on DAILY Shortfalls
    -- We sum the missing hours only for days where they attended but worked < 8 hours.
    -- This ignores Leaves/Holidays (no attendance) and Full Absences (handled by Deduction_days).
    INSERT INTO Deduction (emp_ID, date, amount, attendance_ID, type)
    SELECT 
        @employee_ID,
        
        -- Date: The date of the first "bad" record for that month
        (SELECT TOP 1 a.date 
         FROM Attendance a
         WHERE a.emp_ID = @employee_ID 
           AND MONTH(a.date) = Shortfalls.MonthVal 
           AND YEAR(a.date) = Shortfalls.YearVal 
           AND DATEDIFF(hour, a.check_in_time, a.check_out_time) < 8 
         ORDER BY a.date ASC), 

        -- Amount: Sum of (8 - WorkedHours) for all bad days * Rate
        Shortfalls.TotalMissingHours * @HourlyRate,

        -- Attendance_ID: The first "bad" record ID
        (SELECT TOP 1 a.attendance_ID 
         FROM Attendance a 
         WHERE a.emp_ID = @employee_ID 
           AND MONTH(a.date) = Shortfalls.MonthVal 
           AND YEAR(a.date) = Shortfalls.YearVal 
           AND DATEDIFF(hour, a.check_in_time, a.check_out_time) < 8
         ORDER BY a.date ASC),

        'Missing hours'
    FROM (
        -- Subquery: Calculate missing hours strictly per day
        SELECT 
            MONTH(date) AS MonthVal, 
            YEAR(date) AS YearVal, 
            -- Sum the difference between 8 and the actual duration
            SUM(8 - DATEDIFF(hour, check_in_time, check_out_time)) AS TotalMissingHours
        FROM Attendance
        WHERE emp_ID = @employee_ID 
          AND status = 'Attended' 
          AND DATEDIFF(hour, check_in_time, check_out_time) < 8 -- Only count days with shortfall
        GROUP BY MONTH(date), YEAR(date)
    ) AS Shortfalls
    WHERE NOT EXISTS (
        -- Prevent duplicate deductions for the same month
        SELECT 1 
        FROM Deduction d 
        WHERE d.emp_ID = @employee_ID 
          AND MONTH(d.date) = Shortfalls.MonthVal 
          AND YEAR(d.date) = Shortfalls.YearVal
          AND d.type = 'Missing hours'
    );
END;
GO


-- Different from OG code
-- new
CREATE PROCEDURE Deduction_days
    @employee_ID int
AS
BEGIN
    DECLARE @DailyRate DECIMAL(10, 2);
    DECLARE @OfficialDayOff VARCHAR(50);

    -- 1. Get Salary and Official Day Off
    SELECT @DailyRate = (salary / 22.0),
           @OfficialDayOff = official_day_off
    FROM Employee 
    WHERE employee_ID = @employee_ID; 

    -- 2. Insert Deductions for Absent Days
    -- We filter out Holidays, Days Off, and Leaves to be safe.
    INSERT INTO Deduction (emp_ID, date, amount, attendance_ID, type)
    SELECT 
        @employee_ID,
        a.date,
        @DailyRate,
        a.attendance_ID,
        'missing_days'
    FROM Attendance a
    WHERE a.emp_ID = @employee_ID 
      AND a.status = 'Absent'
      
      -- EDGE CASE 1: Check if it's their Official Day Off (Safeguard for Task 2.3 i)
      AND DATENAME(WEEKDAY, a.date) <> @OfficialDayOff
      
      -- EDGE CASE 2: Check if it's an Official Holiday (Safeguard for Task 2.3 h)
      AND NOT EXISTS (
          SELECT 1 
          FROM Holiday h 
          WHERE a.date BETWEEN h.from_date AND h.to_date
      )
      
      -- EDGE CASE 3: Check if they are on Approved Leave (Safeguard for Task 2.3 j)
      -- We use the helper function 2.5 f to check for 'Approved' or 'Pending' leaves
      AND dbo.Is_On_Leave(@employee_ID, a.date, a.date) = 0

      -- EXISTING CHECK: Prevent Duplicates
      AND NOT EXISTS (
          SELECT 1 
          FROM Deduction d 
          WHERE d.attendance_ID = a.attendance_ID
      );
END;
GO
GO

CREATE FUNCTION Get_Salary(@employee_id INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE @Salary DECIMAL(10,2);
    SELECT @Salary = e.salary
    FROM Employee e
    WHERE e.employee_ID = @employee_id;
    RETURN @Salary;
END
GO


-- Different from OG code
-- Created 100% using AI (Needs Checking)
CREATE FUNCTION Bonus_amount
(
    @employee_ID INT
)
RETURNS DECIMAL(10, 2)
BEGIN
    -- Declarations
    DECLARE @TotalExtraHours DECIMAL(10, 2) = 0.00;
    DECLARE @Salary DECIMAL(10, 2);
    DECLARE @HourlyRate DECIMAL(10, 2);
    DECLARE @OvertimeFactor DECIMAL(10, 2);
    DECLARE @BonusAmount DECIMAL(10, 2);

    -- 1. Get the Employee's Salary (Assuming 'Salary' column exists)
    SELECT @Salary = salary
    FROM Employee
    WHERE employee_ID = @employee_ID;

    -- 2. Calculate Hourly Rate (Rate per hour = (employee_salary/22 days)/8 hours)
    SET @HourlyRate = (@Salary / 22.0) / 8.0;

    -- 3. Get the Overtime Factor of the Highest Rank 
    SELECT TOP 1
        @OvertimeFactor = percentage_overtime
    FROM Role r
    INNER JOIN Employee_Role er ON er.role_name = r.role_name
    WHERE er.emp_ID = @employee_ID -- Using Employee_ID for FK in junction table
    ORDER BY rank ASC; -- Lower rank number means HIGHER rank 

    -- 4. Calculate Total Extra Hours (Overtime)
    -- Total extra hours are accumulated from days where worked duration > 8 hours 
    -- Assuming start_time/end_time columns exist in Attendance
    SELECT @TotalExtraHours = SUM(DailyOvertime)
    FROM (
        SELECT 
            -- Calculate duration and subtract the 8 required hours
            DATEDIFF(hour, a.check_in_time, a.check_out_time) - 8 AS DailyOvertime
        FROM Attendance a
        WHERE a.emp_ID = @employee_ID 
          AND a.status = 'Attended'
          -- Filter only for current month or period if specified; 
          -- if not specified, usually means all time or current period for payroll. 
          -- The original code used 30 days, which I'll omit unless the requirement specifies period.
    ) AS DailyHours
    WHERE DailyOvertime > 0;

    -- 5. Apply the Overtime Formula [cite: 54]
    -- Overtime amount = rate per hour * ([overtime factor * extra hours in attendance] / 100)
    SET @BonusAmount = @HourlyRate * ((@OvertimeFactor * @TotalExtraHours) / 100.0);

    RETURN @BonusAmount;
END;
GO

-- Different from OG code
-- Created 100% using AI (Needs Checking)
CREATE PROCEDURE Add_Payroll
    @Employee_ID INT,
    @From DATE,
    @TO DATE
AS
BEGIN
    DECLARE @BaseSalary DECIMAL(10, 2);
    DECLARE @YearsOfExperience INT;
    DECLARE @PercentageYearOfExperience DECIMAL(10, 2);
    
    DECLARE @BonusAmountVal DECIMAL(10, 2);
    DECLARE @DeductionAmountVal DECIMAL(10, 2);
    DECLARE @FinalSalary DECIMAL(10, 2);
    
    -- 1. Calculate the Employee's Salary (Base Salary + Experience Bonus)
    -- Formula: salary = base_salary + (%year_of_experience/100) * years_of_experience * base_salary
    SELECT 
        @BaseSalary = r.base_salary,
        @YearsOfExperience = e.years_of_experience,
        @PercentageYearOfExperience = r.percentage_YOE -- Assuming this column exists in Role
    FROM Employee e
    INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    INNER JOIN Role r ON er.role_name = r.role_name
    WHERE e.employee_ID = @Employee_ID
    ORDER BY r.rank ASC; -- Use the base salary of the higher rank
    
    SET @FinalSalary = @BaseSalary + (@PercentageYearOfExperience / 100.0) * @YearsOfExperience * @BaseSalary;

    -- 2. Fetch Bonus Amount (calculated via function 2.4.h)
    SET @BonusAmountVal = dbo.Bonus_amount(@Employee_ID);

    -- 3. Fetch Finalized Deductions Amount
    -- Deductions are finalized when they are reflected in the payroll.
    SELECT @DeductionAmountVal = SUM(amount)
    FROM Deduction
    WHERE emp_ID = @Employee_ID 
      AND date BETWEEN @FROM AND @TO  -- FIX: Correct date order
      AND status = 'finalized';      -- FIX: Filter by finalized status [cite: 32, 51]

    -- Handle NULL deductions
    SET @DeductionAmountVal = ISNULL(@DeductionAmountVal, 0.00);

    -- 4. Calculate Final Payment
    SET @FinalSalary = @FinalSalary + @BonusAmountVal - @DeductionAmountVal;
    
    -- 5. Insert into Payroll Table
    INSERT INTO Payroll
        (emp_ID, payment_date, final_salary_amount, from_date, to_date, bonus_amount, deductions_amount) -- FIX: Added Employee_ID
    VALUES
        (
            @Employee_ID,
            GETDATE(),
            @FinalSalary,
            @From,
            @To,
            @BonusAmountVal,
            @DeductionAmountVal
        );
END;
GO

CREATE ROLE Employee
GO
-- Fixed: invalid column name employee_ID and password here
CREATE FUNCTION EmployeeLoginValidation(@employee_ID int, @password varchar(50))
-- Goal: login using my Id and password
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
-- Goal: "Retrieve my performance for a certain semester."
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
-- Goal: Retrieve last month's payroll details
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
-- Goal: Retrieve attendance records for the current month, excluding my unattended official_day_off
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


-- Error
CREATE FUNCTION Deductions_Attendance (@employee_ID int, @month int)
RETURNS TABLE
AS
RETURN(
SELECT *                -- There is an issue here (to fix this we need to select all columns separately)
FROM Deduction d
    INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
WHERE @employee_ID = d.emp_ID AND MONTH(d.date) = @month
)
GO


-- Different from OG code (slight changes)
CREATE FUNCTION Is_On_Leave
(
    @employee_ID INT, 
    @from DATE, 
    @to DATE
)
-- Goal: Verify whether the employee will be on leave during the specified period...
-- treat it as approved for verification purposes
RETURNS BIT
AS
BEGIN
    DECLARE @Onleave BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM [Leave] AS l 
        INNER JOIN (
            SELECT request_id, emp_id FROM Annual_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_id FROM Accidental_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_id FROM Medical_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_id FROM Unpaid_Leave WHERE emp_id = @Employee_ID
            UNION ALL
            SELECT request_id, emp_id FROM Compensation_Leave WHERE emp_id = @Employee_ID
        ) AS subleaves ON l.request_id = subleaves.request_id
        WHERE NOT (l.end_date < @from OR l.start_date > @to) 
          AND l.status IN ('Approved', 'Pending')             
    )
    BEGIN
        SET @Onleave = 1;
    END

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

-- as3: this need revisting to make sure it complies with the guidlines in 1 also that it is actually working
-- as3: TODO: j - n follow similar structure to this
CREATE PROCEDURE Submit_annual
-- Goal: Apply for an annual leave. Populate the approval table accordingly
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name INT;
    SET @rank = db.get_rank(@employee_id);

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

    IF EXISTS(
        SELECT employee_ID
    FROM Employee
    WHERE employee_ID = @employee_ID
        AND dept_name='HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_ID, @request_id
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
    WHERE e.employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_ID, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE r.rank <= 2
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_ID, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name) OR e.dept_name = 'HR'

END;
GO

CREATE FUNCTION Status_leaves(@employee_ID INT)
-- Goal: Retrieve the status of all my submitted annual and accidental leaves during the current month.
RETURNS TABLE
AS
RETURN (
        SELECT al.request_ID,
        l.date_of_request,
        l.final_approval_status AS status  -- changed to l instead of al
    FROM Annual_Leave aL
        INNER JOIN Leave l ON al.request_ID = l.request_ID
    WHERE al.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), l.date_of_request) = 0
UNION
    SELECT acl.request_ID,
        le.date_of_request,
        le.final_approval_status AS status  -- changed to le instead of acl
    FROM Accidental_Leave acl
        INNER JOIN Leave le ON acl.request_ID = le.request_ID
    WHERE acl.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), le.date_of_request) = 0
)
GO

CREATE PROCEDURE Upperboard_approve_annual
-- Goal: As a Dean/Vice-dean/President I can approve/reject annual leaves. 
--In case the person of replacement isn't on leave and works in the same department, the leave gets approved.
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
    AND db.Is_On_Leave(@replacement_ID, l.start_date, end_date) = 0
                ) then 'Approved' ELSE 'Rejected'
            END
            WHERE Emp1_ID = @Upperboard_ID AND Leave_ID=@request_id
GO

CREATE PROCEDURE Submit_accidental
-- Goal: Apply for an accidental leave. Populate the approval table accordingly with the corresponding 
-- employees for the leaves’ approval based on the hierarchy
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    -- 1. VALIDATION: Accidental leaves must be exactly 1 day (Section 1.4).
    IF @start_date <> @end_date
    BEGIN
        PRINT 'Error: Accidental leaves can only be for 1 day (Start Date must equal End Date).';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50); 

    -- Get the employee's rank
    SELECT @rank =get_rank(@employee_ID)

    -- Get the employee's department
    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_ID = @employee_id;

    -- 2. Insert into the main generic 'Leave' table
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    -- 3. Get the ID of the row we just created
    SET @request_ID = SCOPE_IDENTITY();

    -- 4. Insert into the specific 'Accidental_Leave' table
    INSERT INTO Accidental_Leave
        (request_id, emp_id)
    VALUES
        (@request_ID, @employee_id);

    -- 5. POPULATE APPROVALS (Logic copied from Submit_annual)
    
    -- Case A: If the employee is in HR, they need approval from higher-ranking HR staff.
    IF EXISTS(
        SELECT employee_ID
        FROM Employee
        WHERE employee_ID = @employee_id AND dept_name='HR'
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
        AND r.rank < @rank
        GROUP BY e.employee_ID
    END

    -- Case B: If the employee is a Dean or Vice Dean, they need approval from President/Vice President (Rank 1 or 2).
    ELSE IF EXISTS (
        SELECT e.employee_ID
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank <= 2
    END

    -- Case C: Regular employees (Lecturers, TAs, etc.) need approval from their Dean AND HR.
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name) 
           OR e.dept_name = 'HR'
    END
END
GO

CREATE PROCEDURE Submit_medical
-- Goal: Apply for a medical leave. Populate the approval table 
-- accordingly with the corresponding employees for the leaves’ approval based on the hierarchy.
-- It's pretty similar to the function above it 
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type varchar(50), -- 'sick' or 'maternity'
    @insurance_status bit, 
    @disability_details varchar(50),
    @document_description varchar(50), 
    @file_name varchar(50)
AS
BEGIN
    -- 1. VALIDATION: Check for Part-Time + Maternity rule (Section 1.4)
    -- "Employees who are part-time are not eligible for... maternity leaves."
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

    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);

    -- Get the employee's rank
    SELECT @rank = get_rank(@employee_ID)
    -- Get the employee's department
    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_ID = @employee_id;

    -- 2. Insert into the main generic 'Leave' table
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    -- 3. Get the new request_ID
    SET @request_ID = SCOPE_IDENTITY();

    -- 4. Insert into the specific 'Medical_Leave' table
    INSERT INTO Medical_Leave
        (request_id, emp_id, type, insurance_status, disability_details)
    VALUES
        (@request_ID, @employee_id, @type, @insurance_status, @disability_details);


    -- For the documents type shit
    IF @file_name IS NOT NULL OR @document_description IS NOT NULL
    BEGIN
        INSERT INTO Document 
            (medical_ID, emp_ID, description, file_name, status)
        VALUES 
            (@request_ID, @employee_ID, @document_description, @file_name, 'valid'); 
    END
    -- Case A: HR Employees -> Need approval from higher HR
    IF EXISTS(
        SELECT employee_ID
        FROM Employee
        WHERE employee_ID = @employee_ID AND dept_name='HR'
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
        AND r.rank < @rank
        GROUP BY e.employee_ID
    END

    -- Case B: Dean/Vice Dean -> Need approval from President/Vice President (Rank 1 or 2)
    ELSE IF EXISTS (
        SELECT e.employee_ID
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank <= 2
    END

    -- Case C: Regular employees -> Need approval from their Dean AND HR
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name) 
           OR e.dept_name = 'HR'
    END
END
GO

CREATE PROCEDURE Submit_unpaid
-- Goal: Apply for unpaid leave. Populate the approval table accordingly
-- with the corresponding employees for the leaves’ approval based on the hierarchy
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Employee 
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

    -- We check if they already have an 'Approved' unpaid leave in the current year.
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
    
    -- Get Dept Name for logic later
    SELECT @dept_name = dept_name FROM Employee WHERE employee_ID = @employee_ID;

    -- 4. Insert into generic Leave table
    INSERT INTO Leave (date_of_request, start_date, end_date)
    VALUES (GETDATE(), @start_date, @end_date);
    
    SET @request_ID = SCOPE_IDENTITY();

    -- 5. Insert into Unpaid_Leave table
    INSERT INTO Unpaid_Leave (request_id, emp_id)
    VALUES (@request_ID, @employee_ID);

    -- 6. Insert Document (if provided)
    IF @file_name IS NOT NULL OR @document_description IS NOT NULL
    BEGIN
        INSERT INTO Document (unpaid_ID, emp_id, description, file_name, status)
        VALUES (@request_ID, @employee_ID, @document_description, @file_name, 'valid');
    END
    
    -- CASE A: The Applicant is an HR Employee
    -- Guideline: "Must be approved/rejected by the President and HR Manager."
    IF @dept_name = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_ID
        FROM Employee e
        INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
        INNER JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President' 
           OR (r.role_name = 'HR Manager' AND e.dept_name = 'HR');
    END

    -- CASE B: The Applicant is a Dean or Vice Dean
    -- Guideline: "Must be approved/rejected by the President and HR Representative."
    ELSE IF EXISTS (
        SELECT 1 FROM Employee_Role er 
        INNER JOIN Role r ON er.role_name = r.role_name
        WHERE er.emp_id = @employee_ID AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_ID
        FROM Employee e
        INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
        INNER JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President' 
           OR (r.role_name = 'HR Representative' AND e.dept_name = 'HR');
    END

    -- CASE C: Regular Employee (Dean of their Dept + HR)
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_ID
        FROM Employee e
        INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
        INNER JOIN Role r ON er.role_name = r.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name)
           OR e.dept_name = 'HR';
    END
END
GO

CREATE PROCEDURE Upperboard_approve_unpaids
-- Goal: As a Dean/Vice-dean/President I can approve/reject unpaid leaves. memo document submitted with a valid reason,
-- the leave gets approved.
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    -- Requirement: "In case a memo document is submitted with a valid reason, the leave gets approved."
    -- If a document is found, the status becomes 'Approved'. If not, it becomes 'Rejected'.
    UPDATE Employee_Approve_Leave
    SET status = CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM Document 
                        WHERE unpaid_ID = @request_ID -- changed to unpaid_ID we kan fee 7agat zy keda bardo fo2 8ayartohom bas neseit akteb comments
                        AND status = 'valid' 
                    ) THEN 'Approved' 
                    ELSE 'Rejected' 
                 END
    WHERE Emp1_ID = @Upperboard_ID 
      AND Leave_ID = @request_ID;
END
GO

CREATE PROCEDURE Submit_compensation--TODO this should only be approved by the employees hr rep according to the description from ms 1 and 2
-- Goal: Apply for a compensation leave. Populate the approval table
-- accordingly with the corresponding employees for the leaves’ approval based on the hierarchy
    @employee_ID INT,
    @compensation_date DATE, 
    @reason VARCHAR(50),
    @date_of_original_workday DATE, 
    @replacement_emp INT
AS
BEGIN
    IF MONTH(GETDATE()) <> MONTH(@date_of_original_workday) OR YEAR(GETDATE()) <> YEAR(@date_of_original_workday)
    BEGIN
        PRINT 'Error: Compensation leave must be requested within the same month as the extra work day.';
        RETURN;
    END

    -- Check B: "Spent at least 8 hours during his/her day off"
    DECLARE @hours_worked INT;
    
    SELECT @hours_worked = DATEDIFF(HOUR, check_in_time, check_out_time)
    FROM Attendance
    WHERE emp_id = @employee_ID 
      AND date = @date_of_original_workday;

    IF @hours_worked IS NULL OR @hours_worked < 8
    BEGIN
        PRINT 'Error: You must have worked at least 8 hours on the original workday to claim compensation.';
        RETURN;
    END

    -- Check C: Verify that @date_of_original_workday was actually their "Official Day Off"
    DECLARE @official_day_off VARCHAR(50);
    SELECT @official_day_off = official_day_off 
    FROM Employee 
    WHERE employee_ID = @employee_ID;

    -- DATENAME returns 'Saturday', 'Sunday', etc. matching the expected format of official_day_off
    -- Not sure of this one
    IF DATENAME(WEEKDAY, @date_of_original_workday) <> @official_day_off
    BEGIN
        PRINT 'Error: The date of original work must match your official day off.';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);

    -- Get the employee's rank and department for Approval Logic
    SELECT @rank = MIN(r.rank), 
    @dept_name = e.dept_name
    FROM Employee e
    INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
    INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_id = @Employee_ID
    GROUP BY e.dept_name;

    -- Insert into generic Leave table (Duration is usually 1 day for compensation)
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @compensation_date, @compensation_date);

    SET @request_ID = SCOPE_IDENTITY();

    -- Insert into specific Compensation_Leave table
    INSERT INTO Compensation_Leave
        (request_id, emp_id, reason, date_of_original_workday, replacement_emp)
    VALUES
        (@request_ID, @employee_ID, @reason, @date_of_original_workday, @replacement_emp);


    -- Case A: HR Employees -> Need approval from higher HR
    IF EXISTS(
        SELECT employee_id
        FROM Employee
        WHERE employee_id = @employee_id AND dept_name='HR'
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_id, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
        AND r.rank < @rank
        GROUP BY e.employee_id
    END

    -- Case B: Dean/Vice Dean -> Need approval from President/Vice President (Rank 1 or 2)
    ELSE IF EXISTS (
        SELECT e.employee_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.employee_id = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_id, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank <= 2
    END

    -- Case C: Regular employees -> Need approval from their Dean AND HR
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID)
        SELECT e.employee_id, @request_id
        FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name) 
           OR e.dept_name = 'HR'
    END
END
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

-- =========================================
-- Departments
-- =========================================
INSERT INTO Department (name, building_location) VALUES
('MET', 'Bldg A'),
('IET', 'Bldg B'),
('HR', 'Bldg C'),
('Medical', 'Bldg D'),
('Upper Board', 'Bldg E');

-- =========================================
-- Roles
-- =========================================
INSERT INTO Role (role_name, title, description, rank, base_salary, percentage_YOE, percentage_overtime, annual_balance, accidental_balance) VALUES
('President', 'President', 'Head of University', 1, 20000, 0.1, 50, 30, 5),
('Vice-President', 'Vice President', 'Supervises Deans', 2, 15000, 0.08, 40, 25, 5),
('Dean_MET', 'Dean', 'Head of MET Department', 3, 12000, 0.07, 30, 20, 5),
('HR_Manager', 'HR Manager', 'Manages HR Department', 3, 11000, 0.06, 25, 20, 5),
('Lecturer_IET', 'Lecturer', 'Teaching and research', 5, 8000, 0.05, 15, 15, 3);

-- =========================================
-- Employees
-- =========================================
INSERT INTO Employee (first_name, last_name, gender, email, address, years_of_experience, official_day_off, type_of_contract, employment_status, annual_balance, accidental_balance, hire_date, resignation_date, department_ID) VALUES
('Ahmed', 'Ali', 'M', 'ahmed.ali@gu.edu.eg', 'Cairo St 1', 15, 'Friday', 'full_time', 'active', 30, 5, '2010-01-15', NULL, 5),
('Mona', 'Hassan', 'F', 'mona.hassan@gu.edu.eg', 'Cairo St 2', 8, 'Saturday', 'full_time', 'active', 25, 5, '2016-03-20', NULL, 1),
('Karim', 'Saad', 'M', 'karim.saad@gu.edu.eg', 'Cairo St 3', 10, 'Friday', 'full_time', 'active', 20, 5, '2013-05-10', NULL, 2),
('Sara', 'Mahmoud', 'F', 'sara.mahmoud@gu.edu.eg', 'Cairo St 4', 3, 'Sunday', 'part_time', 'active', 0, 0, '2022-08-01', NULL, 1),
('Omar', 'Fahmy', 'M', 'omar.fahmy@gu.edu.eg', 'Cairo St 5', 5, 'Saturday', 'full_time', 'onleave', 15, 3, '2018-11-05', NULL, 3);

-- =========================================
-- Employee_Role (Many-to-Many)
-- =========================================
INSERT INTO Employee_Role (employee_ID, role_ID) VALUES
(1, 1),
(2, 3),
(3, 5),
(4, 5),
(5, 4);

-- =========================================
-- Documents
-- =========================================
INSERT INTO Document (employee_ID, type, description, filename, storage_location, size, creation_date, expiry_date, status) VALUES
(1, 'Contract', 'Permanent contract', 'contract_ahmed.pdf', '/docs/', 500, '2010-01-15', '2030-01-14', 'valid'),
(2, 'National_ID', 'ID copy', 'id_mona.pdf', '/docs/', 200, '2016-03-20', '2026-03-19', 'valid'),
(3, 'Medical', 'Health report', 'medical_karim.pdf', '/docs/', 300, '2013-05-10', '2018-05-10', 'expired'),
(4, 'Contract', 'Part-time contract', 'contract_sara.pdf', '/docs/', 250, '2022-08-01', '2023-08-01', 'expired'),
(5, 'Contract', 'Full-time contract', 'contract_omar.pdf', '/docs/', 400, '2018-11-05', '2028-11-04', 'valid');

-- =========================================
-- Attendance
-- =========================================
INSERT INTO Attendance (employee_ID, date, check_in_time, check_out_time, total_hours, status) VALUES
(1, '2025-11-17', '08:00', '16:00', 8, 'attended'),
(2, '2025-11-17', '08:30', '16:00', 7.5, 'attended'),
(3, '2025-11-17', NULL, NULL, 0, 'absent'),
(4, '2025-11-17', '09:00', '13:00', 4, 'attended'),
(5, '2025-11-17', '08:00', '12:00', 4, 'attended');

-- =========================================
-- Payroll
-- =========================================
INSERT INTO Payroll (employee_ID, from_date, to_date, payment_date, final_salary, comments, bonuses_amount, deductions_amount) VALUES
(1, '2025-11-01', '2025-11-30', '2025-11-30', 21000, 'Monthly salary', 500, 0),
(2, '2025-11-01', '2025-11-30', '2025-11-30', 13000, 'Monthly salary', 200, 0),
(3, '2025-11-01', '2025-11-30', '2025-11-30', 9000, 'Monthly salary', 0, 100),
(4, '2025-11-01', '2025-11-30', '2025-11-30', 3500, 'Part-time salary', 0, 0),
(5, '2025-11-01', '2025-11-30', '2025-11-30', 7000, 'Monthly salary', 100, 50);

-- =========================================
-- Deduction
-- =========================================
INSERT INTO Deduction (employee_ID, date, amount, type, status) VALUES
(3, '2025-11-17', 100, 'missing_hours', 'pending'),
(5, '2025-11-17', 50, 'unpaid', 'pending'),
(4, '2025-11-17', 0, 'missing_days', 'pending'),
(3, '2025-10-15', 200, 'missing_hours', 'finalized'),
(2, '2025-10-20', 0, 'missing_days', 'finalized');

-- =========================================
-- Leave
-- =========================================
INSERT INTO Leave (employee_ID, date_of_request, start_date, end_date, total_days, status, type) VALUES
(2, '2025-11-01', '2025-11-10', '2025-11-14', 5, 'approved', 'annual'),
(5, '2025-11-05', '2025-11-18', '2025-11-18', 1, 'pending', 'accidental'),
(4, '2025-11-02', '2025-11-12', '2025-11-13', 2, 'rejected', 'unpaid'),
(3, '2025-11-03', '2025-11-15', '2025-11-16', 2, 'approved', 'medical'),
(1, '2025-11-04', '2025-12-01', '2025-12-01', 1, 'pending', 'compensation');

-- =========================================
-- Performance
-- =========================================
INSERT INTO Performance (employee_ID, rating, comment, semester) VALUES
(1, 5, 'Excellent leadership', 'W25'),
(2, 4, 'Good teaching', 'W25'),
(3, 3, 'Satisfactory work', 'W25'),
(4, 5, 'Outstanding support', 'W25'),
(5, 2, 'Needs improvement', 'W25');

-- =========================================
-- Employee_Replace_Employee
-- =========================================
INSERT INTO Employee_Replace_Employee (emp_1, emp_2, from_date, to_date) VALUES
(2, 5, '2025-11-10', '2025-11-14'),
(3, 1, '2025-11-15', '2025-11-16'),
(4, 2, '2025-11-12', '2025-11-13'),
(5, 3, '2025-11-18', '2025-11-18'),
(1, 4, '2025-12-01', '2025-12-01');
