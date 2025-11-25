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


-- test 5
PRINT dbo.Is_On_Leave(8, CAST('2025-10-01' AS DATE), CAST('2025-10-26' AS DATE))