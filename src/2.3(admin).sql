USE University_HR_ManagementSystem_Team_97
GO

-- bv1 checked: unit test to be created 
CREATE PROCEDURE Update_Status_Doc
AS
UPDATE Document
SET status = 'expired'
where GETDATE() > expiry_date;
GO

-- changed it to delete as it says remove
-- bv1 checked: unit test to be created 
CREATE PROCEDURE  Remove_Deductions
AS
DELETE d FROM Deduction d
    INNER JOIN Employee e on d.emp_ID = e.employee_ID
    where e.employment_status ='resigned'
GO

--bv 1: simplified query unit tests to be created
CREATE PROCEDURE Update_Employment_Status
    @Employee_ID int
AS
BEGIN
UPDATE Employee
SET employment_status = CASE
            WHEN employment_status In ('notice_period', 'resigned') THEN employment_status
            WHEN  dbo.Is_On_Leave(@Employee_ID) = 1 THEN 'onleave' 
            ELSE 'active'
        END 
WHERE employee_ID = @Employee_ID;
END
GO

-- -- bv1 checked: unit test to be created 
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

-- bv1 checked: unit test to be created 
CREATE PROCEDURE  Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date date,
    @to_date date
AS
INSERT INTO Holiday
    (name,from_date,to_date)
VALUES(@holiday_name, @from_date, @to_date);/*to date was just missing @ before it here*/
GO

/*should be working but we will still need to recheck it
11-14 still has the error of invalid column name for employment_status and employee_ID*/
-- bv1 checked: unit test to be created 
CREATE PROCEDURE Intitiate_Attendance
AS
BEGIN
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    INSERT INTO Attendance
        ([date], [status], emp_ID)
    -- 11/14 shouldnt date be changed to @CurrentDate?? and status to be written as [status]?
    SELECT
        @CurrentDate,
        'absent',
        E.employee_ID
    FROM
        Employee E
    WHERE
        E.employment_status = 'active'
        AND E.employee_ID NOT IN (
        SELECT emp_ID
        FROM Attendance
        WHERE [date] = @CurrentDate
    );
END 
GO

CREATE PROCEDURE Update_Attendance
    @Employee_id int,
    @check_in time,
    @check_out time
AS
UPDATE Attendance
SET status = 'attended',
check_in_time = @check_in,
check_out_time = @check_out
FROM Attendance
    INNER JOIN Employee on Attendance.emp_ID = Employee.employee_ID
WHERE @Employee_id = emp_ID
    AND Attendance.date = CAST(GETDATE() AS DATE) -- attencence of the given day
    /* old imp: AND Attendance.total_hours >=8 AND Employee.type_of_contract = 'Full time')
    OR (total_hours<8 AND type_of_contract<>'Part time')*/
GO

-- bv1 checked: unit test to be created 
CREATE PROCEDURE Remove_Holiday/*asked gpt here so not 100% if there is a better way*/
AS
DELETE FROM Attendance
where EXISTS(
SELECT *
FROM Holiday
where Attendance.[date] between h.from_date and h.to_date)
GO

CREATE PROCEDURE Remove_DayOff
    @Employee_id int
AS
DELETE FROM Attendance 
where DATENAME(WEEKDAY, Attendance.date) IN (
SELECT official_day_off
FROM Employee
where @Employee_id = Employee.employee_ID)
GO

-- bv1 checked: unit test to be created 
CREATE PROCEDURE  Remove_Approved_Leaves
    @Employee_id int
AS
WITH
    ApprovedLeave
    AS
    (
        SELECT l.request_ID, l.start_date, l.end_date
        FROM LEAVE l
            INNER JOIN
            (                                                       
                SELECT request_ID, emp_ID
                FROM Annual_Leave
                WHERE emp_ID = @Employee_ID
            UNION ALL
                SELECT request_ID, emp_ID
                FROM Accidental_Leave
                WHERE emp_ID = @Employee_ID
            UNION ALL
                SELECT request_ID, emp_ID
                FROM Medical_Leave
                WHERE emp_ID = @Employee_ID
            UNION ALL
                SELECT request_ID, emp_ID
                FROM Unpaid_Leave
                WHERE emp_ID = @Employee_ID
            UNION ALL
                SELECT request_ID, emp_ID
                FROM Compensation_Leave
                WHERE emp_ID = @Employee_ID
            ) AS subleaves
            ON l.request_ID = subleaves.request_ID
        WHERE l.[final_approval_status] = 'approved'
        -- bv1: need to check if pending also count as an approved leave in this case
    )
    DELETE FROM Attendance
    WHERE emp_ID = @Employee_id
    AND
    EXISTS (SELECT *
    FROM Approvedleave al
    WHERE Attendance.[date] BETWEEN al.start_date AND al.end_date)


GO

CREATE PROCEDURE Replace_employee
    @Emp1_ID int,
    @Emp2_ID int,
    @from_date date,
    @to_date date
AS
BEGIN
    IF @from_date > @to_date
    BEGIN
        PRINT 'Error: The start date cannot be after the end date.';
        RETURN;
    END

    IF @Emp1_ID = @Emp2_ID
    BEGIN
        PRINT 'Error: An employee cannot replace themselves.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 
        FROM Employee 
        WHERE employee_ID = @Emp2_ID AND employment_status = 'resigned'
    )
    BEGIN
        PRINT 'Error: The replacement employee has resigned and cannot be assigned tasks.';
        RETURN;
    END

    DECLARE @Dept1 varchar(50);
    DECLARE @Dept2 varchar(50);
    
    SELECT @Dept1 = dept_name FROM Employee WHERE employee_ID = @Emp1_ID;
    SELECT @Dept2 = dept_name FROM Employee WHERE employee_ID = @Emp2_ID;
    

    IF @Dept1 <> @Dept2
    BEGIN
        PRINT 'Error: Employees must belong to the same department.';
        RETURN;
    END

    IF dbo.Is_On_Leave(@Emp1_ID, @from_date, @to_date) = 0
    BEGIN
        PRINT 'Error: Employee 1 is not on approved/pending leave during this period, so they cannot be replaced.';
        RETURN;
    END

    IF dbo.Is_On_Leave(@Emp2_ID, @from_date, @to_date) = 1
    BEGIN
        PRINT 'Error: The replacement employee (Emp2) is on leave during this period.';
        RETURN;
    END;

    IF EXISTS (
        SELECT 1 
        FROM Employee_Replace_Employee 
        WHERE Emp1_ID = @Emp1_ID 
          AND (from_date <= @to_date AND to_date >= @from_date)
    )
    BEGIN
        PRINT 'Error: Employee 1 already has a replacement registered for this period.';
        RETURN;
    END

    INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);

END;
GO