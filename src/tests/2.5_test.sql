USE University_HR_ManagementSystem_Team_97;
GO

EXECUTE dbo.init_values

-- test 1
SELECT *
FROM dbo.MyPerformance(2, 'W24')

-- test 2
SELECT *
FROM dbo.Last_month_payroll(1);

-- test 3 
SELECT *
FROM dbo.MyAttendance(1);

-- test 4
-- TODO:://discuess is the period refering to the period of time saved in deductions or in attendance
SELECT *
FROM dbo.Deductions_Attendance(1,9)

-- test 5
SELECT emp_ID, l.*
FROM Leave l
    INNER JOIN (
                                                                                                                                SELECT request_id, emp_ID
        FROM Annual_Leave
    UNION ALL
        SELECT request_id, emp_id
        FROM Accidental_Leave
    UNION ALL
        SELECT request_id, emp_id
        FROM Medical_Leave
    UNION ALL
        SELECT request_id, emp_id
        FROM Unpaid_Leave
    UNION ALL
        SELECT request_id, emp_id
        FROM Compensation_Leave
        ) AS subleaves ON l.request_id = subleaves.request_id
WHERE LOWER(final_approval_status) IN ('approved', 'pending')


PRINT dbo.Is_On_Leave(8, CAST('2025-10-01' AS DATE), CAST('2025-10-26' AS DATE))

SELECT employee_ID, role_name
FROM Employee
    INNER JOIN Employee_Role er On er.emp_ID = employee_ID

SELECT Employee_id
FROM Employee
WHERE dept_name = 'HR'
/*
CREATE PROCEDURE Submit_annual
    @employee_ID INT,
    @replacement_emp INT,
    @start_date DATE,
    @end_date DATE
*/

EXECUTE dbo.Submit_annual 4, 5, '2025-9-01', '2025-9-26'

SELECT e.employee_ID, role_name, [status]
FROM Employee_Approve_Leave eal
    INNER JOIN Employee e ON eal.Emp1_ID = e.employee_ID
    INNER JOIN Employee_Role er ON er.emp_ID = e.employee_ID
WHERE eal.Leave_ID = 3

SELECT *
FROM Employee_Approve_Leave
WHERE Leave_ID = 27

SELECT *
FROM dbo.Status_leaves(1)

EXECUTE dbo.Upperboard_approve_annual 27, 11, 3

SELECT emp_1.dept_name, emp_2.dept_name
FROM Employee emp_1
    INNER JOIN Employee_Replace_Employee er On emp_1.employee_ID = er.Emp1_ID
    INNER JOIN Employee emp_2 On emp_2.employee_ID = er.Emp2_ID

SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(employee_id), employee_id
FROM Employee

INSERT INTO Employee_Replace_Employee
    (Emp1_ID, Emp2_ID, to_date, from_date)
VALUES
    (1, 3, '2025-11-30', '2025-11-20')
INSERT INTO Leave
    (date_of_request)
VALUES
    (GETDATE())
INSERT INTO Annual_Leave
    (request_ID, emp_ID)
VALUES(31, 1)

SELECT dbo.is_on_leave(1, GETDATE(), GETDATE())
FROM Employee

SELECT
    *
FROM Employee_Replace_Employee e
WHERE Emp1_ID = 1
    --WHERE e.from_date <= GETDATE() AND e.to_date >= GETDATE()


