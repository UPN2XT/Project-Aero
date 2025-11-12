CREATE VIEW allEmployeeProfiles
AS
    SELECT *
    FROM Employee;
GO

CREATE VIEW NoEmployeeDept
AS
    SELECT count(*)
    FROM Employee
    GROUP BY dept_name;
GO

CREATE VIEW  allPerformance
AS
    SELECT *
    FROM Performance
    WHERE semester ='W%';
GO

CREATE VIEW allRejectedMedicals
AS
    SELECT *
    FROM Medical_Leave Ml
        INNER JOIN Leave l on Ml.request_ID = l.request_ID
    where final_approval_status = 'Rejected';
GO

CREATE VIEW allEmployeeAttendance
AS
    SELECT *
    FROM Attendance
    where date = GETDATE()-1;/*double check later*/
GO