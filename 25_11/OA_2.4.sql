USE University_HR_ManagementSystem_Team_97;
GO

CREATE FUNCTION HRLoginValidation(@Employee_ID int, @Password varchar(50))
RETURNS bit
AS
BEGIN
    DECLARE @ISVALID BIT = 0;
    IF EXISTS(SELECT 1
    FROM Employee e
    WHERE @Employee_ID = e.employee_ID
        AND @Password = e.[password]
        AND e.dept_name = 'HR')
        SET @ISVALID = 1;
    RETURN @ISVALID;
END
GO

CREATE FUNCTION Get_Salary(@employee_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @FinalSalary DECIMAL(10,2);
    DECLARE @BaseSalary DECIMAL(10,2);
    DECLARE @PercYOE DECIMAL(4,2);
    DECLARE @YearsExp INT;

    SELECT @YearsExp = years_of_experience
    FROM Employee
    WHERE employee_ID = @employee_id;

    SELECT TOP 1
        @BaseSalary = r.base_salary,
        @PercYOE = r.percentage_YOE
    FROM Role r
        INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.emp_ID = @employee_id
    ORDER BY r.rank ASC;

    IF @BaseSalary IS NULL SET @BaseSalary = 0;

    SET @FinalSalary = @BaseSalary + (@YearsExp * (@PercYOE / 100.0) * @BaseSalary);
    RETURN @FinalSalary;
END
GO

CREATE FUNCTION Bonus_amount(@employee_ID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Bonus DECIMAL(10,2);
    DECLARE @Salary DECIMAL(10,2) = dbo.Get_Salary(@employee_ID);
    DECLARE @TotalHours INT;
    DECLARE @OvertimeFactor DECIMAL(4,2);

    SELECT @TotalHours = SUM(DATEDIFF(HOUR, check_in_time, check_out_time))
    FROM Attendance
    WHERE emp_ID = @employee_ID AND MONTH(date) = MONTH(GETDATE()) AND YEAR(date) = YEAR(GETDATE());

    SELECT TOP 1
        @OvertimeFactor = r.percentage_overtime
    FROM Role r
        INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.emp_ID = @employee_ID
    ORDER BY r.rank ASC;

    IF @TotalHours > 176
        SET @Bonus = (@Salary / 176.0) * (@OvertimeFactor) * (@TotalHours - 176);
    ELSE 
        SET @Bonus = 0;

    RETURN ISNULL(@Bonus, 0);
END
GO

CREATE FUNCTION get_approval_status(@Request_ID INT, @Dep_name VARCHAR(50), @Min_Rank INT)
RETURNS VARCHAR(50)
AS
BEGIN
    RETURN CASE 
        WHEN EXISTS (
            SELECT Emp1_ID
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_ID = Emp1_ID AND dept_name = @Dep_name AND dbo.get_rank(employee_ID) <= @Min_Rank
    WHERE Leave_ID = @request_id AND lower([status]) = 'approved'
        ) THEN 'approved'
        WHEN EXISTS (
            SELECT Emp1_ID
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = Emp1_ID AND dept_name = @Dep_name
    WHERE Leave_ID = @request_id AND LOWER([status]) = 'rejected' AND dbo.get_rank(employee_id) <= @Min_Rank
        ) THEN 'rejected'
        ELSE 'pending'
    END
END
GO

CREATE FUNCTION get_approval_status_pres(@Request_ID INT)
RETURNS VARCHAR(50)
AS
BEGIN
    RETURN CASE 
        WHEN EXISTS (
            SELECT Emp1_ID
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = Emp1_ID AND dept_name IS NULL AND dbo.get_rank(employee_id) = 1
    WHERE Leave_ID = @request_id AND LOWER([status]) = 'approved'
        ) THEN 'approved'
        WHEN EXISTS (
            SELECT Emp1_ID
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = Emp1_ID
    WHERE Leave_ID = @request_id AND dbo.get_rank(employee_id) = 1 AND LOWER([status]) = 'rejected'
        ) THEN 'rejected'
        ELSE 'pending'
    END
END
GO

CREATE PROCEDURE Add_Payroll
    @Employee_ID INT,
    @From DATE,
    @TO DATE
AS
BEGIN
    DECLARE @FinalSalary DECIMAL(10,2) = dbo.Get_Salary(@Employee_ID);
    DECLARE @Bonus DECIMAL(10,2) = dbo.Bonus_amount(@Employee_ID);
    DECLARE @Deduction DECIMAL(10,2);

    SELECT @Deduction = ISNULL(SUM(amount), 0)
    FROM Deduction
    WHERE emp_ID = @Employee_ID AND date BETWEEN @From AND @To;

    INSERT INTO Payroll
        (payment_date, final_salary_amount, from_date, to_date, bonus_amount, deductions_amount, emp_ID)
    VALUES
        (GETDATE(), (@FinalSalary + @Bonus - @Deduction), @From, @To, @Bonus, @Deduction, @Employee_ID);

    UPDATE Deduction SET status = 'finalized' WHERE emp_ID = @Employee_ID AND date BETWEEN @From AND @To;
END
GO

CREATE PROCEDURE Deduction_hours
    @employee_ID int
AS
BEGIN
    DECLARE @HourlyRate DECIMAL(10, 2) = (dbo.Get_Salary(@employee_ID) / 22.0) / 8.0;

    INSERT INTO Deduction
        (emp_ID, [date], amount, attendance_ID, [type])
    SELECT
        @employee_ID, A.date, (8 - DATEDIFF(HOUR, A.check_in_time, A.check_out_time)) * @HourlyRate,
        A.attendance_ID, 'missing_hours'
    FROM Attendance A
    WHERE A.emp_ID = @employee_ID AND lower(A.status) = 'attended'
        AND DATEDIFF(HOUR, A.check_in_time, A.check_out_time) < 8
        AND NOT EXISTS (SELECT 1
        FROM Deduction d
        WHERE d.attendance_ID = A.attendance_ID AND d.type = 'missing_hours');
END
GO

CREATE PROCEDURE Deduction_days
    @employee_ID int
AS
BEGIN
    DECLARE @DailyRate DECIMAL(10, 2) = (dbo.Get_Salary(@employee_ID) / 22.0);
    DECLARE @OfficialDayOff VARCHAR(50);
    SELECT @OfficialDayOff = official_day_off
    FROM Employee
    WHERE employee_ID = @employee_ID;

    INSERT INTO Deduction
        (emp_ID, date, amount, attendance_ID, type)
    SELECT
        @employee_ID, A.date, @DailyRate, A.attendance_ID, 'missing_days'
    FROM Attendance A
    WHERE A.emp_ID = @employee_ID AND lower(A.status) = 'absent'
        AND DATENAME(WEEKDAY, A.date) <> @OfficialDayOff
        AND dbo.Is_On_Leave(@employee_ID, A.date, A.date) = 0
        AND NOT EXISTS (SELECT 1
        FROM Deduction d
        WHERE d.attendance_ID = A.attendance_ID)
        AND NOT EXISTS (SELECT 1
        FROM Holiday h
        WHERE a.date BETWEEN h.from_date AND h.to_date);
END
GO

CREATE PROCEDURE Deduction_unpaid
    @employee_ID int
AS
BEGIN
    DECLARE @DailyRate DECIMAL(10, 2) = (dbo.Get_Salary(@employee_ID) / 22.0);

    INSERT INTO Deduction
        (emp_ID, date, amount, type, unpaid_ID)
    SELECT
        @employee_ID, L.start_date, (L.num_days * @DailyRate), 'unpaid', UL.request_ID
    FROM Unpaid_Leave UL INNER JOIN Leave L ON UL.request_ID = L.request_ID
    WHERE UL.emp_ID = @employee_ID AND lower(L.final_approval_status) = 'approved'
        AND NOT EXISTS (SELECT 1
        FROM Deduction d
        WHERE d.unpaid_ID = UL.request_ID);
END
GO


CREATE PROCEDURE HR_approval_an_acc
    @request_ID int,
    @HR_ID int
AS
BEGIN
    DECLARE @Type VARCHAR(20);
    DECLARE @datediff int
    DECLARE @emp_id int

    select @datediff = num_days
    from Leave
    where @request_ID = request_ID

    IF EXISTS (SELECT 1
    FROM Annual_Leave
    WHERE request_ID = @request_ID) SET @Type = 'annual';
    ELSE SET @Type = 'accidental';

    UPDATE Employee_Approve_Leave
    SET status = CASE 
        WHEN lower(@Type) = 'accidental' AND (SELECT accidental_balance
        FROM Employee
        WHERE employee_ID = (SELECT emp_ID = @emp_id
        FROM Accidental_Leave
        WHERE request_ID = @request_ID)) - 1 > 0 THEN 'approved'
        WHEN lower(@Type) = 'annual' AND (SELECT annual_balance
        FROM Employee
        WHERE employee_ID = (SELECT emp_ID = @emp_id
        FROM Annual_Leave
        WHERE request_ID = @request_ID)) - @datediff > 0 THEN 'approved'
        ELSE 'rejected'
    END
    WHERE Emp1_ID = @HR_ID AND Leave_ID = @request_ID;

    IF lower(@Type) = 'accidental' and (select status
        from Employee_Approve_Leave
        where @request_ID = Leave_ID AND @HR_ID = Emp1_ID) = 'approved'
    BEGIN
        UPDATE Employee
    set accidental_balance = accidental_balance-1
    where employee_ID = @emp_id
    END

    IF lower(@Type) = 'annual' and (select status
        from Employee_Approve_Leave
        where @request_ID = Leave_ID AND @HR_ID = Emp1_ID) = 'approved'
    BEGIN
        UPDATE Employee
    set annual_balance = annual_balance - @datediff
    where employee_ID = @emp_id
    END

    IF lower(@Type) = 'annual'
        EXEC dbo.auto_update_annual @request_id;
    ELSE
        EXEC dbo.auto_update_accedintal_leave @request_id;
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
            INNER JOIN Employee e on u.emp_ID = e.employee_ID
        WHERE u.request_id = @request_id
            AND
            e.type_of_contract = 'full_time'
				) AND YEAR(GETDATE()) = YEAR(Leave.start_date) and e.annual_balance <>0
			) THEN 'approved'
			ELSE 'rejected'
			END
		WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
    EXEC dbo.auto_update_Unpaid_leave @Request_id
END
GO

CREATE PROCEDURE HR_approval_comp
    -- TODO::add exute when the function is ready
    @request_ID int,
    @HR_ID int
AS
BEGIN

    if EXISTS(
    SELECT eal.[status]
    from Employee_Approve_Leave eal
    WHERE @request_ID = eal.Leave_ID AND EXISTS(SELECT eal2.[status]
        from Employee_Approve_Leave eal2
        WHERE eal2.[status]='rejected' and @request_ID = eal.Leave_ID))
    BEGIN
        update Leave
    set final_approval_status = 'rejected'
    where @request_ID = request_ID
        print 'Error:employee within the hierarchy rejected the leave'
        RETURN;
    END;

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
			) THEN 'approved'
			ELSE 'rejected'
			END
		WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
END
GO

CREATE FUNCTION get_rank(@Employee_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @rank INT;
    SELECT TOP 1
        @rank = r.rank
    FROM Role r
        INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.emp_ID = @Employee_ID
    ORDER BY r.rank ASC;

    RETURN @rank;
END
GO

CREATE PROCEDURE auto_update_status(@request_id INT)
AS
BEGIN
    DECLARE @Status VARCHAR(50) = 'pending'
    IF EXISTS (SELECT 1
    FROM Employee_Approve_Leave
    WHERE Leave_ID = @request_id AND LOWER([status]) = 'rejected')
    SET @Status = 'rejected'
ELSE IF NOT EXISTS (SELECT 1
    FROM Employee_Approve_Leave
    WHERE Leave_ID = @request_id AND LOWER([status]) <> 'approved')
SET @Status = 'approved'
    UPDATE Leave
SET final_approval_status = @status
WHERE request_id = @request_id
    IF @Status = 'rejected'
UPDATE Employee_Approve_Leave
SET [status] = @Status
WHERE Leave_ID = @request_id
END
GO


CREATE PROCEDURE auto_update_annual_compensation
    @request_ID INT
AS
BEGIN
    DECLARE @start_date DATE, @end_date DATE, @replacement_emp INT, @user_id INT
    EXECUTE dbo.auto_update_status @request_id
    SELECT TOP 1
        @start_date = start_date, @end_date = end_date, @replacement_emp = replacement_emp,
        @user_id = emp_ID
    FROM (                                                SELECT emp_id, request_ID, replacement_emp
            FROM Annual_Leave
        UNION
            SELECT emp_ID , request_ID, replacement_emp
            FROM Compensation_Leave) AS c
        INNER JOIN Leave ON Leave.request_ID = c.request_ID
    WHERE c.request_ID = @request_ID
    IF (SELECT final_approval_status
    FROM Leave
    WHERE request_id = @request_id) = 'approved'
    EXECUTE dbo.Replace_employee @user_id, @replacement_emp, @start_date, @end_date
END
GO