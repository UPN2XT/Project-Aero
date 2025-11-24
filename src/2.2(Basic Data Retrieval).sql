USE University_HR_ManagementSystem_Team_97
GO

CREATE VIEW allEmployeeProfiles
AS
    SELECT *
    FROM Employee;
GO

CREATE VIEW NoEmployeeDept
AS
    SELECT count(*) AS 'count'
    FROM Employee
    GROUP BY dept_name;
GO

CREATE VIEW  allPerformance
AS
    SELECT *
    FROM Performance
    WHERE semester ='W%';
GO

-- TODO:// recheck
CREATE VIEW allRejectedMedicals
AS
    SELECT Ml.disability_details, ml.Emp_ID, ml.insurance_status, ml.request_ID, ml.[type]
    FROM Medical_Leave Ml
        INNER JOIN Leave l on Ml.request_ID = l.request_ID
    where final_approval_status = 'rejected';
GO

CREATE VIEW allEmployeeAttendance
AS
    SELECT *
    FROM Attendance
    where date = GETDATE()-1;/*double check later*/
GO