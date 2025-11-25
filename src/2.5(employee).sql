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
        AND l.final_approval_status IN ('approved', 'pending')
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

CREATE FUNCTION GET_ID_Replacment_IF_ON_LEAVE(@employee_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @ID INT = @employee_id
    SELECT TOP 1
        @ID = e.Emp2_ID
    FROM Employee_Replace_Employee e
    WHERE e.from_date <= GETDATE() AND e.to_date >= GETDATE()
    RETURN CASE WHEN dbo.Is_On_Leave(@employee_ID, GETDATE(), GETDATE()) = 1
    THEN @ID ELSE @employee_ID END
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

    SELECT @my_dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;
    SELECT @dep_name_replacement = dept_name
    FROM Employee e
    WHERE e.employee_ID = @replacement_emp

    IF dbo.is_on_leave(@replacement_emp, @start_date, @end_date) = 1
    BEGIN
        PRINT 'replacment employee is on leave'
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        WHERE request_ID = @request_ID
        RETURN;
    END

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
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_id
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
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE r.rank = 1 OR r.role_name = 'HR_Representative_' + @dept_name
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID)
    SELECT
        dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id),
        @request_id
    FROM Employee e
        INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
        INNER JOIN Role r ON r.role_name = er.role_name
    WHERE (r.role_name = 'Dean' AND e.dept_name=@my_dept)
        OR r.role_name = 'HR_Representative_' + @dept_name
END 
GO

CREATE FUNCTION Status_leaves(@employee_ID INT)
RETURNS TABLE
AS
RETURN (                                                                                                                                     SELECT al.request_ID,
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

CREATE PROCEDURE Submit_accidental
    @employee_ID INT,
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    IF @start_date <> @end_date
    BEGIN
        PRINT 'Error: Accidental leaves can only be for 1 day.';
        RETURN;
    END

    INSERT INTO Leave
        (date_of_request, start_date, end_date, final_approval_status)
    VALUES
        (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Accidental_Leave
        (request_id, emp_id)
    VALUES
        (@ReqID, @employee_ID);

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;
    IF (@Dept = 'HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR Manager';
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
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
        SELECT @contract_type = type_of_contract
        FROM Employee
        WHERE employee_ID = @employee_ID;
        IF @contract_type = 'part_time'
        BEGIN
            PRINT 'Error: Part-time employees are not eligible for maternity leave.';
            RETURN;
        END
    END

    INSERT INTO Leave
        (date_of_request, start_date, end_date, final_approval_status)
    VALUES
        (GETDATE(), @start_date, @end_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Medical_Leave
        (request_id, emp_id, type, insurance_status, disability_details)
    VALUES
        (@ReqID, @employee_ID, @type, @insurance_status, @disability_details);

    IF @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document
            (medical_ID, emp_id, description, file_name, status, type, creation_date)
        VALUES
            (@ReqID, @employee_ID, @document_description, @file_name, 'valid', 'Medical', GETDATE());
    END

    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    IF (@Dept = 'HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR Manager';
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO

CREATE PROCEDURE Submit_unpaid
    -- TODO://to be tested
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

    IF EXISTS (
        SELECT 1
    FROM Unpaid_Leave ul
        INNER JOIN Leave l ON ul.request_id = l.request_id
    WHERE ul.emp_ID = @employee_ID
        AND l.final_approval_status = 'Approved'
        AND YEAR(l.start_date) = YEAR(GETDATE())
    )
    BEGIN
        PRINT 'Error: You can only have one approved unpaid leave per year.';
        RETURN;
    END

    DECLARE @request_ID INT;
    DECLARE @dept_name VARCHAR(50);

    SELECT @dept_name = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    INSERT INTO Leave
        (date_of_request, start_date, end_date)
    VALUES
        (GETDATE(), @start_date, @end_date);

    SET @request_ID = SCOPE_IDENTITY();

    INSERT INTO Unpaid_Leave
        (request_id, emp_id)
    VALUES
        (@request_ID, @employee_ID);

    IF @file_name IS NOT NULL
    BEGIN
        INSERT INTO Document
            (unpaid_ID, emp_id, description, file_name, status, type, creation_date)
        VALUES
            (@request_ID, @employee_ID, @document_description, @file_name, 'valid', 'Memo', GETDATE());
    END

    IF @dept_name = 'HR'
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE r.[rank] = 1
            OR (r.rank = 3 AND e.dept_name = 'HR');
    END

    ELSE IF EXISTS (
        SELECT 1
    FROM Employee_Role er
        INNER JOIN Role r ON er.role_name = r.role_name
    WHERE er.emp_id = @employee_ID AND r.role_name IN ('Dean', 'Vice Dean')
    )
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_id
        FROM Employee e
            INNER JOIN Employee_Role er ON er.emp_id = e.employee_ID
            INNER JOIN Role r ON r.role_name = er.role_name
        WHERE r.rank = 1 OR r.role_name = 'HR_Representative_' + @dept_name
    END

    ELSE
    BEGIN
        INSERT INTO Employee_Approve_Leave
            (Emp1_ID, Leave_ID)
        SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_ID
        FROM Employee e
            INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
            INNER JOIN Role r ON er.role_name = r.role_name
        WHERE (r.role_name = 'Dean' AND e.dept_name = @dept_name)
            OR r.role_name = 'HR_Representative_' + @dept_name OR r.[rank] = 1;
    END
END
GO


CREATE PROCEDURE Upperboard_approve_unpaids
    @request_ID INT,
    @Upperboard_ID INT
AS
BEGIN
    UPDATE Employee_Approve_Leave
    SET status = CASE 
                    WHEN EXISTS (
                        SELECT 1
    FROM Document
    WHERE Leave_ID = @request_ID
        AND status = 'valid' 
                    ) THEN 'Approved' 
                    ELSE 'Rejected' 
                 END
    WHERE Emp1_ID = @Upperboard_ID
        AND Leave_ID = @request_ID;
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
    INSERT INTO Leave
        (date_of_request, start_date, end_date, final_approval_status)
    VALUES
        (GETDATE(), @compensation_date, @compensation_date, 'pending');
    DECLARE @ReqID INT = SCOPE_IDENTITY();
    INSERT INTO Compensation_Leave
        (request_id, emp_id, reason, date_of_original_workday, replacement_emp)
    VALUES
        (@ReqID, @employee_ID, @reason, @date_of_original_workday, @replacement_emp);

    IF dbo.Is_On_Leave(@replacement_emp, @compensation_date, @compensation_date) = 1
    BEGIN
        UPDATE Leave
        SET final_approval_status = 'Rejected'
        RETURN;
    END


    DECLARE @Dept VARCHAR(50);
    SELECT @Dept = dept_name
    FROM Employee
    WHERE employee_ID = @employee_ID;

    IF (@Dept = 'HR')
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR Manager';
    ELSE
    INSERT INTO Employee_Approve_Leave
        (Emp1_ID, Leave_ID, status)
    SELECT e.employee_ID, @ReqID, 'pending'
    FROM Employee e INNER JOIN Employee_Role er ON e.employee_ID = er.emp_ID
    WHERE er.role_name = 'HR_Representative_' + @Dept;
END
GO


