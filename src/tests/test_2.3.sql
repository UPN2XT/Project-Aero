USE University_HR_ManagementSystem_Team_97;
GO

INSERT INTO Document (type, description, file_name, creation_date, expiry_date, status, emp_ID)
VALUES ('TestDoc', 'Should Expire', 'TestFile1', DATEADD(year, -1, GETDATE()), DATEADD(day, -1, GETDATE()), 'valid', 1);

SELECT Count(*) as 'Expired Docs Before' FROM Document WHERE status = 'expired';

EXEC Update_Status_Doc;

SELECT Count(*) as 'Expired Docs After' FROM Document WHERE status = 'expired';

IF EXISTS (SELECT 1 FROM Document WHERE file_name = 'TestFile1' AND status = 'expired')
    PRINT '   [SUCCESS] TestFile1 was updated to expired.'
ELSE
    PRINT '   [FAIL] TestFile1 was NOT updated.';

INSERT INTO Deduction (emp_ID, date, amount, type, status)
VALUES (15, GETDATE(), 500.00, 'missing_hours', 'pending');

SELECT Count(*) FROM Deduction WHERE emp_ID = 15;

EXEC Remove_Deductions;

PRINT '   [After] Deduction count for Resigned Emp 15 (Should be 0):'
SELECT Count(*) FROM Deduction WHERE emp_ID = 15;

UPDATE Employee SET employment_status = 'active' WHERE employee_ID = 3;

INSERT INTO Leave (date_of_request, start_date, end_date, final_approval_status)
VALUES (GETDATE(), DATEADD(day, -1, GETDATE()), DATEADD(day, 1, GETDATE()), 'approved');
DECLARE @NewLeaveID INT = SCOPE_IDENTITY();

INSERT INTO Medical_Leave (request_ID, emp_ID, type, insurance_status)
VALUES (@NewLeaveID, 3, 'sick', 1);

EXEC Update_Employment_Status @Employee_ID = 3;

SELECT employment_status FROM Employee WHERE employee_ID = 3;

IF OBJECT_ID('Holiday', 'U') IS NULL
    EXEC Create_Holiday;
ELSE 
    PRINT '   (Holiday table already exists, skipping Create_Holiday)'

EXEC Add_Holiday @holiday_name = 'Test Holiday', @from_date = '2025-12-25', @to_date = '2025-12-26';

SELECT * FROM Holiday WHERE name = 'Test Holiday';

EXEC Intitiate_Attendance;

SELECT TOP 5 * FROM Attendance WHERE date = CAST(GETDATE() AS DATE) AND status = 'absent';

DECLARE @CheckIn TIME = '09:00:00';
DECLARE @CheckOut TIME = '17:00:00';

EXEC Update_Attendance @Employee_id = 1, @check_in = @CheckIn, @check_out = @CheckOut;

SELECT * FROM Attendance WHERE emp_ID = 1 AND date = CAST(GETDATE() AS DATE);

EXEC Add_Holiday @holiday_name = 'Today Holiday', @from_date = '2025-01-01', @to_date = '2025-12-31'; 

DROP TABLE IF EXISTS #TempAtt;

SELECT * INTO #TempAtt FROM Attendance WHERE emp_ID = 2 AND date = CAST(GETDATE() AS DATE);

EXEC Remove_Holiday;

SELECT * FROM Attendance WHERE emp_ID = 2 AND date = CAST(GETDATE() AS DATE);

DECLARE @SatDate DATE = '2025-11-22';
INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID)
VALUES (@SatDate, '09:00', '17:00', 'attended', 1);

EXEC Remove_DayOff @Employee_id = 1;

SELECT * FROM Attendance WHERE emp_ID = 1 AND date = @SatDate;

INSERT INTO Attendance (date, check_in_time, check_out_time, status, emp_ID)
VALUES (CAST(GETDATE() AS DATE), '09:00', '17:00', 'attended', 3);

SELECT Count(*) FROM Attendance WHERE emp_ID = 3 AND date = CAST(GETDATE() AS DATE);

EXEC Remove_Approved_Leaves @Employee_id = 3;

SELECT Count(*) FROM Attendance WHERE emp_ID = 3 AND date = CAST(GETDATE() AS DATE);

DECLARE @FromDate DATE = CAST(GETDATE() AS DATE);
DECLARE @ToDate DATE = CAST(GETDATE() AS DATE);

EXEC Replace_employee @Emp1_ID = 3, @Emp2_ID = 1, @from_date = @FromDate, @to_date = @ToDate;

SELECT * FROM Employee_Replace_Employee WHERE Emp1_ID = 3 AND Emp2_ID = 1;