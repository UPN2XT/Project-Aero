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
WHERE LOWER(e.employment_status) ='resigned';
GO

CREATE PROCEDURE Update_Employment_Status
    @Employee_ID int
AS
BEGIN
    UPDATE Employee
    SET employment_status = CASE
            WHEN LOWER(employment_status) In ('notice_period', 'resigned') THEN employment_status
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
        CREATE TABLE Holiday (
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
INSERT INTO Holiday (name,from_date,to_date) VALUES(@holiday_name, @from_date, @to_date);
GO

CREATE PROCEDURE Intitiate_Attendance
AS
BEGIN
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    INSERT INTO Attendance ([date], [status], emp_ID)
    SELECT @CurrentDate, 'absent', E.employee_ID
    FROM Employee E
    WHERE LOWER(E.employment_status) = 'active'
    AND E.employee_ID NOT IN (SELECT emp_ID FROM Attendance WHERE [date] = @CurrentDate);
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
    
    INSERT INTO @AttendanceToRemove (ID)
    SELECT A.attendance_ID
    FROM Attendance A
    INNER JOIN Holiday h ON A.date BETWEEN h.from_date AND h.to_date;

    DELETE FROM Deduction
    WHERE attendance_ID IN (SELECT ID FROM @AttendanceToRemove);

    DELETE FROM Attendance
    WHERE attendance_ID IN (SELECT ID FROM @AttendanceToRemove);
END
GO

CREATE PROCEDURE Remove_DayOff
    @Employee_id int
AS
DELETE FROM Attendance 
WHERE emp_ID = @Employee_id 
AND DATENAME(WEEKDAY, Attendance.date) IN (
    SELECT official_day_off FROM Employee WHERE @Employee_id = Employee.employee_ID
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
        SELECT request_ID, emp_ID FROM Annual_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Accidental_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Medical_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Unpaid_Leave
        UNION ALL SELECT request_ID, emp_ID FROM Compensation_Leave
    ) AS subleaves ON l.request_ID = subleaves.request_ID
    WHERE subleaves.emp_ID = @Employee_id 
    AND LOWER(l.final_approval_status) = 'approved'
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
    IF @from_date > @to_date BEGIN PRINT 'Error: Start > End'; RETURN; END
    IF @Emp1_ID = @Emp2_ID BEGIN PRINT 'Error: Same Emp'; RETURN; END

    IF EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @Emp2_ID AND LOWER(employment_status) = 'resigned')
    BEGIN PRINT 'Error: Emp2 resigned'; RETURN; END

    DECLARE @Dept1 varchar(50), @Dept2 varchar(50);
    SELECT @Dept1 = dept_name FROM Employee WHERE employee_ID = @Emp1_ID;
    SELECT @Dept2 = dept_name FROM Employee WHERE employee_ID = @Emp2_ID;

    IF @Dept1 <> @Dept2 BEGIN PRINT 'Error: Different Depts'; RETURN; END

    IF dbo.Is_On_Leave(@Emp1_ID, @from_date, @to_date) = 0
    BEGIN PRINT 'Error: Emp1 is not on leave'; RETURN; END

    IF dbo.Is_On_Leave(@Emp2_ID, @from_date, @to_date) = 1
    BEGIN PRINT 'Error: Emp2 is on leave'; RETURN; END;

    INSERT INTO Employee_Replace_Employee (Emp1_ID, Emp2_ID, from_date, to_date)
    VALUES (@Emp1_ID, @Emp2_ID, @from_date, @to_date);
END;
GO