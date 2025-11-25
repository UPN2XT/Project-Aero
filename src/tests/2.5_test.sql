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
WHERE eal.Leave_ID = 39

SELECT *
FROM Employee_Approve_Leave
WHERE Leave_ID = 27

SELECT employee_id
FROM Employee
WHERE
 type_of_contract = 'part_time'

SELECT *
FROM Employee
WHERE dept_name = 'HR'

EXECUTE dbo.Submit_annual 4, 5, '2025-12-3', '2025-12-6'

SELECT emp_1.dept_name, emp_2.dept_name
FROM Employee emp_1
    INNER JOIN Employee_Replace_Employee er On emp_1.employee_ID = er.Emp1_ID
    INNER JOIN Employee emp_2 On emp_2.employee_ID = er.Emp2_ID

/*
 @employee_ID INT,
    @start_date DATE,
    @end_date DATE,
    @document_description VARCHAR(50),
    @file_name VARCHAR(50)

*/

SELECT dbo.GET_ID_Replacment_IF_ON_LEAVE(e.employee_id), @request_ID
FROM Employee e
    INNER JOIN Employee_Role er ON e.employee_ID = er.emp_id
    INNER JOIN Role r ON er.role_name = r.role_name
WHERE (r.role_name = 'Dean' AND e.dept_name = 'MET')
    OR r.role_name = 'HR_Representative_' + e.dept_name OR r.[rank] = 1


