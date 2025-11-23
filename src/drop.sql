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

CREATE PROCEDURE dropAllProceduresFunctionsViews
AS
BEGIN
    DROP FUNCTION IF EXISTS HRLoginValidation
    DROP FUNCTION IF EXISTS Bonus_amount
    DROP FUNCTION IF EXISTS EmployeeLoginValidation
    DROP FUNCTION IF EXISTS MyPerformance
    DROP FUNCTION IF EXISTS MyAttendance
    DROP FUNCTION IF EXISTS Last_month_payroll
    DROP FUNCTION IF EXISTS Deductions_Attendance
    DROP FUNCTION IF EXISTS Is_On_Leave
    DROP FUNCTION IF EXISTS Status_leaves

    DROP VIEW IF EXISTS allEmployeeProfiles
    DROP VIEW IF EXISTS NoEmployeeDept
    DROP VIEW IF EXISTS allPerformance
    DROP VIEW IF EXISTS allRejectedMedicals
    DROP VIEW IF EXISTS allEmployeeAttendance

    DROP PROCEDURE IF EXISTS createAllTables
    DROP PROCEDURE IF EXISTS dropAllTables
    DROP PROCEDURE IF EXISTS clearAllTables
    DROP PROCEDURE IF EXISTS Update_Status_Doc
    DROP PROCEDURE IF EXISTS Remove_Deductions
    DROP PROCEDURE IF EXISTS Update_Employment_Status
    DROP PROCEDURE IF EXISTS Create_Holiday
    DROP PROCEDURE IF EXISTS Add_Holiday
    DROP PROCEDURE IF EXISTS Intitiate_Attendance
    DROP PROCEDURE IF EXISTS Update_Attendance
    DROP PROCEDURE IF EXISTS Remove_Holiday
    DROP PROCEDURE IF EXISTS Remove_DayOff
    DROP PROCEDURE IF EXISTS Remove_Approved_Leaves
    DROP PROCEDURE IF EXISTS Replace_employee
    DROP PROCEDURE IF EXISTS HR_approval_an_acc
    DROP PROCEDURE IF EXISTS HR_approval_unpaid
    DROP PROCEDURE IF EXISTS HR_approval_comp
    DROP PROCEDURE IF EXISTS Deduction_hours
    DROP PROCEDURE IF EXISTS Deduction_days
    DROP PROCEDURE IF EXISTS Deduction_unpaid
    DROP PROCEDURE IF EXISTS Add_Payroll
    DROP PROCEDURE IF EXISTS Submit_annual
    DROP PROCEDURE IF EXISTS Upperboard_approve_annual
    DROP PROCEDURE IF EXISTS Submit_accidental
    DROP PROCEDURE IF EXISTS Submit_medical
    DROP PROCEDURE IF EXISTS Submit_unpaid
    DROP PROCEDURE IF EXISTS Upperboard_approve_unpaids
    DROP PROCEDURE IF EXISTS Submit_compensation
    DROP PROCEDURE IF EXISTS Dean_andHR_Evaluation
END
GO