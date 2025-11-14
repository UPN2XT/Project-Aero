CREATE ROLE Employee
GO

CREATE FUNCTION EmployeeLoginValidation(@Employee_ID int, @Password varchar(50))--invalid column name employee_ID and password here
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



CREATE FUNCTION MyPerformance--invalid object name Performance here somehow
(
    @employee_ID INT,
    @semester CHAR(3)
)
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




CREATE FUNCTION Last_month_payroll--invalid object name Payroll as well
(
    @employee_ID INT
)
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

CREATE FUNCTION MyAttendance(@employee_ID int)--not sure how we would remove the employees unoffical day off when both are different variable type
RETURNS TABLE
AS
RETURN(
SELECT * FROM Attendance a
WHERE a.emp_ID = employee_ID);
GO


CREATE FUNCTION Deductions_Attendance (@employee_ID int, @month int)
RETURNS TABLE
AS
RETURN(
SELECT * FROM Deduction d 
INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
WHERE @employee_ID = d.emp_ID  AND MONTH(d.date) = @month
)
GO

CREATE FUNCTION Is_On_Leave(@employee_ID int, @from date, @to date)
RETURNS BIT
BEGIN 
DECLARE @Onleave bit =0 
WITH AllLeaves AS (SELECT request_id,l.start_date,l.end_date
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
    )
    IF EXISTS( SELECT * FROM AllLeaves al--if anyone knows how to fix this, pls do
    WHERE al.[start_date] BETWEEN @from and @to 
    AND al.end_date BETWEEN @from and @to)
    SET @Onleave = 1
return @Onleave
END
GO
--end of 11/14 checks and update

