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
FROM Performance --invalid object name Performance here somehow, maybe drop the table and do it again
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
FROM Payroll --invalid object name Payroll as well
WHERE emp_ID = @employee_ID -- wtf is happening here?
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


CREATE FUNCTION Deductions_Attendance (@employee_ID int, @month int)
RETURNS TABLE
AS
RETURN(
SELECT *
FROM Deduction d
    INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
WHERE @employee_ID = d.emp_ID AND MONTH(d.date) = @month
)
GO

-- as3 fixed by gemini
-- IMPORTANT NOTE: 
-- "treat it as approved for verification purposes." This implies checking the status 
-- from the LEAVE table. our query doesn't check status at all
CREATE FUNCTION Is_On_Leave(@employee_ID INT, @from DATE, @to DATE)

-- Goal: Verify whether the employee will be on leave during the specified period...
-- treat it as approved for verification purposes
RETURNS BIT
AS
BEGIN
    DECLARE @Onleave BIT = 0;

    IF EXISTS (
        -- We moved the logic from the CTE directly into this subquery
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
        ) AS subleaves
        ON l.request_id = subleaves.request_id
    WHERE NOT (l.end_date < @from OR l.start_date > @to) -- The overlap check
    )
        SET @Onleave = 1;

    RETURN @Onleave;
END
GO

/*
old imp

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

*/

--end of 11/14 checks and update

CREATE FUNCTION get_rank (@Employee_ID INT)
RETURNS INT
BEGIN
    DECLARE @rank INT;
    SELECT @rank = MAX(rank)
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
    SET @rank = get_rank(@employee_id);

    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_id = @employee_id;

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
        SELECT employee_id
    FROM Employee
    WHERE employee_id = @employee_id
        AND dept_name='HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_id, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = 'HR'
        AND r.rank < @rank
    GROUP BY employee_id
    ELSE IF EXISTS (
        SELECT employee_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE employee_id = @employee_id
        AND role_name IN ('Dean', 'Vice Dean')
    )
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_id, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE r.rank <= 2
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_id, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE (r.role_name = 'Dean' AND e.dept_name=@dep_name) OR e.dept_name = 'HR'

END GO

-- as3
CREATE FUNCTION Status_leaves(@employee_ID INT)
-- Goal: Retrieve the status of all my submitted annual and accidental leaves during the current month.
RETURNS TABLE
AS
RETURN (
        SELECT al.request_ID,
        l.date_of_request,
        al.final_approval_status AS status
    FROM Annual_Leave aL
        INNER JOIN Leave l ON al.request_ID = l.request_ID
    WHERE al.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), l.date_of_request) = 0
UNION
    SELECT acl.request_ID,
        le.date_of_request,
        acl.final_approval_status AS status
    FROM Accidental_Leave acl
        INNER JOIN Leave le ON acl.request_ID = le.request_ID
    WHERE acl.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), le.date_of_request) = 0
)
GO

-- as3
-- when rejected leave status should be updated aswll
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
                    SELECT e.employee_id
FROM Employee e
    INNER JOIN Leave l ON l.request_id = @request_ID
    INNER JOIN Annual_Leave al ON al.request_id = @request_ID
    INNER JOIN Employee e1 ON e1.employee_id = al.emp_ID
WHERE e.dept_name = e1.dept_name
    AND e.employee_id = @replacement_ID
    AND Is_On_Leave(@replacement_ID, l.start_date, end_date) = 0
                ) then 'Approved' ELSE 'Rejected'
            END
            WHERE Emp1_ID = @Upperboard_ID AND Leave_ID=@request_id
GO

-- My new function
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

-- as3 / OLD FUNCTION
-- CREATE PROCEDURE Dean_andHR_Evaluation
--     @employee_ID INT,
--     @rating INT,
--     @comment VARCHAR(40),
--     @semester CHAR(3)
-- AS
-- INSERT INTO Performance
--     (emp_ID, rating, comments, semester)
-- VALUES
--     (@employee_id, @rating, @comment, @semester)
-- GO