USE University_HR_ManagementSystem_Team_97;
GO

CREATE FUNCTION EmployeeLoginValidation(@employee_ID int, @password varchar(50))
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


CREATE FUNCTION Last_month_payroll(@employee_ID INT)
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

CREATE FUNCTION MyAttendance(@employee_ID int)
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
SELECT d.*
FROM Deduction d
    INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
WHERE @employee_ID = d.emp_ID AND MONTH(a.[date]) = @month
    AND d.[type] = 'missing_days'
)
GO


CREATE FUNCTION Is_On_Leave(@employee_ID INT, @from DATE, @to DATE)
RETURNS BIT
AS
BEGIN
    DECLARE @Onleave BIT = 0;
    IF EXISTS (
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
        ) AS subleaves ON l.request_id = subleaves.request_id
        INNER JOIN Employee e ON e.employee_id = @employee_ID
    WHERE 
        l.start_date <= @to AND l.end_date >= @from
        AND NOT (e.employment_status = 'resigned')
        AND LOWER(l.final_approval_status) IN ('approved', 'pending')
    )
    SET @Onleave = 1;

    RETURN @Onleave;
END
GO

CREATE FUNCTION get_rank (@Employee_ID INT)
RETURNS INT
BEGIN
    DECLARE @rank INT;
    SELECT @rank = MIN(rank)
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_id = @Employee_ID;
    RETURN @rank;
END
GO

CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
DECLARE @dep_name_replacement varchar(50);
DECLARE @my_dept varchar(50);
BEGIN
    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);
    SET @rank = dbo.get_rank(@employee_id);

    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_ID = @employee_id;

    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);
    SET @request_ID = SCOPE_IDENTITY();
    INSERT INTO Annual_Leave
        (request_id, emp_id, replacement_emp)
    VALUES
        (@request_id, @employee_id, @replacement_emp);

    PRINT @request_id

    IF EXISTS(
        SELECT type_of_contract
    FROM Employee
    WHERE @employee_ID = employee_ID AND type_of_contract = 'part_time'
    )
    BEGIN
        PRINT 'Part time employees are not eligble for annual leave';
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

    -- Check C: getting my department
    SELECT @my_dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    --get dep of replacment employee
    SELECT @dep_name_replacement = dept_name
    FROM Employee e
    WHERE e.employee_ID = @replacement_emp

    --check if replacment employee is on leave
    IF dbo.is_on_leave(@replacement_emp, @start_date, @end_date) = 1
    BEGIN
        PRINT 'replacment employee is on leave'
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

    --check if both employees are the same department
    IF @my_dept <> @dep_name_replacement
    BEGIN
        PRINT 'replacement employee is not from the same department'
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

    IF EXISTS(
        SELECT employee_ID
    FROM Employee
    WHERE employee_ID = @employee_ID
        AND dept_name='HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_ID, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.dept_name = 'HR'
        AND r.rank < @rank
    GROUP BY employee_ID
    ELSE IF EXISTS (
        SELECT employee_ID
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_ID, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE r.rank <= 2 OR dept_name = 'HR'
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT e.employee_ID, @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE (r.role_name = 'Dean' AND e.dept_name=@my_dept) OR e.dept_name = 'HR'

END 
GO

CREATE FUNCTION Status_leaves(@employee_ID INT)
RETURNS TABLE
AS
RETURN (                 SELECT al.request_ID,
        l.date_of_request,
        l.final_approval_status AS status
    FROM Annual_Leave aL
        INNER JOIN Leave l ON al.request_ID = l.request_ID
    WHERE al.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), l.date_of_request) = 0
UNION
    SELECT acl.request_ID,
        le.date_of_request,
        le.final_approval_status AS status
    FROM Accidental_Leave acl
        INNER JOIN Leave le ON acl.request_ID = le.request_ID
    WHERE acl.emp_ID = @employee_ID
        AND DATEDIFF(month, GETDATE(), le.date_of_request) = 0
)
GO


CREATE PROCEDURE Upperboard_approve_annual
    @request_ID INT,
    @Upperboard_ID INT,
    @replacement_ID INT
AS
UPDATE Employee_Approve_Leave
        SET status =
                CASE WHEN EXISTS (
                    SELECT e.employee_ID
FROM Employee e
    INNER JOIN Leave l ON l.request_id = @request_ID
    INNER JOIN Annual_Leave al ON al.request_id = @request_ID
    INNER JOIN Employee e1 ON e1.employee_ID = al.emp_ID
WHERE e.dept_name = e1.dept_name
    AND e.employee_ID = @replacement_ID
    AND dbo.Is_On_Leave(@replacement_ID, l.start_date, end_date) = 0
                ) then 'Approved' ELSE 'Rejected'
            END
            WHERE Emp1_ID = @Upperboard_ID AND Leave_ID=@request_id
EXEC dbo.auto_update_annual @request_id;
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

CREATE PROCEDURE Submit_accidental
    -- Goal: Apply for an accidental leave. Populate the approval table accordingly with the corresponding 
    -- employees for the leaves’ approval based on the hierarchy
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    -- 1. VALIDATION: Accidental leaves must be exactly 1 day (Section 1.4).
    IF @start_date <> @end_date
    BEGIN
        PRINT 'Error: Accidental leaves can only be for 1 day (Start Date must equal End Date).';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);

    -- Get the employee's rank
    SELECT @rank = MAX(r.rank)
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_ID = @Employee_ID;

    -- Get the employee's department
    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_ID = @employee_id;

    -- 2. Insert into the main generic 'Leave' table
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    -- 3. Get the ID of the row we just created
    SET @request_ID = SCOPE_IDENTITY();

    -- 4. Insert into the specific 'Accidental_Leave' table
    INSERT INTO Accidental_Leave
        (request_id, emp_id)
    VALUES
        (@request_ID, @employee_id);

    -- 5. POPULATE APPROVALS (Logic copied from Submit_annual)

    -- Case A: If the employee is in HR, they need approval from higher-ranking HR staff.
    IF EXISTS(
        SELECT employee_ID
    FROM Employee
    WHERE employee_ID = @employee_id AND dept_name='HR'
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
            AND r.rank < @rank
        GROUP BY e.employee_ID
    END

    -- Case B: If the employee is a Dean or Vice Dean, they need approval from President/Vice President (Rank 1 or 2).
    ELSE IF EXISTS (
        SELECT e.employee_ID
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank <= 2
    END

    -- Case C: Regular employees (Lecturers, TAs, etc.) need approval from their Dean AND HR.
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name)
            OR e.dept_name = 'HR'
    END
END
GO

CREATE PROCEDURE Submit_medical
    -- Goal: Apply for a medical leave. Populate the approval table 
    -- accordingly with the corresponding employees for the leaves’ approval based on the hierarchy.
    -- It's pretty similar to the function above it 
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type varchar(50),
    -- 'sick' or 'maternity'
    @insurance_status bit,
    @disability_details varchar(50),
    @document_description varchar(50),
    @file_name varchar(50)
AS
BEGIN
    -- 1. VALIDATION: Check for Part-Time + Maternity rule (Section 1.4)
    -- "Employees who are part-time are not eligible for... maternity leaves."
    IF @type = 'maternity'
    BEGIN
        DECLARE @contract_type VARCHAR(50);
        SELECT @contract_type = type_of_contract
        FROM Employee
        WHERE employee_ID = @employee_ID;

        IF @contract_type = 'part_time'
        BEGIN
            PRINT 'Error: Part-time employees are not eligible for maternity leave.';
            RETURN;
        END
    END

    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);

    -- Get the employee's rank
    SELECT @rank = MAX(r.rank)
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_ID = @Employee_ID;

    -- Get the employee's department
    SELECT @dept_name = dept_name
    FROM Employee
    WHERE Employee.employee_ID = @employee_id;

    -- 2. Insert into the main generic 'Leave' table
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    -- 3. Get the new request_ID
    SET @request_ID = SCOPE_IDENTITY();

    -- 4. Insert into the specific 'Medical_Leave' table
    INSERT INTO Medical_Leave
        (request_id, emp_id, type, insurance_status, disability_details)
    VALUES
        (@request_ID, @employee_id, @type, @insurance_status, @disability_details);


    -- For the documents type shit
    IF @file_name IS NOT NULL OR @document_description IS NOT NULL
    BEGIN
        INSERT INTO Document
            (request_id, emp_id, description, file_name, status)
        VALUES
            (@request_ID, @employee_ID, @document_description, @file_name, 'valid');
    END
    -- Case A: HR Employees -> Need approval from higher HR
    IF EXISTS(
        SELECT employee_ID
    FROM Employee
    WHERE employee_ID = @employee_ID AND dept_name='HR'
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
            AND r.rank < @rank
        GROUP BY e.employee_ID
    END

    -- Case B: Dean/Vice Dean -> Need approval from President/Vice President (Rank 1 or 2)
    ELSE IF EXISTS (
        SELECT e.employee_ID
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_ID = @employee_id
        AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank <= 2
    END

    -- Case C: Regular employees -> Need approval from their Dean AND HR
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name)
            OR e.dept_name = 'HR'
    END
END
GO


CREATE PROCEDURE Submit_unpaid
    -- Goal: Apply for unpaid leave. Populate the approval table accordingly
    -- with the corresponding employees for the leaves’ approval based on the hierarchy
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF EXISTS (
        SELECT 1
    FROM Employee
    WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time'
    )
    BEGIN
        PRINT 'Error: Part-time employees are not eligible for unpaid leaves.';
        RETURN;
    END

    IF DATEDIFF(DAY, @start_date, @end_date) > 30
    BEGIN
        PRINT 'Error: Unpaid leave cannot exceed 30 days.';
        RETURN;
    END

    -- We check if they already have an 'Approved' unpaid leave in the current year.
    IF EXISTS (
        SELECT 1
    FROM Unpaid_Leave ul
        INNER JOIN Leave l ON ul.request_id = l.request_id
    WHERE ul.emp_ID = @employee_ID
        AND l.status = 'Approved'
        AND YEAR(l.start_date) = YEAR(GETDATE())
    )
    BEGIN
        PRINT 'Error: You can only have one approved unpaid leave per year.';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @dept_name VARCHAR(50);

    -- Get Dept Name for logic later
    SELECT @dept_name = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    -- 4. Insert into generic Leave table
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    SET @request_ID = SCOPE_IDENTITY();

    -- 5. Insert into Unpaid_Leave table
    INSERT INTO Unpaid_Leave
        (request_id, emp_id)
    VALUES
        (@request_ID, @employee_ID);

    -- 6. Insert Document (if provided)
    IF @file_name IS NOT NULL OR @document_description IS NOT NULL
    BEGIN
        INSERT INTO Document
            (request_id, emp_id, description, file_name, status)
        VALUES
            (@request_ID, @employee_ID, @document_description, @file_name, 'valid');
    END

    -- CASE A: The Applicant is an HR Employee
    -- Guideline: "Must be approved/rejected by the President and HR Manager."
    IF @dept_name = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President'
            OR (r.role_name = 'HR Manager' AND e.dept_name = 'HR');
    END

    -- CASE B: The Applicant is a Dean or Vice Dean
    -- Guideline: "Must be approved/rejected by the President and HR Representative."
    ELSE IF EXISTS (
        SELECT 1
    FROM Employee_Role er
        INNER JOIN Role r ON er.role_name = r.role_name
    WHERE er.emp_id = @employee_ID AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE r.role_name = 'President'
            OR (r.role_name = 'HR Representative' AND e.dept_name = 'HR');
    END

    -- CASE C: Regular Employee (Dean of their Dept + HR)
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_ID, @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name)
            OR e.dept_name = 'HR';
    END
END
GO


CREATE PROCEDURE Upperboard_approve_unpaids
    -- Goal: As a Dean/Vice-dean/President I can approve/reject unpaid leaves. memo document submitted with a valid reason,
    -- the leave gets approved.
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    -- Requirement: "In case a memo document is submitted with a valid reason, the leave gets approved."
    -- If a document is found, the status becomes 'Approved'. If not, it becomes 'Rejected'.
    UPDATE Employee_Approve_Leave
    SET status = CASE 
                    WHEN EXISTS (
                        SELECT 1
    FROM Document
    WHERE request_id = @request_ID
        AND status = 'valid' 
                    ) THEN 'Approved' 
                    ELSE 'Rejected' 
                 END
    WHERE Emp1_ID = @Upperboard_ID
        AND Leave_ID = @request_ID;
END
GO






CREATE PROCEDURE Submit_compensation
    -- Goal: Apply for a compensation leave. Populate the approval table
    -- accordingly with the corresponding employees for the leaves’ approval based on the hierarchy
    @employee_ID INT,
    @compensation_date DATE,
    @reason VARCHAR(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
DECLARE @dep_name_replacement varchar(50);
DECLARE @my_dept varchar(50);
BEGIN
    IF MONTH(GETDATE()) <> MONTH(@date_of_original_workday) OR YEAR(GETDATE()) <> YEAR(@date_of_original_workday)
    BEGIN
        PRINT 'Error: Compensation leave must be requested within the same month as the extra work day.';
        RETURN;
    END

    -- Check B: "Spent at least 8 hours during his/her day off"
    DECLARE @hours_worked INT;

    SELECT @hours_worked = DATEDIFF(HOUR, check_in_time, check_out_time)
    FROM Attendance
    WHERE emp_id = @employee_ID
        AND date = @date_of_original_workday;

    IF @hours_worked IS NULL OR @hours_worked < 8
    BEGIN
        PRINT 'Error: You must have worked at least 8 hours on the original workday to claim compensation.';
        RETURN;
    END

    -- Check C: Verify that @date_of_original_workday was actually their "Official Day Off" and get their dept
    DECLARE @official_day_off VARCHAR(50);
    SELECT @official_day_off = official_day_off, @my_dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    --get dep of replacment employee
    SELECT @dep_name_replacement = dept_name
    FROM Employee e
    WHERE e.employee_ID = @replacement_ID

    --check if replacment employee is on leave
    IF is_on_leave(@replacement_emp, @compensation_date, @compensation_date) = 1
    BEGIN
        PRINT 'Error: replacment employee is on leave'
        RETURN;
    END

    --check if both employees are the same department
    IF @my_dept <> @dep_name_replacement
    BEGIN
        PRINT 'Error: replacement employee is not from the same department'
        RETURN;
    END

    -- DATENAME returns 'Saturday', 'Sunday', etc. matching the expected format of official_day_off
    -- Not sure of this one
    IF DATENAME(WEEKDAY, @date_of_original_workday) <> @official_day_off
    BEGIN
        PRINT 'Error: The date of original work must match your official day off.';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @rank INT;
    DECLARE @dept_name VARCHAR(50);

    -- Get the employee's rank and department for Approval Logic
    SELECT @rank = MAX(r.rank),
        @dept_name = e.dept_name
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE e.employee_id = @Employee_ID
    GROUP BY e.dept_name;

    -- Insert into generic Leave table (Duration is usually 1 day for compensation)
    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @compensation_date, @compensation_date);

    SET @request_ID = SCOPE_IDENTITY();

    -- Insert into specific Compensation_Leave table
    INSERT INTO Compensation_Leave
        (request_id, emp_id, reason, original_work_date, replacement_emp)
    VALUES
        (@request_ID, @employee_ID, @reason, @date_of_original_workday, @replacement_emp);


    -- Case A: HR Employees -> Need approval from higher HR
    IF EXISTS(
        SELECT employee_id
    FROM Employee
    WHERE employee_id = @employee_id AND dept_name='HR'
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_id, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
            AND r.rank < @rank
        GROUP BY e.employee_id
    END
    --case where employee is dean/vice dean or regular
    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT e.employee_id, @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_id
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE e.dept_name = 'HR'
    END
END
GO


