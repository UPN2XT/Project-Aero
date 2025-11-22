CREATE ROLE HR
GO
CREATE FUNCTION HRLoginValidation(@Employee_ID int, @Password varchar(50))--this has error invlaid column name for employee_ID and password
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

-- as3: major change turns out aprovals are pre put into the table so insert got changed to set
-- as3: two important requirments are missing hr is supposed to be the last one approving ie the status of the leave entity itself should change
-- as3: a PRODUCER to check if the leave was rejected and update it is required

CREATE PROCEDURE HR_approval_an_acc--11/14 dont we need to check if the employee is full time or not? as3: yes this needs to be fixed
    @request_ID int,
    @HR_ID int
AS
BEGIN
    IF @request_ID IN (                                                                                                SELECT request_id
        FROM Accidental_Leave
    UNION
        SELECT request_id
        FROM Annual_Leave)
UPDATE Employee_Approve_Leave
    SET status = CASE WHEN EXISTS (SELECT request_id
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
    WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
END
GO

CREATE PROCEDURE HR_approval_unpaid
    @request_ID int,
    @HR_ID int
AS
BEGIN
    IF @request_ID IN (SELECT request_id
    FROM Unpaid_Leave)
UPDATE Employee_Approve_Leave
    SET status =
            CASE WHEN 30 > (
				SELECT COUNT(*)
    FROM Unpaid_Leave
        INNER JOIN Leave ON Unpaid_Leave.request_id = Leave.request_id
    WHERE Unpaid_Leave.emp_ID IN (
		SELECT emp_id
        FROM Unpaid_Leave u
            INNER JOIN Employee e on u.emp_ID = e.Employee_ID
        WHERE u.request_id = @request_id
            AND
            e.type_of_contract = 'Full time'--11/14 added this part since part-time employees are not eligible so assuming they can still request one, it should be rejected
				) AND YEAR(GETDATE()) = YEAR(Leave.start_date) -- Need to check if max unpaid leave is in the same year or not
			) THEN 'Approved'
			ELSE 'Rejected'
			END
		WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
END
GO

CREATE PROCEDURE HR_approval_comp
    @request_ID int,
    @HR_ID int
AS
BEGIN
    IF @request_ID IN (SELECT request_id
    FROM Compensation_Leave)
UPDATE Employee_Approve_Leave
       SET status =
    
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
		WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
END
GO

-- 3.4 (g) TODO -- as2 note: g requires recursion or a more complex way of inserion that current ones or a way to devide the leaves according to month

-- as2: the query is way too complex and I am not sure if its cully correct 
CREATE PROCEDURE Deduction_hours
    @employee_ID int
AS
BEGIN
    DECLARE @rate DECIMAL(10,2);
    SET @rate = Get_Salary(@employee_id) / 176;
    WITH
        q1
        AS
        (
            SELECT SUM(duration) AS dur,
                MONTH(Attendance.date) AS month,
                YEAR(Attendance.date) AS year
            FROM attencence
            GROUP BY 
            MONTH(Attendance.date),
            YEAR(Attendance.date)
            HAVING hours < 176
                AND NOT EXISTS (
                SELECT *
                FROM Deduction d
                    INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
                WHERE Deduction.emp_id = @employee_id
                    AND Month(a.date) = month AND YEAR(a.date) = YEAR
                    AND d.type = 'Missing hours'--why was this made? dont we need to find the first day which has less than 8 hours?
            )
        )
    INSERT INTO Deduction
        (emp_ID, date, amount, attendance_ID, type)
    SELECT
        @employee_id,
        '01-01-2001', /*placeholder becuase i am not sure what the date should be exactly
                        11-14 part of me belives that it should be related to the first day they get a deduction on */
        ((176-dur) * @rate),
        (
                SELECT TOP 1
            ae.attendance_id
        FROM Attendance ae
        WHERE YEAR(ae.date) = year AND MONTH(ae.date) = month
            AND ae.duration < 8
        ORDER BY ae.date
            ),
        'Missing hours'
    FROM q1

END
GO

-- as2: not 100% sure about this
CREATE PROCEDURE Deduction_days
    @employee_ID int
AS
BEGIN
    DECLARE @amount DECIMAL(10,2);
    SET @amount = Get_Salary(@employee_id) / 22;
    INSERT INTO Deduction
        (emp_ID, date, amount, attendance_ID, type)
    SELECT
        @employee_id,
        Attendance.date,
        @amount,
        Attendance.attendance_ID,
        'Missing days'
    FROM Attendance
    WHERE Attendance.status = 'Absent'
        AND Attendance.attendance_ID NOT IN (
            SELECT attendance_ID
        FROM Deduction
        WHERE Deduction.emp_id = @employee_ID
        )

END
GO
/*
	Questions?
	is the overtime calulated for last 30 days? month? this month? this needs answering
	is overtime calculated if an employee stays more than 8 hours for a day or is it for total hours

*/

CREATE FUNCTION Get_Salary(@employee_id INT)--invalid column name here with employee_ID
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE @Salary DECIMAL(10,2);
    SELECT @Salary = e.salary
    FROM Employee e
    WHERE e.employee_ID = @employee_id;
    RETURN @Salary;
END
GO

CREATE FUNCTION Bonus_amount(@employee_ID INT)--invalid column name here with employee_ID
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
    WHERE e.employee_ID = @employee_id;

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
            GETDATE(), (Get_Salary(@Employee_id) + @Bouns_amount_val - @Deduction_amount_val),
            @From,
            @To,
            @Bouns_amount_val,
            @Deduction_amount_val
	)
END
GO

CREATE FUNCTION get_approval_status(@Request_ID INT, @Dep_name VARCHAR(50), @Min_Rank INT)
RETURNS VARCHAR(50)
AS
BEGIN
    RETURN CASE WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name = @Dep_name
            AND get_rank(employee_id) <= @Min_Rank
    WHERE Leave_ID = @request_id
        AND [status] = 'Approved'
) THEN 'Approved'
WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name = @Dep_name
    WHERE Leave_ID = @request_id
        AND [status] = 'Rejected'
        AND get_rank(employee_id) <= @Min_Rank
) THEN 'Rejected'
ELSE 'Pending'
END
END
GO

CREATE FUNCTION get_approval_status_pres(@Request_ID INT)
RETURNS VARCHAR(50)
AS
BEGIN
    RETURN CASE WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name IS NULL
            AND get_rank(employee_id) = 1
    WHERE Leave_ID = @request_id
        AND [status] = 'Approved'
) THEN 'Approved'
WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name = @Dep_name
    WHERE Leave_ID = @request_id
        AND dept_name IS NULL
        AND get_rank(employee_id) = 1
) THEN 'Rejected'
ELSE 'Pending'
END
END
GO

CREATE PROCEDURE auto_update_accedintal_leave
    @request_id INT
AS
BEGIN
    UPDATE Leave
SET [status] =  get_approval_status(@request_id, 'HR', 4)
WHERE request_id = @request_id
END
GO

CREATE PROCEDURE auto_update_Medical_leave
    @request_id INT
AS
BEGIN
    UPDATE Leave
SET [status] = get_approval_status(@request_id, 'HR', 4)
WHERE request_id = @request_id
END
GO

CREATE PROCEDURE auto_update_Unpaid_leave_vdean
    @request_id INT
AS
BEGIN
    Declare @pre_approval_status VARCHAR(50) = get_approval_status_pres(@request_id)
    DECLARE @hr_approval VARCHAR(50) = get_approval_status(@request_id, 'HR', 4)
    DECLARE @Status VARCHAR(50) = CASE WHEN @pre_approval_status = 'Approved' AND @hr_approval = 'Approved' THEN 'Approved'
    WHEN @pre_approval_status = 'Rejected' OR @hr_approval = 'Rejected' THEN 'Rejected'
    ELSE 'Pending'
    END
    UPDATE Leave
SET [status] = @Status
WHERE request_id = @request_id
END
GO
CREATE PROCEDURE auto_update_Unpaid_leave
    @request_id INT
AS
BEGIN
    DECLARE @Emp_dep VARCHAR(50)
    DECLARE @emp_id INT

    SELECT TOP 1
        @Emp_dep = Emp_ID
    FROM Unpaid_Leave
    WHERE request_id = @Request_id

    DECLARE @Rank INT = get_rank(@emp_id);

    IF ((@Rank = 4 OR @Rank = 3) AND @Emp_dep != 'HR') 
        THEN auto_update_Unpaid_leave_vdean
    (@request_id)
    ELSE
    IF ()
    DECLARE @higher_ranking_approval VARCHAR(50) = get_approval_status(@request_id, 'HR', 4)
END

DECLARE @higher_ranking_approval VARCHAR(50) = get_approval_status(@request_id, 'HR', 4)
UPDATE Leave
SET [status] = get_approval_status(@request_id, 'HR', 4)
WHERE request_id = @request_id
END
GO



