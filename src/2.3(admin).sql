
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

/*
    Orginal before as2
CREATE PROCEDURE  Remove_Deductions/*not sure if we need to remove the record or just set the amount to 0*/
AS
UPDATE Deduction
SET amount = 0
FROM Deduction d
    INNER JOIN Employee e on d.emp_ID = e.employee_ID
where e.employment_status ='Resigned'
GO
*/

-- new in as2 needs to be rechecked
CREATE PROCEDURE Update_Employment_Status
    @Employee_ID int
AS
WITH
    ActiveLeaves
    AS
    (
                                            SELECT request_id, emp_id
            FROM Annual_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Accidental_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Medical_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Unpaid_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Compensation_Leave
            WHERE emp_id = @Employee_ID
    ),
    EmployeeStatusCheck
    AS
    (
        SELECT
            e.Emp_ID,
            e.status AS CurrentStatus,
            CASE
            WHEN e.status In ('Notice Period', 'Resigned') THEN e.status
            WHEN EXISTS (
                SELECT 1
            FROM Leave l
                INNER JOIN ActiveLeaves al ON al.request_id = l.request_id
            WHERE
                    l.final_approval_status = 'Approved' AND
                GETDATE() BETWEEN l.start_date AND l.end_date
            ) THEN 'Onleave' 
            ELSE e.status 
        END AS NewStatus
        FROM
            Employee e
        WHERE
        e.Emp_ID = @Employee_ID
    )
UPDATE e
SET status = sc.NewStatus
FROM Employee e
    INNER JOIN EmployeeStatusCheck sc ON e.Emp_ID = sc.Emp_ID
WHERE e.Emp_ID = @Employee_ID;
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
VALUES(@holiday_name, @from_date, @to_date);/*to date was just missing @ before it here*/
GO

/*should be working but we will still need to recheck it
11-14 still has the error of invalid column name for employment_status and employee_ID*/
CREATE PROCEDURE Intitiate_Attendance
AS
BEGIN
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    INSERT INTO Attendance
        (date, status, emp_ID)-- 11/14 shouldnt date be changed to @CurrentDate and status to be written as [status]?
    SELECT
        @CurrentDate,
        'Absent',
        E.employee_ID
    FROM
        Employee E
    WHERE
        E.employment_status = 'Active'
        AND E.employee_ID NOT IN (
        SELECT emp_ID
        FROM Attendance
        WHERE [date] = @CurrentDate
    );
END 
GO

/*
    could be done with if else but not sure
    as2: from what i know attendence is tied to the exsistance of a checkin or checkout 
    so i changed it to this
    also older implementaion didnt update probably it would have updated more than one record and not update ones that should be updated aswell    
*/
CREATE PROCEDURE Update_Attendance
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
WHERE @Employee_id = emp_ID
    AND Attendance.date = GETDATE() -- attencence of the given day
    /* old imp: AND Attendance.total_hours >=8 AND Employee.type_of_contract = 'Full time')
    OR (total_hours<8 AND type_of_contract<>'Part time')*/
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
where DATENAME(WEEKDAY, Attendance.date) IN (
SELECT official_day_off
FROM Employee
where @Employee_id = Employee.employee_ID)
GO

-- as2 note: this is wrong and i am too lazy to fix it whomever sees this u need to get all leaves that are approved for a given employee then remove them you will need to union all leave tables for this
--changed it to like what you said omar BUT i added join with the actual leave table and filtered them with status = approved
CREATE PROCEDURE  Remove_Approved_Leaves
    @Employee_id int
AS
WITH ApprovedLeave AS (SELECT request_id,l.start_date,l.end_date
            FROM LEAVE l
        INNER JOIN (
            SELECT request_id,emp_ID
            FROM Annual_Leave 
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Accidental_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Medical_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Unpaid_Leave
            WHERE emp_id = @Employee_ID
        UNION ALL
            SELECT request_id, emp_id
            FROM Compensation_Leave
            WHERE emp_id = @Employee_ID
            ) AS subleaves
            ON l.request_id=subleaves.request_id
            WHERE [status] ='Approved'
    )
    DELETE FROM Attendance
    WHERE emp_ID = @Employee_id 
    AND 
    EXISTS (SELECT * FROM Approvedleave
    WHERE Attendance.[date] BETWEEN al.start_date AND al.end_date)


GO

-- end of as2 check by omar ahmed

CREATE PROCEDURE Replace_employee/*not sure if its just let emp1 from the table be 2 and 2 be 1 or not so will check later*/
    @Emp1_ID int,
    @Emp2_ID int,
    @from_date date,
    @to_date date
AS
GO