CREATE PROCEDURE Update_Status_Doc
AS
UPDATE Document
SET status = 'Expired'
where GETDATE() > expiry_date;
GO

CREATE PROCEDURE  Remove_Deductions/*not sure if we need to remove the record or just set the amount to 0*/
AS
UPDATE Deduction
SET amount = 0
FROM Deduction d
    INNER JOIN Employee e on d.emp_ID = e.employee_ID
where e.employment_status ='Resigned'
GO

CREATE PROCEDURE Update_Employment_Status
    /*will probably need to use an upcoming procedure to help us but if someone has an idea do write*/
    @Employee_ID int
AS
GO

CREATE PROCEDURE Create_Holiday
AS
CREATE TABLE Holiday
(
    Holiday_ID INT PRIMARY KEY IDENTITY,
    name VARCHAR(50),
    from_date date,
    to_date date
);
GO

CREATE PROCEDURE  Add_Holiday
    @holiday_name VARCHAR(50),
    @from_date date,
    @to_date date
AS
INSERT INTO Holiday
    (name,from_date,to_date)
VALUES(@holiday_name, @from_date, to_date);
GO

CREATE PROCEDURE Intitiate_Attendance/*check later*/
AS
GO

CREATE PROCEDURE Update_Attendance/*could be done with if else but not sure*/
    @Employee_id int,
    @check_in time,
    @check_out time
AS
UPDATE Attendance
SET status = 'Attended',
check_in_time = @check_in,
check_out_time = @check_out
FROM Attendance
    INNER JOIN Employee on Attendance.emp_ID = Employee.employee_ID
WHERE (@Employee_id = emp_ID AND Attendance.total_hours >=8 AND Employee.type_of_contract = 'Full time')
    OR (total_hours<8 AND type_of_contract<>'Part time')
GO

CREATE PROCEDURE Remove_Holiday/*asked gpt here so not 100% if there is a better way*/
AS
DELETE FROM Attendance
where EXISTS(
SELECT *
FROM Holiday
where Attendance.[date] between h.from_date and h.to_date)
GO

CREATE PROCEDURE Remove_DayOff/*based on the previous one so double check*/
    @Employee_id int
AS
DELETE FROM Attendance 
where EXISTS(
SELECT official_day_off
FROM Employee
where @Employee_id = Employee.employee_ID)
GO

CREATE PROCEDURE  Remove_Approved_Leaves
    @Employee_id int
AS
DELETE FROM Attendance
WHERE EXISTS(
SELECT final_approval_status
from leave l
    INNER JOIN Employee_Approve_Leave ea ON ea.Leave_ID = l.request_ID
    INNER JOIN Employee e ON e.employee_ID = ea.Emp1_ID
where Attendance.[date] >=l.start_date AND Attendance.[date]<=end_date)
GO

CREATE PROCEDURE Replace_employee/*not sure if its just let emp1 from the table be 2 and 2 be 1 or not so will check later*/
    @Emp1_ID int,
    @Emp2_ID int,
    @from_date date,
    @to_date date
AS
GO