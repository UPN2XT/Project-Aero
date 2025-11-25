USE University_HR_ManagementSystem_Team_97;
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

    if EXISTS(
    SELECT eal.[status]
    from Employee_Approve_Leave eal
    WHERE @request_ID = eal.Leave_ID AND EXISTS(SELECT eal2.[status]
        from Employee_Approve_Leave eal2
        WHERE eal2.[status]='Rejected' and @request_ID = eal.Leave_ID))
    BEGIN
        print 'Error:employee within the hierarchy rejected the leave'
        RETURN;
    END;

    IF @request_ID IN (                                                                                                                                                                SELECT request_id
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
    IF EXISTS (SELECT 1
    FROM Annual_Leave
    WHERE request_id = @request_id)
    EXEC auto_update_annual @request_id;
   ELSE
    EXEC auto_update_accedintal_leave @request_id
END
GO

CREATE PROCEDURE HR_approval_unpaid
    @request_ID int,
    @HR_ID int
AS
BEGIN

    if EXISTS(
    SELECT eal.[status]
    from Employee_Approve_Leave eal
    WHERE @request_ID = eal.Leave_ID AND EXISTS(SELECT eal2.[status]
        from Employee_Approve_Leave eal2
        WHERE eal2.[status]='Rejected' and @request_ID = eal.Leave_ID))
    BEGIN
        print 'Error:employee within the hierarchy rejected the leave'
        RETURN;
    END;

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
    EXEC auto_update_Unpaid_leave @Request_id
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
        WHERE eal2.[status]='Rejected' and @request_ID = eal.Leave_ID))
    BEGIN
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
			) THEN 'Approved'
			ELSE 'Rejected'
			END
		WHERE Emp1_ID = @HR_ID AND Leave_ID=@request_id
END
GO

-- 3.4 (g) TODO -- as2 note: g requires recursion or a more complex way of inserion that current ones or a way to devide the leaves according to month

-- as2: the query is way too complex and I am not sure if its cully correct 
/*
CREATE PROCEDURE Deduction_hours
    @employee_ID int
AS
BEGIN
    DECLARE @rate DECIMAL(10,2);
    SET @rate = Get_Salary(@employee_id) / 176 -- TODO 
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
*/

-- new 21/11
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

        /*(SELECT TOP 1 a.date 
         FROM Attendance a
         WHERE a.emp_ID = @employee_ID 
           AND MONTH(a.date) = Shortfalls.MonthVal 
           AND YEAR(a.date) = Shortfalls.YearVal 
           AND DATEDIFF(hour, a.check_in_time, a.check_out_time) < 8 
         ORDER BY a.date ASC), */

        CAST(GETDATE() AS DATE), -- current date as directed by ta

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

-- as2: not 100% sure about this
/*
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
*/
/*
	Questions?
	is the overtime calulated for last 30 days? month? this month? this needs answering
	is overtime calculated if an employee stays more than 8 hours for a day or is it for total hours

*/

-- new 21/11
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
        --CAST(GETDATE() AS DATE), -- current date as directed by ta
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
    UPDATE deduction
    SET [status] = 'Finalized'
    WHERE date BETWEEN @From AND @To
END
GO

CREATE FUNCTION get_approval_status(@Request_ID INT, @Dep_name VARCHAR(50), @Min_Rank INT)--TODO add fourth input incase of hr to know who dep they represent
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
    DECLARE @Status VARCHAR(50);
    IF ((@Rank = 4 OR @Rank = 3) AND @Emp_dep != 'HR') 
    BEGIN
        Declare @pre_approval_status VARCHAR(50) = get_approval_status_pres(@request_id)
        DECLARE @hr_approval VARCHAR(50) = get_approval_status(@request_id, 'HR', 4)
        SET @Status = CASE WHEN @pre_approval_status = 'Approved' AND @hr_approval = 'Approved' THEN 'Approved'
        WHEN @pre_approval_status = 'Rejected' OR @hr_approval = 'Rejected' THEN 'Rejected'
        ELSE 'Pending'
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
        Declare @pre_approval_status VARCHAR(50) = get_approval_status_pres(@request_id)
        DECLARE @hr_approval VARCHAR(50) = get_approval_status(@request_id, 'HR', 4)
        DECLARE @MIN_AB INT = CASE WHEN EXISTS (
            SELECT employee_id
        FROM Employee
            INNER JOIN Employee_Role er ON er.emp_id = employee_id
        WHERE er.role_name = 'Dean'
            AND Is_On_Leave(employee_id, GETDATE(), GETDATE()) = 0
            AND dept_name = @Emp_dep
        ) THEN 3 ELSE 4 END
        DECLARE @dean_dv_approval VARCHAR(50) = dbo.get_approval_status(@request_id, @Emp_dep, @MIN_AB)
        SET @Status = CASE WHEN @pre_approval_status = 'Approved' AND @hr_approval = 'Approved' AND @dean_dv_approval = 'Approved'
        THEN 'Approved' WHEN 'Rejected' IN (@pre_approval_status, @hr_approval, @dean_dv_approval) THEN 'Rejected'
        ELSE 'Pending' END
    END
    UPDATE Leave
SET [status] = get_approval_status(@request_id, 'HR', 4)
WHERE request_id = @request_id
END
GO

CREATE PROCEDURE auto_update_annual--TO DO 
    @request_ID INT
AS
BEGIN
    DECLARE @emp_approve_emp VARCHAR(50);
    DECLARE @upperboard_approve VARCHAR(50);
    DECLARE @employee_ID INT;
    DECLARE @department VARCHAR(50);
    DECLARE @rank INT;
    -- The following are only needed to check Is_On_Leave
    DECLARE @Emp1_ID INT;
    DECLARE @Emp1_ID_rank INT;
    DECLARE @from_date VARCHAR(50);
    DECLARE @end_date VARCHAR(50);

    -- Get rank, employee_ID and department name of the employee requesting the leave
    SELECT @rank = rank, @employee_ID = employee_ID, @department = dept_name
    FROM Employee e INNER JOIN Annual_Leave al ON e.employee_ID = al.emp_ID
    WHERE al.request_ID = @request_ID

    -- Gets the employee_ID for the employee accepting the leave
    SELECT @Emp1_ID = Emp1_ID
    FROM Emploee_Approves_Employee eae INNER JOIN Employee e ON e.employee_ID = eae.Emp1_ID
    WHERE @request_ID = Leave_ID AND e.dept_name = @department

    -- Get rank of the employee accepting the leave
    SET @Emp1_ID_rank = db.get_rank(@Emp1_ID)

    /*UPDATE Leave
    SET status = CASE 
                    WHEN @rank>=5 THEN*/

    -- Case 1: Employee is of rank 5 or 6 (Needs approval from Hr and Dean)
    IF @rank>=5 
    BEGIN
        SELECT @start_date = start_date, @end_date = end_date
        -- Needed for Is_On_Leave
        FROM Leave
        WHERE @request_ID = request_ID

        SET @emp_approve_emp = dbo.get_approval_status(@request_ID, 'HR_Representative' +'_' +@department, 4)
        -- Get hr approval
        IF @Emp1_ID_rank = 3 AND dbo.Is_On_Leave(@Emp1_ID_rank, @from_date, @end_date) = 0 -- I think there is a problem here (The logic of it doesn't make sense to me) (@Emp1_ID_rank = 3 => ??????)
        BEGIN
            SET @upperboard_approve = dbo.get_approval_status(@request_ID, @department, 3)
        -- get dean approval
        END;

        ELSE
        BEGIN
            SET @upperboard_approve = dbo.get_approval_status(@request_ID, @department, 4)
        -- get vice-dean approval in case dean is on leave
        END;

        IF @emp_approve_emp = 'Approved' AND @upperboard_approve = 'Approved'
        BEGIN
            UPDATE Leave
        SET status = 'Approved'
        WHERE @request_ID = Leave_ID
        END;

        ELSE
        BEGIN
            UPDATE Leave
        SET status = 'Rejected'
        WHERE @request_ID = Leave_ID
        END;
    END

    -- Case 2: Employee is a dean or vice-dean ranks 3 or 4 (Needs hr approval and upperboard approval => president or vice-president)
    ELSE IF (@rank=3 AND @deparment <>  'HR') OR (@rank=4 AND @deparment <>  'HR')
    BEGIN
        SET @emp_approve_emp = dbo.get_approval_status(@request_ID, 'HR_Representative' + @department, 4)
        -- Gets hr approval
        SET @upperboard_approve = dbo.get_approval_status_pres(@request_ID)
        -- This should be replaced by the function that omar made that checks if president/vice-president approved leave

        IF @emp_approve_emp = 'Approved' AND @upperboard_approve = 'Approved'
        BEGIN
            UPDATE Leave
        SET status = 'Approved'
        WHERE @request_ID = Leave_ID
        END;

        ELSE
        BEGIN
            UPDATE Leave
        SET status = 'Rejected'
        WHERE @request_ID = Leave_ID
        END;
    END;

    -- Case 3: Hr request for leave (Needs approval from higher rank HR)
    ELSE IF (@rank = 4 AND @deparment = 'HR')
    BEGIN
        SET @emp_approve_emp = dbo.get_approval_status(@request_ID, 'HR_Representative' + @department, 3)
        -- Gets approval from higher rank HR
        IF @emp_approve_emp = 'Approved'
        BEGIN
            UPDATE Leave
        SET status = 'Approved'
        WHERE @request_ID = Leave_ID
        END;

        ELSE
        BEGIN
            UPDATE Leave
        SET status = 'Rejected'
        WHERE @request_ID = Leave_ID
        END;
    END;

END
GO

-- THE FOLLOWING IS AI VERSION OF THE CODE IMPLEMENTED ABOVE
-- I SENT IT MY OWN VERSION AND ASKED IT TO CHECK FOR MISTAKES

CREATE PROCEDURE auto_update_annual
    @request_ID INT
-- Removed trailing comma
AS
BEGIN
    -- Declarations
    DECLARE @Employee_ID INT;
    DECLARE @Department VARCHAR(50);
    DECLARE @Rank INT;
    DECLARE @Start_date DATE;
    DECLARE @End_date DATE;

    -- Variables for Approvals
    DECLARE @Dean_ID INT;
    DECLARE @ViceDean_ID INT;
    DECLARE @Approver_ID INT;
    DECLARE @HR_Representative_Status VARCHAR(50);
    DECLARE @UpperBoard_Status VARCHAR(50);

    -- 1. Get Details of the Applicant (Employee Requesting Leave)
    SELECT
        @Employee_ID = e.ID,
        @Department = e.dept_name, -- Assuming dept_name is in Employee or derived via Join
        @Start_date = l.start_date,
        @End_date = l.end_date
    FROM Employee e
        INNER JOIN Annual_Leave al ON e.employee_ID = al.emp_ID INNER JOIN [Leave] l ON al.request_ID = l.request_ID
    -- Adjusted column names to standard
    WHERE l.request_ID = @request_ID;

    -- Get Rank (Assuming rank is in Role table linked to Employee)
    SELECT TOP 1
        @Rank = r.rank
    FROM Role r
        INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.employee_ID = @Employee_ID
    ORDER BY r.rank ASC;
    -- Get highest rank (lowest number)

    -- =========================================================================
    -- CASE 1: Employee is Lecturer (5) or TA (6)
    -- Needs HR Representative + Dean (or Vice Dean if Dean is on leave)
    -- =========================================================================
    IF @Rank >= 5 
    BEGIN
        -- A. Check HR Representative Approval
        SELECT @HR_Representative_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID
            AND er.role_name = 'HR_Representative';
        -- Simplified check

        -- B. Determine who acts as the "Dean" approver
        -- Find the Dean of this department
        SELECT @Dean_ID = e.employee_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.employee_ID
        WHERE er.role_name = 'Dean' AND e.dept_name = @Department;

        -- Find the Vice Dean of this department
        SELECT @ViceDean_ID = e.employee_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.employee_ID
        WHERE er.role_name = 'Vice Dean' AND e.dept_name = @Department;

        -- LOGIC FIX: Check if Dean is on Leave 
        IF dbo.Is_On_Leave(@Dean_ID, @Start_date, @End_date) = 1
        BEGIN
            -- Dean is absent, Vice Dean approves 
            SET @Approver_ID = @ViceDean_ID;
        END
        ELSE
        BEGIN
            -- Dean is present, Dean approves
            SET @Approver_ID = @Dean_ID;
        END

        -- Check the status of that specific approver
        SELECT @UpperBoard_Status = status
        FROM Employee_Approve_Leave
        WHERE Leave_ID = @request_ID AND Emp1_ID = @Approver_ID;

        -- Final Update
        IF @HR_Representative_Status = 'Approved' AND @UpperBoard_Status = 'Approved'
        BEGIN
            UPDATE [Leave] SET status = 'Approved' WHERE request_ID = @request_ID;
        END
        ELSE IF @HR_Representative_Status = 'Rejected' OR @UpperBoard_Status = 'Rejected'
        BEGIN
            UPDATE [Leave] SET status = 'Rejected' WHERE request_ID = @request_ID;
        END
    END

    -- =========================================================================
    -- CASE 2: Applicant is Dean (3) or Vice Dean (4)
    -- Approved by President + HR Representative [cite: 61, 62]
    -- =========================================================================
    ELSE IF (@Rank = 3 OR @Rank = 4) AND @Department <> 'HR'
    BEGIN
        -- Check HR Representative Approval
        SELECT @HR_Representative_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID AND er.role_name = 'HR_Representative';

        -- Check President Approval
        SELECT @UpperBoard_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID AND (er.role_name = 'President');

        IF @HR_Representative_Status = 'Approved' AND @UpperBoard_Status = 'Approved'
        BEGIN
            UPDATE [Leave] SET status = 'Approved' WHERE request_ID = @request_ID;
        END
        ELSE IF @HR_Representative_Status = 'Rejected' OR @UpperBoard_Status = 'Rejected'
        BEGIN
            UPDATE [Leave] SET status = 'Rejected' WHERE request_ID = @request_ID;
        END
    END

    -- =========================================================================
    -- CASE 3: Applicant is HR (Rank 4, Dept HR)
    -- Approved by HR Manager + President [cite: 63, 64]
    -- =========================================================================
    ELSE IF @Rank = 4 AND @Department = 'HR'
    BEGIN
        -- Check HR Manager Approval
        SELECT @HR_Representative_Status = status
        -- Reusing variable
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.employee_ID
        WHERE eal.Leave_ID = @request_ID AND er.role_name = 'HR Manager';

        -- Check President Approval
        SELECT @UpperBoard_Status = status
        FROM Employee_Approve_Leave eal
            INNER JOIN Employee_Role er ON eal.Emp1_ID = er.Employee_ID
        WHERE eal.Leave_ID = @request_ID AND er.role_name = 'President';

        IF @HR_Representative_Status = 'Approved' AND @UpperBoard_Status = 'Approved'
        BEGIN
            UPDATE [Leave] SET status = 'Approved' WHERE request_ID = @request_ID;
        END
        ELSE IF @HR_Representative_Status = 'Rejected' OR @UpperBoard_Status = 'Rejected'
        BEGIN
            UPDATE [Leave] SET status = 'Rejected' WHERE request_ID = @request_ID;
        END
    END
END
GO



