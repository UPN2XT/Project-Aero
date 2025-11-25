USE University_HR_ManagementSystem_Team_97;
GO

CREATE FUNCTION EmployeeLoginValidation(@employee_ID int, @password varchar(50))
RETURNS bit
AS
BEGIN
    IF EXISTS(SELECT 1 FROM Employee WHERE employee_ID=@employee_ID AND [password]=@password)
        RETURN 1;
    RETURN 0;
END
GO

CREATE FUNCTION MyPerformance(@employee_ID INT, @semester CHAR(3))
RETURNS TABLE AS RETURN (
    SELECT performance_ID, rating, comments, semester FROM Performance 
    WHERE emp_ID = @employee_ID AND semester = @semester
);
GO

CREATE FUNCTION Last_month_payroll(@employee_ID INT)
RETURNS TABLE AS RETURN (
    SELECT ID AS payroll_ID, payment_date, final_salary_amount, from_date, to_date, comments, bonus_amount, deductions_amount
    FROM Payroll
    WHERE emp_ID = @employee_ID 
    AND MONTH(payment_date) = MONTH(DATEADD(MONTH, -1, GETDATE()))
    AND YEAR(payment_date) = YEAR(DATEADD(MONTH, -1, GETDATE()))
);
GO

CREATE FUNCTION MyAttendance(@employee_ID int)
RETURNS TABLE AS RETURN (
    SELECT a.* FROM Attendance a 
    INNER JOIN Employee e ON a.emp_ID = e.employee_id
    WHERE a.emp_ID = @employee_ID 
    AND MONTH(a.date) = MONTH(GETDATE()) AND YEAR(a.date) = YEAR(GETDATE())
    AND DATENAME(weekday, a.date) != e.official_day_off
);
GO

CREATE FUNCTION Deductions_Attendance (@employee_ID int, @month int)
RETURNS TABLE AS RETURN (
    SELECT d.* FROM Deduction d 
    INNER JOIN Attendance a ON a.attendance_ID = d.attendance_ID
    WHERE @employee_ID = d.emp_ID AND MONTH(d.date) = @month
);
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
            SELECT request_id FROM Annual_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Accidental_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Medical_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Unpaid_Leave WHERE emp_id = @Employee_ID
            UNION ALL SELECT request_id FROM Compensation_Leave WHERE emp_id = @Employee_ID
        ) AS subleaves ON l.request_id = subleaves.request_id
        INNER JOIN Employee e ON e.employee_id = @employee_ID
        WHERE 
            l.start_date <= @to AND l.end_date >= @from
            AND NOT (e.employment_status = 'resigned')
            AND l.final_approval_status IN ('approved', 'pending')
    )
    SET @Onleave = 1;

    RETURN @Onleave;
END
GO

CREATE FUNCTION Status_leaves(@employee_ID INT)
RETURNS TABLE AS RETURN (
    SELECT al.request_ID, l.date_of_request, l.final_approval_status AS status
    FROM Annual_Leave al INNER JOIN Leave l ON al.request_ID = l.request_ID
    WHERE al.emp_ID = @employee_ID
    UNION
    SELECT acl.request_ID, le.date_of_request, le.final_approval_status
    FROM Accidental_Leave acl INNER JOIN Leave le ON acl.request_ID = le.request_ID
    WHERE acl.emp_ID = @employee_ID
);
GO

CREATE FUNCTION get_rank(@Employee_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @rank INT;
    SELECT TOP 1 @rank = r.rank
    FROM Role r
    INNER JOIN Employee_Role er ON r.role_name = er.role_name
    WHERE er.emp_ID = @Employee_ID
    ORDER BY r.rank ASC;
    
    RETURN @rank;
END
GO

CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    IF dbo.Is_On_Leave(@replacement_emp, @start_date, @end_date) = 1
    BEGIN
        PRINT 'Error: Replacement employee is on leave';
        RETURN;
    END

    IF EXISTS (SELECT type_of_contract FROM Employee WHERE @employee_ID = employee_ID AND type_of_contract = 'part_time')
    BEGIN
        PRINT 'Error: Part time employees are not eligble for annual leave';
        RETURN;
    END

    INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @start_date, @end_date, 'pending');
    
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    
    INSERT INTO Annual_Leave (request_id, emp_id, replacement_emp)
    VALUES (@ReqID, @employee_ID, @replacement_emp);

    DECLARE @Dept VARCHAR(50);
    DECLARE @Rank INT;
    
    SELECT @Dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;
    
    SELECT TOP 1 @Rank = r.rank 
    FROM Role r INNER JOIN Employee_Role er ON r.role_name = er.role_name 
    WHERE er.emp_ID = @employee_ID 
    ORDER BY r.rank ASC;
    
    IF @Rank IS NULL SET @Rank = 5;

    IF @Rank >= 5
    BEGIN
        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @ReqID, 'pending'
        FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
        WHERE er.role_name = 'Dean' AND e.dept_name = @Dept;

        INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
        SELECT e.employee_ID, @ReqID, 'pending'
        FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
        WHERE er.role_name = 'HR_Representative_' + @Dept;
    END
    
    PRINT 'Annual Leave Submitted Successfully';
END
GO

CREATE PROCEDURE Submit_accidental
    @employee_ID INT, @start_date DATE, @end_date DATE
AS
BEGIN
    IF @start_date <> @end_date
    BEGIN
        PRINT 'Error: Accidental leaves can only be for 1 day.';
        RETURN;
    END

    INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
    VALUES (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Accidental_Leave (request_id, emp_id) VALUES (@ReqID, @employee_ID);
    
    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;
    
    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Submit_medical
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @type varchar(50),
    @insurance_status bit,
    @disability_details varchar(50),
    @document_description varchar(50),
    @file_name varchar(50)
AS
BEGIN
    IF @type = 'maternity'
    BEGIN
        DECLARE @contract_type VARCHAR(50);
        SELECT @contract_type = type_of_contract FROM Employee WHERE employee_ID = @employee_ID;
        IF @contract_type = 'part_time'
        BEGIN
            PRINT 'Error: Part-time employees are not eligible for maternity leave.';
            RETURN;
        END
    END

    INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Medical_Leave (request_id, emp_id, type, insurance_status, disability_details) VALUES (@ReqID, @employee_ID, @type, @insurance_status, @disability_details);

    IF @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document (medical_ID, emp_id, description, file_name, status, type, creation_date) 
        VALUES (@ReqID, @employee_ID, @document_description, @file_name, 'valid', 'Medical', GETDATE());
    END

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;
    
    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Submit_unpaid
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Employee WHERE employee_ID = @employee_ID AND type_of_contract = 'part_time')
    BEGIN
        PRINT 'Error: Part-time employees are not eligible for unpaid leaves.';
        RETURN;
    END

    IF DATEDIFF(DAY, @start_date, @end_date) > 30
    BEGIN
        PRINT 'Error: Unpaid leave cannot exceed 30 days.';
        RETURN;
    END

    INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Unpaid_Leave (request_id, emp_id) VALUES (@ReqID, @employee_ID);

    IF @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document (unpaid_ID, emp_id, description, file_name, status, type, creation_date) 
        VALUES (@ReqID, @employee_ID, @document_description, @file_name, 'valid', 'Unpaid', GETDATE());
    END

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
    WHERE er.role_name = 'Dean' AND e.dept_name = @Dept;

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Submit_compensation
    @employee_ID INT,
    @compensation_date DATE,
    @reason VARCHAR(50),
    @date_of_original_workday DATE,
    @replacement_emp INT
AS
BEGIN
    IF dbo.Is_On_Leave(@replacement_emp, @compensation_date, @compensation_date) = 1
    BEGIN
        PRINT 'Error: Replacement employee is on leave';
        RETURN;
    END

    INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status) VALUES (GETDATE(), @compensation_date, @compensation_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Compensation_Leave (request_id, emp_id, reason, date_of_original_workday, replacement_emp) 
    VALUES (@ReqID, @employee_ID, @reason, @date_of_original_workday, @replacement_emp);

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name FROM Employee WHERE employee_ID = @employee_ID;

    INSERT INTO Employee_Approve_Leave (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID 
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Upperboard_approve_annual
    @request_ID INT,
    @Upperboard_ID INT,
    @replacement_ID INT
AS
BEGIN
    DECLARE @StartDate DATE, @EndDate DATE;
    SELECT @StartDate = start_date, @EndDate = end_date FROM Leave WHERE request_ID = @request_ID;

    UPDATE Employee_Approve_Leave
    SET status = CASE 
        WHEN dbo.Is_On_Leave(@replacement_ID, @StartDate, @EndDate) = 0 THEN 'approved'
        ELSE 'rejected'
    END
    WHERE Emp1_ID = @Upperboard_ID AND Leave_ID = @request_ID;
    
    EXEC auto_update_annual @request_id;
END
GO

CREATE PROCEDURE Upperboard_approve_unpaids
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    UPDATE Employee_Approve_Leave
    SET status = CASE 
        WHEN EXISTS (SELECT 1 FROM Document WHERE document_ID = @request_ID AND status = 'valid') THEN 'approved' 
        ELSE 'rejected' 
    END
    WHERE Emp1_ID = @Upperboard_ID AND Leave_ID = @request_ID;
END
GO

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
    INSERT INTO Performance (emp_ID, rating, comments, semester)
    VALUES (@employee_ID, @rating, @comment, @semester);
END
GO