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
DROP PROC Update_Status_Doc
DROP PROC Remove_Deductions
DROP PROC Update_Employment_Status
DROP PROC Create_Holiday
DROP PROC Add_Holiday
DROP PROC Intitiate_Attendance
DROP PROC Update_Attendance
DROP PROC Remove_Holiday
DROP PROC Remove_DayOff
DROP PROC Remove_Approved_Leaves
DROP PROC Replace_employee
DROP PROC HR_approval_an_acc
DROP PROC HR_approval_unpaid
DROP PROC HR_approval_comp
DROP PROC Deduction_hours
DROP PROC Deduction_days
DROP PROC Add_Payroll
DROP PROC Replace_employee
GO