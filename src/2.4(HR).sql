USE University_HR_ManagementSystem_Team_97;
GO

CREATE FUNCTION HRLoginValidation(@Employee_ID int, @Password varchar(50))
RETURNS bit
BEGIN
    DECLARE @ISVALID BIT = 0;
    IF EXISTS(SELECT *
    FROM Employee e
    where @Employee_ID= e.employee_ID AND @Password = e.[password] and e.dept_name = 'HR')
    BEGIN
        SET @ISVALID = 1;
    END
    return @ISVALID
END
GO

CREATE PROCEDURE HR_approval_an_acc
    @request_ID int,
    @HR_ID int
AS
BEGIN
    IF @request_ID IN (                                                                                                                                                                                        SELECT request_id
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
    WHERE Employee.accidental_balance > 0 and Employee.type_of_contract<>'part_time'
			) THEN 'approved'
			ELSE 'rejected'
		END
		WHEN EXISTS (SELECT request_id
    FROM Annual_Leave) 
		THEN CASE WHEN
			EXISTS (
				SELECT employee_id
    FROM Employee
        INNER JOIN Annual_Leave ON Annual_Leave.emp_ID = Employee.employee_id
            AND @request_ID = Annual_Leave.request_id
    WHERE Employee.annual_balance > 0 and Employee.type_of_contract<>'part_time'
			) THEN 'approved'
			ELSE 'rejected'
		END
		ELSE 'rejected'
		END
    WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
    IF EXISTS (SELECT 1
    FROM Annual_Leave
    WHERE request_id = @request_id)
    EXEC dbo.auto_update_annual @request_id;
   ELSE
    EXEC dbo.auto_update_accedintal_leave @request_id
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
				) AND YEAR(GETDATE()) = YEAR(Leave.start_date)
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

CREATE PROCEDURE Deduction_hours
    @employee_ID int
AS
BEGIN
    DECLARE @HourlyRate DECIMAL(10, 2);
    DECLARE @Salary DECIMAL(10, 2);

    SELECT @Salary = salary
    FROM Employee
    WHERE employee_ID = @employee_ID;

    SET @HourlyRate = (@Salary / 22.0) / 8.0;

    INSERT INTO Deduction
        (emp_ID, [date], amount, attendance_ID, [type])
    SELECT
        @employee_ID,

        CAST(GETDATE() AS DATE),

        Shortfalls.TotalMissingHours * @HourlyRate,

        (SELECT TOP 1
            a.attendance_ID
        FROM Attendance a
        WHERE a.emp_ID = @employee_ID
            AND MONTH(a.date) = Shortfalls.MonthVal
            AND YEAR(a.date) = Shortfalls.YearVal
            AND DATEDIFF(hour, a.check_in_time, a.check_out_time) < 8
        ORDER BY a.date ASC),

        'Missing hours'
    FROM (
        SELECT
            MONTH(date) AS MonthVal,
            YEAR(date) AS YearVal,
            SUM(8 - DATEDIFF(hour, check_in_time, check_out_time)) AS TotalMissingHours
        FROM Attendance
        WHERE emp_ID = @employee_ID
            AND status = 'Attended'
            AND DATEDIFF(hour, check_in_time, check_out_time) < 8
        GROUP BY MONTH(date), YEAR(date)
    ) AS Shortfalls
    WHERE NOT EXISTS (
        SELECT 1
    FROM Deduction d
    WHERE d.emp_ID = @employee_ID
        AND MONTH(d.date) = Shortfalls.MonthVal
        AND YEAR(d.date) = Shortfalls.YearVal
        AND d.type = 'Missing hours'
    );
END;
GO

CREATE PROCEDURE Deduction_days
    @employee_ID int
AS
BEGIN
    DECLARE @DailyRate DECIMAL(10, 2);
    DECLARE @OfficialDayOff VARCHAR(50);

    SELECT @DailyRate = (salary / 22.0),
        @OfficialDayOff = official_day_off
    FROM Employee
    WHERE employee_ID = @employee_ID;

    INSERT INTO Deduction
        (emp_ID, date, amount, attendance_ID, type)
    SELECT
        @employee_ID,
        a.date,
        @DailyRate,
        a.attendance_ID,
        'missing_days'
    FROM Attendance a
    WHERE a.emp_ID = @employee_ID
        AND a.status = 'Absent'

        AND DATENAME(WEEKDAY, a.date) <> @OfficialDayOff

        AND NOT EXISTS (
          SELECT 1
        FROM Holiday h
        WHERE a.date BETWEEN h.from_date AND h.to_date
      )
        AND dbo.Is_On_Leave(@employee_ID, a.date, a.date) = 0

        AND NOT EXISTS (
          SELECT 1
        FROM Deduction d
        WHERE d.attendance_ID = a.attendance_ID
      );
END;
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
    -- TODO Last day of the month


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
END
GO

CREATE PROCEDURE Add_Payroll
    @Employee_ID INT,
    @From DATE,
    @TO DATE
AS
BEGIN
    DECLARE @Bouns_amount_val DECIMAL(10,2);
    DECLARE @Deduction_amount_val DECIMAL(10,2);
    SET @Bouns_amount_val = dbo.Bonus_amount(@Employee_ID);

    SELECT @Deduction_amount_val = SUM(amount)
    FROM Deduction
    WHERE emp_ID = @Employee_id AND date BETWEEN @TO AND @FROM;

    INSERT INTO Payroll
        (payment_date, final_salary_amount, from_date, to_date, bonus_amount, deductions_amount)
    VALUES
        (
            GETDATE(), (dbo.Get_Salary(@Employee_id) + @Bouns_amount_val - @Deduction_amount_val),
            @From,
            @To,
            @Bouns_amount_val,
            @Deduction_amount_val
	)
    UPDATE deduction
    SET [status] = 'finalized'
    WHERE date BETWEEN @From AND @To
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
            AND dbo.get_rank(employee_id) <= @Min_Rank
    WHERE Leave_ID = @request_id
        AND [status] = 'approved'
) THEN 'approved'
WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name = @Dep_name
    WHERE Leave_ID = @request_id
        AND LOWER([status]) = 'rejected'
        AND dbo.get_rank(employee_id) <= @Min_Rank
) THEN 'rejected'
ELSE 'pending'
END
END
GO

CREATE FUNCTION get_approval_status_pres(@Request_ID INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Dep_name varchar(50)
    RETURN CASE WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name IS NULL
            AND dbo.get_rank(employee_id) = 1
    WHERE Leave_ID = @request_id
        AND LOWER([status]) = 'approved'
) THEN 'approved'
WHEN EXISTS (
    SELECT emp_id
    FROM Employee_Approve_Leave
        INNER JOIN Employee ON employee_id = emp_id
            AND dept_name = @Dep_name
    WHERE Leave_ID = @request_id
        AND dept_name IS NULL
        AND dbo.get_rank(employee_id) = 1
) THEN 'rejected'
ELSE 'pending'
END
END
GO

CREATE PROCEDURE auto_update_accedintal_leave
    @request_id INT
AS
BEGIN
    UPDATE Leave
SET [status] =  dbo.get_approval_status(@request_id, 'HR', 4)
WHERE request_id = @request_id
END
GO

CREATE PROCEDURE auto_update_Medical_leave
    @request_id INT
AS
BEGIN
    UPDATE Leave
SET [status] = dbo.get_approval_status(@request_id, 'HR', 4)
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

    DECLARE @Rank INT = dbo.get_rank(@emp_id);
    DECLARE @Status VARCHAR(50);
    IF ((@Rank = 4 OR @Rank = 3) AND @Emp_dep != 'HR') 
    BEGIN
        Declare @pre_approval_status VARCHAR(50) = dbo.get_approval_status_pres(@request_id)
        DECLARE @hr_approval VARCHAR(50) = dbo.get_approval_status(@request_id, 'HR', 4)
        SET @Status = CASE WHEN @pre_approval_status = 'approved' AND @hr_approval = 'approved' THEN 'approved'
        WHEN @pre_approval_status = 'rejected' OR @hr_approval = 'rejected' THEN 'rejected'
        ELSE 'pending'
        END
    END

    ELSE IF (@Rank = 4 AND @Emp_dep = 'HR')
    BEGIN
        DECLARE @Hr_manger_approval VARCHAR(50) = dbo.get_approval_status(@request_id, 'HR', 3)
        DECLARE @president_approval VARCHAR(50) = dbo.get_approval_status_pres(@request_id)
        SET @Status = CASE WHEN @president_approval = 'Approved' AND @Hr_manger_approval = 'Approved' THEN 'Approved'
        WHEN @president_approval = 'Rejected' OR @Hr_manger_approval = 'Rejected' THEN 'Rejected'
        ELSE 'Pending' END

    END

    ELSE
    BEGIN
        Declare @pre_approval_status VARCHAR(50) = dbo.get_approval_status_pres(@request_id)
        DECLARE @hr_approval VARCHAR(50) = dbo.get_approval_status(@request_id, 'HR', 4)
        DECLARE @MIN_AB INT = CASE WHEN EXISTS (
            SELECT employee_id
        FROM Employee
            INNER JOIN Employee_Role er ON er.emp_id = employee_id
        WHERE er.role_name = 'Dean'
            AND dbo.Is_On_Leave(employee_id, GETDATE(), GETDATE()) = 0
            AND dept_name = @Emp_dep
        ) THEN 3 ELSE 4 END
        DECLARE @dean_dv_approval VARCHAR(50) = dbo.get_approval_status(@request_id, @Emp_dep, @MIN_AB)
        SET @Status = CASE WHEN @pre_approval_status = 'approved' AND @hr_approval = 'approved' AND @dean_dv_approval = 'approved'
        THEN 'approved' WHEN 'rejected' IN (@pre_approval_status, @hr_approval, @dean_dv_approval) THEN 'rejected'
        ELSE 'pending' END
    END
    UPDATE Leave
SET [status] = dbo.get_approval_status(@request_id, 'HR', 4)
WHERE request_id = @request_id
END
GO

CREATE PROCEDURE auto_update_annual
    @request_ID INT
AS
BEGIN
    DECLARE @Employee_ID INT;
    DECLARE @Department VARCHAR(50);
    DECLARE @Rank INT;
    DECLARE @Start_date DATE;
    DECLARE @End_date DATE;

    DECLARE @Dean_ID INT;
    DECLARE @ViceDean_ID INT;
    DECLARE @Approver_ID INT;
    DECLARE @HR_Representative_Status VARCHAR(50);
    DECLARE @UpperBoard_Status VARCHAR(50);

    SELECT
        @Employee_ID = e.ID,
        @Department = e.dept_name,
        @Start_date = l.start_date,
        @End_date = l.end_date
    FROM Employee e
        INNER JOIN Annual_Leave al ON e.employee_ID = al.emp_ID INNER JOIN [Leave] l ON al.request_ID = l.request_ID
    WHERE l.request_ID = @request_ID;

    SELECT TOP 1
        @Rank = r.rank
    FROM Role r
        INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.employee_ID = @Employee_ID
    ORDER BY r.rank ASC;

    IF @Rank >= 5 
    BEGIN
        SELECT @HR_Representative_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID
            AND er.role_name = 'HR_Representative';

        SELECT @Dean_ID = e.employee_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.employee_ID
        WHERE er.role_name = 'Dean' AND e.dept_name = @Department;

        SELECT @ViceDean_ID = e.employee_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.employee_ID
        WHERE er.role_name = 'Vice Dean' AND e.dept_name = @Department;

        IF dbo.Is_On_Leave(@Dean_ID, @Start_date, @End_date) = 1
        BEGIN
            SET @Approver_ID = @ViceDean_ID;
        END
        ELSE
        BEGIN
            SET @Approver_ID = @Dean_ID;
        END

        SELECT @UpperBoard_Status = status
        FROM Employee_Approve_Leave
        WHERE Leave_ID = @request_ID AND Emp1_ID = @Approver_ID;

        IF LOWER(@HR_Representative_Status) = 'approved' AND LOWER(@UpperBoard_Status) = 'approved'
        BEGIN
            UPDATE [Leave] SET final_approval_status = 'rpproved' WHERE request_ID = @request_ID;
        END
        ELSE IF LOWER(@HR_Representative_Status) = 'rejected' OR LOWER(@UpperBoard_Status) = 'rejected'
        BEGIN
            UPDATE [Leave] SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        END
    END

    ELSE IF (@Rank = 3 OR @Rank = 4) AND @Department <> 'HR'
    BEGIN
        SELECT @HR_Representative_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID AND er.role_name = 'HR_Representative';

        SELECT @UpperBoard_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID AND (er.role_name = 'President');

        IF LOWER(@HR_Representative_Status) = 'approved' AND LOWER(@UpperBoard_Status) = 'approved'
        BEGIN
            UPDATE [Leave] SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
        END
        ELSE IF LOWER(@HR_Representative_Status) = 'rejected' OR LOWER(@UpperBoard_Status) = 'rejected'
        BEGIN
            UPDATE [Leave] SET final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        END
    END

    ELSE IF @Rank = 4 AND @Department = 'HR'
    BEGIN
        SELECT @HR_Representative_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID AND er.role_name = 'HR Manager';

        SELECT @UpperBoard_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.Employee_ID
        WHERE eal.Leave_ID = @request_ID AND er.role_name = 'President';

        IF LOWER(@HR_Representative_Status) = 'approved' AND LOWER(@UpperBoard_Status) = 'approved'
        BEGIN
            UPDATE [Leave] SET final_approval_status = 'approved' WHERE request_ID = @request_ID;
        END
        ELSE IF (@HR_Representative_Status) = 'rejected' OR (@UpperBoard_Status) = 'rejected'
        BEGIN
            UPDATE [Leave] SET  final_approval_status = 'rejected' WHERE request_ID = @request_ID;
        END
    END
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
END
GO 

