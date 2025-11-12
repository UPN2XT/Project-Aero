CREATE PROC dropAllTables
AS
DROP TABLE Employee_Approve_Leave
DROP TABLE Employee_Replace_Employee
DROP TABLE Performance
DROP TABLE Deduction
DROP TABLE Attendance
DROP TABLE Payroll
DROP TABLE Document
DROP TABLE Compensation_Leave
DROP TABLE Unpaid_Leave
DROP TABLE Medical_Leave
DROP TABLE Accidental_Leave
DROP TABLE Annual_Leave
DROP TABLE Medical_Leave
DROP TABLE Leave
DROP TABLE Role_existsIn_Department
DROP TABLE Employee_Role
DROP TABLE Role
DROP TABLE Employee_Phone
DROP TABLE Employee
DROP TABLE Department
GO

CREATE PROC dropAllProceduresFunctionsViews/*still needs to add more procs and views as we continue*/
AS
DROP PROC dropAllTables
DROP PROC createAllTables
DROP VIEW allEmploteeProfiles
DROP VIEW NoEmployeeDept
DROP VIEW allPerformance
DROP VIEW allRejectedMedicals
DROP VIEW allEmployeeAttendance
DROP PROC clearAllTables
DROP PROC CalculateEmployeeSalary
GO