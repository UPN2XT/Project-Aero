USE University_HR_ManagementSystem_Team_97;
GO

---------------------------------------------------------------------
-- STEP 1: Create the Helper Function (Required for Admin Proc)
-- (Fixed version of Is_On_Leave from File 2.5)
---------------------------------------------------------------------
CREATE OR ALTER FUNCTION Is_On_Leave(@employee_ID INT, @from DATE, @to DATE)
RETURNS BIT
AS
BEGIN
    DECLARE @Onleave BIT = 0;
    -- Check against LEAVE table + Sub-tables
    IF EXISTS (
        SELECT 1
        FROM LEAVE AS l
        INNER JOIN (
            SELECT request_id FROM Annual_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Accidental_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Medical_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Unpaid_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Compensation_Leave WHERE emp_id = @Employee_ID
        ) AS subleaves ON l.request_id = subleaves.request_id
        INNER JOIN Employee e ON e.employee_id = @employee_ID
        WHERE 
            -- Overlap logic: (Start <= EndRequest) and (End >= StartRequest)
            l.start_date <= @to AND l.end_date >= @from
            AND NOT (e.employment_status = 'Resigned')
            AND l.final_approval_status IN ('Approved', 'Pending')
    )
    SET @Onleave = 1;

    RETURN @Onleave;
END
GO

---------------------------------------------------------------------
-- STEP 2: Create/Fix the Admin Procedures (File 2.3)
---------------------------------------------------------------------

-- 2.3 (a) Update_Status_Doc
CREATE OR ALTER PROCEDURE Update_Status_Doc
AS
UPDATE Document SET status = 'expired' WHERE GETDATE() > expiry_date;
GO

-- 2.3 (b) Remove_Deductions
CREATE OR ALTER PROCEDURE Remove_Deductions
AS
DELETE d FROM Deduction d
INNER JOIN Employee e on d.emp_ID = e.employee_ID
WHERE e.employment_status ='resigned';
GO

-- 2.3 (c) Update_Employment_Status (FIXED: Added dates to Is_On_Leave)
CREATE OR ALTER PROCEDURE Update_Employment_Status
    @Employee_ID int
AS
BEGIN
    UPDATE Employee
    SET employment_status = CASE
            WHEN employment_status In ('notice_period', 'resigned') THEN employment_status
            -- FIX: Passed GETDATE() for both dates
            WHEN dbo.Is_On_Leave(@Employee_ID, GETDATE(), GETDATE()) = 1 THEN 'onleave' 
            ELSE 'active'
        END 
    WHERE employee_ID = @Employee_ID;
END
GO

-- 2.3 (d) Create_Holiday
CREATE OR ALTER PROCEDURE Create_Holiday
AS
BEGIN
    IF OBJECT_ID('Holiday', 'U') IS NULL
    BEGIN
        CREATE TABLE Holiday (
            Holiday_ID INT PRIMARY KEY IDENTITY,
            name VARCHAR(50),
            from_date date,
            to_date date
        );
    END
END
GO

-- 2.3 (e) Add_Holiday
CREATE OR ALTER PROCEDURE Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date date,
    @to_date date
AS
INSERT INTO Holiday (name,from_date,to_date) VALUES(@holiday_name, @from_date, @to_date);
GO

-- 2.3 (f) Intitiate_Attendance
CREATE OR ALTER PROCEDURE Intitiate_Attendance
AS
BEGIN
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    INSERT INTO Attendance ([date], [status], emp_ID)
    SELECT @CurrentDate, 'absent', E.employee_ID
    FROM Employee E
    WHERE E.employment_status = 'active'
    AND E.employee_ID NOT IN (SELECT emp_ID FROM Attendance WHERE [date] = @CurrentDate);
END 
GO

-- 2.3 (g) Update_Attendance
CREATE OR ALTER PROCEDURE Update_Attendance
    @Employee_id int,
    @check_in time,
    @check_out time
AS
UPDATE Attendance
SET status = 'attended', check_in_time = @check_in, check_out_time = @check_out
WHERE emp_ID = @Employee_id AND date = CAST(GETDATE() AS DATE);
GO

-- 2.3 (h) Remove_Holiday (FIXED: Added alias 'h')
CREATE OR ALTER PROCEDURE Remove_Holiday
AS
BEGIN
    -- 1. Identify the Attendance IDs that fall on a holiday
    DECLARE @AttendanceToRemove TABLE (ID INT);
    
    INSERT INTO @AttendanceToRemove (ID)
    SELECT A.attendance_ID
    FROM Attendance A
    INNER JOIN Holiday h ON A.date BETWEEN h.from_date AND h.to_date;

    -- 2. Delete the linked Deductions first (Fixes the FK Conflict)
    DELETE FROM Deduction
    WHERE attendance_ID IN (SELECT ID FROM @AttendanceToRemove);

    -- 3. Now it is safe to delete the Attendance records
    DELETE FROM Attendance
    WHERE attendance_ID IN (SELECT ID FROM @AttendanceToRemove);
END
GO

-- 2.3 (i) Remove_DayOff
CREATE OR ALTER PROCEDURE Remove_DayOff
    @Employee_id int
AS
DELETE FROM Attendance 
WHERE emp_ID = @Employee_id 
AND DATENAME(WEEKDAY, Attendance.date) IN (
    SELECT official_day_off FROM Employee WHERE @Employee_id = Employee.employee_ID
);
GO

-- 2.3 (j) Remove_Approved_Leaves
CREATE OR ALTER PROCEDURE Remove_Approved_Leaves
    @Employee_id int
AS
DELETE FROM Attendance
WHERE emp_ID = @Employee_id
AND EXISTS (
    SELECT 1
    FROM LEAVE l
    INNER JOIN (                                                       
        SELECT request_ID, emp_ID FROM Annual_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Accidental_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Medical_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Unpaid_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Compensation_Leave
    ) AS subleaves ON l.request_ID = subleaves.request_ID
    WHERE subleaves.emp_ID = @Employee_id 
    AND l.final_approval_status = 'approved'
    AND Attendance.date BETWEEN l.start_date AND l.end_date
);
GO

-- 2.3 (k) Replace_employee (FIXED: Added dates to Is_On_Leave)
CREATE OR ALTER PROCEDURE Replace_employee
    @Emp1_ID int,
    @Emp2_ID int,
    @from_date date,
    @to_date date
AS
BEGIN
    IF @from_date > @to_date BEGIN PRINT 'Error: Start > End'; RETURN; END
    IF @Emp1_ID = @Emp2_ID BEGIN PRINT 'Error: Same Emp'; RETURN; END

    IF EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @Emp2_ID AND employment_status = 'resigned')
    BEGIN PRINT 'Error: Emp2 resigned'; RETURN; END

    DECLARE @Dept1 varchar(50), @Dept2 varchar(50);
    SELECT @Dept1 = dept_name FROM Employee WHERE employee_ID = @Emp1_ID;
    SELECT @Dept2 = dept_name FROM Employee WHERE employee_ID = @Emp2_ID;

    IF @Dept1 <> @Dept2 BEGIN PRINT 'Error: Different Depts'; RETURN; END

    -- FIX: Using 3 args
    IF dbo.Is_On_Leave(@Emp1_ID, @from_date, @to_date) = 0
    BEGIN PRINT 'Error: Emp1 is not on leave'; RETURN; END

    -- FIX: Using 3 args
    IF dbo.Is_On_Leave(@Emp2_ID, @from_date, @to_date) = 1
    BEGIN PRINT 'Error: Emp2 is on leave'; RETURN; END;

    INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO

---------------------------------------------------------------------
-- STEP 3: RUN THE TESTS
---------------------------------------------------------------------
PRINT '===================================================';
PRINT 'STARTING ADMIN PROCEDURES TEST';
PRINT '===================================================';

-- Test A
PRINT '>>> TEST 2.3.a: Update_Status_Doc';
INSERT INTO Document (type, description, file_name, creation_date, expiry_date, status, emp_ID)
VALUES ('TestDoc', 'Expired', 'TestFile1', '2020-01-01', DATEADD(day, -1, GETDATE()), 'valid', 1);
EXEC Update_Status_Doc;
SELECT count(*) as 'Expired Docs (Should be > 0)' FROM Document WHERE file_name='TestFile1' AND status='expired';

-- Test D & E
PRINT '>>> TEST 2.3.d/e: Holidays';
EXEC Create_Holiday;
EXEC Add_Holiday 'TestDay', '2025-01-01', '2025-01-02';
SELECT * FROM Holiday WHERE name='TestDay';

-- Test F
PRINT '>>> TEST 2.3.f: Initiate Attendance';
EXEC Intitiate_Attendance;
SELECT count(*) as 'Attendance Records Today' FROM Attendance WHERE date = CAST(GETDATE() AS DATE);

PRINT '===================================================';
PRINT 'TESTS COMPLETE - IF YOU SEE RESULTS ABOVE, IT WORKED';
PRINT '===================================================';