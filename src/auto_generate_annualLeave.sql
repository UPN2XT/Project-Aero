CREATE PROCEDURE auto_update_annual--TO DO 
    @request_ID INT,
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
    @Emp1_ID_rank = db.get_rank(@Emp1_ID)

    /*UPDATE Leave
    SET status = CASE 
                    WHEN @rank>=5 THEN*/

    -- Case 1: Employee is of rank 5 or 6 (Needs approval from Hr and Dean)
    IF @rank>=5 
    BEGIN
        SELECT @start_date = start_date, @end_date = end_date -- Needed for Is_On_Leave
        FROM Leave
        WHERE @request_ID = request_ID

        @emp_approve_emp = db.get_approval_status_from_hr(@request_ID, 'HR_Representative' || department, 4) -- Get hr approval
        IF @Emp1_ID_rank = 3 AND db.Is_On_Leave(@Emp1_ID_rank, @from_date, @end_date) = 0 -- I think there is a problem here (The logic of it doesn't make sense to me) (@Emp1_ID_rank = 3 => ??????)
        BEGIN
            @upperboard_approve = db.get_approval_status_from_hr(@request_ID, @department, 3) -- get dean approval
        END;

        ELSE
        BEGIN
            @upperboard_approve = db.get_approval_status_from_hr(@request_ID, @department, 4) -- get vice-dean approval in case dean is on leave
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

        END;
    END;

    -- Case 2: Employee is a dean or vice-dean ranks 3 or 4 (Needs hr approval and upperboard approval => president or vice-president)
    ELSE IF (@rank=3 AND @deparment <>  'HR') OR (@rank=4 AND @deparment <>  'HR')
    BEGIN
        @emp_approve_emp = db.get_approval_status_from_hr(@request_ID, 'HR_Representative' || department, 4) -- Gets hr approval
        @upperboard_approve = db.get_approval_status_from_upperboard(@request_ID) -- This should be replaced by the function that omar made that checks if president/vice-president approved leave

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
        @emp_approve_emp = db.get_approval_status_from_hr(@request_ID, 'HR_Representative' || department, 3) -- Gets approval from higher rank HR
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
    @request_ID INT -- Removed trailing comma
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
    INNER JOIN Annual_Leave al ON e.employee_ID = al.emp_ID INNER JOIN [Leave] l ON al.request_ID = l.request_ID -- Adjusted column names to standard
    WHERE l.request_ID = @request_ID;

    -- Get Rank (Assuming rank is in Role table linked to Employee)
    SELECT TOP 1 @Rank = r.rank
    FROM Role r
    INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.employee_ID = @Employee_ID
    ORDER BY r.rank ASC; -- Get highest rank (lowest number)

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
          AND er.role_name = 'HR_Representative'; -- Simplified check

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
        SELECT @HR_Representative_Status = status -- Reusing variable
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
END;
GO