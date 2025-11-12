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
    IF @request_ID IN (								
														                SELECT request_id
        FROM Accidental_Leave
    UNION
        SELECT request_id
        FROM Annual_Leave)
INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    VALUES
        (
            @request_ID,
            @HR_ID,
            CASE WHEN EXISTS (SELECT request_id
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
)
END
GO

CREATE PROCEDURE HR_approval_unpaid
    @request_ID int,
    @HR_ID int
AS
BEGIN
    IF @request_ID IN (SELECT request_id
    FROM Unpaid_Leave)
INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    VALUES
        (
            @request_ID,
            @HR_ID,
            CASE WHEN 30 > (
				SELECT COUNT(*)
            FROM Unpaid_Leave
                INNER JOIN Leave ON Unpaid_Leave.request_id = Leave.request_id
            WHERE Unpaid_Leave.emp_ID IN (
					SELECT emp_id
                FROM Unpaid_Leave u
                WHERE u.request_id = @request_id
				) AND YEAR(CURRENT_DATE) = YEAR(Leave.start_date) -- Need to check if max unpaid leave is in the same year or not
			) THEN 'Approved'
			ELSE 'Rejected'
			END
		)
END
GO

CREATE PROCEDURE HR_approval_comp
    @request_ID int,
    @HR_ID int
AS
BEGIN
    IF @request_ID IN (SELECT request_id
    FROM Compensation_Leave)
INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    VALUES
        (
            @request_ID,
            @HR_ID,
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
		)
END
GO

-- 3.4 (e, f, g) TODO

CREATE PROCEDURE Deduction_days
    @employee_ID int
AS
BEGIN
    INSERT INTO Deduction
        (emp_ID, )
END
GO
/*
	Questions?
	is the overtime calulated for last 30 days? month? this month? this needs answering
	is overtime calculated if an employee stays more than 8 hours for a day or is it for total hours

*/

CREATE FUNCTION Get_Salary(@employee_id INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE @Salary DECIMAL(10,2);
    SELECT @Salary = e.salary
    FROM Employee e
    WHERE e.employee_id = @employee_id;
    RETURN @Salary;
END
GO

CREATE FUNCTION Bonus_amount(@employee_ID INT)
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
    WHERE e.employee_id = @employee_id;

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
            CURRENT_DATE, (Get_Salary(@Employee_id) + @Bouns_amount_val - @Deduction_amount_val),
            @From,
            @To,
            @Bouns_amount_val,
            @Deduction_amount_val
	)
END
GO

