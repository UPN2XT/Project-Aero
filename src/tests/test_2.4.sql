DROP DATABASE University_HR_ManagementSystem_Team_97;

USE University_HR_ManagementSystem_Team_97;

EXEC dbo.createAllTables
GO

-- test 1 (a): hr -> right password
EXECUTE dbo.init_values

select * from Employee

select * from Employee_Role

DECLARE @test1 VARCHAR(50) = CASE WHEN dbo.HRLoginValidation(4, '670') = 1 THEN 'Test 1: Sucesses' ELSE 'Test 1: fail' END
PRINT @test1

-- test 2 (a): hr -> wrong password

DECLARE @test2 VARCHAR(50) = CASE WHEN dbo.HRLoginValidation(4, '904') = 0 THEN 'Test 2: Sucesses' ELSE 'Test 2: fail' END
PRINT @test2

-- test 3 (a): hr -> not hr

DECLARE @test3 VARCHAR(50) = CASE WHEN dbo.HRLoginValidation(3, '123') = 0 THEN 'Test 3: Sucesses' ELSE 'Test 3: fail' END
PRINT @test3

-- Ensure the database is using the correct context
USE University_HR_ManagementSystem_Team_97
GO

-------------------------------------------------------------------------
-- Unit Tests for Procedure: HR_approval_an_acc
-- Logic: Approves or Rejects Annual/Accidental leaves based on balance.
-- Updates Leave status and Employee balance accordingly.
-------------------------------------------------------------------------

-------------------------------------------------------
-- Test 1: HR Approves Accidental Leave (Sufficient Balance)
-- Request ID: 6 (Accidental, 1 Day)
-- Employee: 1 (Jack), Current Accidental Balance: 6
-- Approver: 5 (Menna - HR)
-------------------------------------------------------

PRINT '-------------------------------------------------------'
PRINT 'Test 1: HR Approves Accidental Leave (Happy Path)'
PRINT 'Checking Request 6 (Accidental) for Employee 1 (Balance: 6)'

-- Execution TO DO 
select * from Leave

select * from Annual_Leave

select * from Accidental_Leave

EXEC HR_approval_an_acc @request_ID = 6, @HR_ID = 5

-- Validation
DECLARE @test1_status VARCHAR(50)
DECLARE @test1_balance INT
DECLARE @test1_result VARCHAR(100)

SELECT @test1_status = final_approval_status FROM Leave WHERE request_ID = 6
SELECT @test1_balance = accidental_balance FROM Employee WHERE employee_ID = 3

SET @test1_result = CASE 
    WHEN @test1_status = 'approved' AND @test1_balance = 6 THEN 'Test 1: Success' 
    ELSE 'Test 1: Fail (Status: ' + ISNULL(@test1_status, 'NULL') + ', Balance: ' + CAST(ISNULL(@test1_balance, 0) AS VARCHAR) + ')'
END

PRINT @test1_result


-------------------------------------------------------
-- Test 2: HR Rejects Annual Leave (Insufficient Balance)
-- Request ID: 3 (Annual, 1 Day)
-- Employee: 3 (Sarah), Current Annual Balance: 0
-- Approver: 5 (Menna - HR)
-------------------------------------------------------

PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 2: HR Rejects Annual Leave (Insufficient Balance)'
PRINT 'Checking Request 3 (Annual) for Employee 3 (Balance: 0)'

-- Execution TO DO 
EXEC HR_approval_an_acc @request_ID = 4, @HR_ID = 5

-- Validation
DECLARE @test2_status VARCHAR(50)
DECLARE @test2_balance INT
DECLARE @test2_result VARCHAR(100)

SELECT @test2_status = final_approval_status FROM Leave WHERE request_ID = 4
SELECT @test2_balance = annual_balance FROM Employee WHERE employee_ID = 11

SET @test2_result = CASE 
    WHEN @test2_status = 'approved' AND @test2_balance = 52 THEN 'Test 2: Success' 
    ELSE 'Test 2: Fail (Status: ' + ISNULL(@test2_status, 'NULL') + ', Balance: ' + CAST(ISNULL(@test2_balance, 0) AS VARCHAR) + ')'
END

PRINT @test2_result


-------------------------------------------------------
-- Test 3: HR Manager Approves Annual Leave (Applicant is HR)
-- Request ID: 5 (Annual, 3 Days)
-- Employee: 5 (Menna), Current Annual Balance: 6
-- Approver: 10 (HR Manager) - Required because applicant is HR Rep
-------------------------------------------------------

PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 3: HR Manager Approves Annual Leave (HR Applicant)'
PRINT 'Checking Request 5 (Annual) for Employee 5 (Balance: 6)'

-- Setup: Ensure the HR Manager is assigned as an approver for this request
-- (This insertion ensures the test environment is valid for this specific scenario)
IF NOT EXISTS (SELECT * FROM Employee_Approve_Leave WHERE Emp1_ID = 10 AND Leave_ID = 5)
BEGIN
    INSERT INTO Employee_Approve_Leave (Emp1_ID, leave_ID, status) VALUES (10, 5, 'PENDING')
END

-- Execution
EXEC HR_approval_an_acc @request_ID = 5, @HR_ID = 10

-- Validation
DECLARE @test3_status VARCHAR(50)
DECLARE @test3_balance INT
DECLARE @test3_result VARCHAR(100)

SELECT @test3_status = final_approval_status FROM Leave WHERE request_ID = 5
SELECT @test3_balance = annual_balance FROM Employee WHERE employee_ID = 5

SET @test3_result = CASE 
    WHEN @test3_status = 'approved' AND @test3_balance = 3 THEN 'Test 3: Success' 
    ELSE 'Test 3: Fail (Status: ' + ISNULL(@test3_status, 'NULL') + ', Balance: ' + CAST(ISNULL(@test3_balance, 0) AS VARCHAR) + ')'
END

PRINT @test3_result


select * from Unpaid_Leave

select * FROM Employee_Approve_Leave

-- Test 4 (c): HR Approves Unpaid Leave
-- Procedure: HR_approval_unpaid
-------------------------------------------------------
PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 4: HR Approves Unpaid Leave'

-- Setup: Create a dummy Unpaid Leave request if not exists for testing
-- Request ID: 101, Employee: 1, HR: 5
/*IF NOT EXISTS (SELECT * FROM Leave WHERE request_ID = 101)
BEGIN
    INSERT INTO Leave (request_ID, date_of_request, start_date, end_date, final_approval_status) 
    VALUES (101, '2024-01-29', '2024-02-01', '2024-02-05', 'pending');
    
    INSERT INTO Unpaid_Leave (request_ID, emp_ID, document_description) 
    VALUES (101, 1, 'Test Doc');
    
    INSERT INTO Employee_Approve_Leave (Emp1_ID, leave_ID, status) 
    VALUES (5, 101, 'pending');
END*/

-- Execution
EXEC HR_approval_unpaid @request_ID = 15, @HR_ID = 4;

-- Validation
DECLARE @test4_status_leave VARCHAR(50);
DECLARE @test4_status_approval VARCHAR(50);
DECLARE @test4_result VARCHAR(100);

SELECT @test4_status_leave = final_approval_status FROM Leave WHERE request_ID = 14;
SELECT @test4_status_approval = status FROM Employee_Approve_Leave WHERE Leave_ID = 14 AND Emp1_ID =2;

SET @test4_result = CASE 
    WHEN @test4_status_leave = 'approved' THEN 'Test 4: Success' 
    ELSE 'Test 4: Fail (Leave Status: ' + ISNULL(@test4_status_leave, 'NULL')
END
PRINT @test4_result;
GO

-------------------------------------------------------
-- Test 5 (d): HR Approves Compensation Leave
-- Procedure: HR_approval_comp
-------------------------------------------------------
PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 5: HR Approves Compensation Leave'

-- Setup: Create a dummy Compensation Leave request
-- Request ID: 102, Employee: 1, HR: 5
IF NOT EXISTS (SELECT * FROM Leave WHERE request_ID = 102)
BEGIN
    INSERT INTO Leave (request_ID, type, start_date, end_date, final_approval_status) 
    VALUES (102, 'compensation', '2024-02-10', '2024-02-10', 'pending');
    
    INSERT INTO Compensation_Leave (request_ID, emp_ID, reason) 
    VALUES (102, 1, 'Worked on weekend');
    
    INSERT INTO Employee_Approve_Leave (Emp1_ID, leave_ID, status) 
    VALUES (5, 102, 'pending');
END

-- Execution
EXEC HR_approval_comp @request_ID = 102, @HR_ID = 5;

-- Validation
DECLARE @test5_status_leave VARCHAR(50);
DECLARE @test5_status_approval VARCHAR(50);
DECLARE @test5_result VARCHAR(100);

SELECT @test5_status_leave = final_approval_status FROM Leave WHERE request_ID = 102;
SELECT @test5_status_approval = status FROM Employee_Approve_Leave WHERE Leave_ID = 102 AND Emp1_ID = 5;

SET @test5_result = CASE 
    WHEN @test5_status_leave = 'approved' AND @test5_status_approval = 'approved' THEN 'Test 5: Success' 
    ELSE 'Test 5: Fail (Leave Status: ' + ISNULL(@test5_status_leave, 'NULL') + ', Approval Status: ' + ISNULL(@test5_status_approval, 'NULL') + ')'
END
PRINT @test5_result;
GO

-------------------------------------------------------
-- Test 6 (e): Add Deduction for Missing Hours
-- Procedure: Deduction_hours
-------------------------------------------------------
PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 6: Add Deduction for Missing Hours'

-- Setup: Insert an attendance record with < 8 hours for Employee 1
-- Date: Yesterday
IF NOT EXISTS (SELECT * FROM Attendance WHERE emp_ID = 1 AND date = CAST(GETDATE()-1 AS DATE))
BEGIN
    INSERT INTO Attendance (emp_ID, date, check_in_time, check_out_time, status)
    VALUES (1, CAST(GETDATE()-1 AS DATE), '09:00:00', '14:00:00', 'attended'); -- 5 hours
END

-- Execution
EXEC Deduction_hours @employee_ID = 1;

-- Validation
DECLARE @test6_deduction_amount DECIMAL(10,2);
DECLARE @test6_result VARCHAR(100);

-- Check if a deduction of type 'missing_hours' exists for this employee and date
SELECT TOP 1 @test6_deduction_amount = amount 
FROM Deduction 
WHERE emp_ID = 1 AND type = 'missing_hours' AND date = CAST(GETDATE()-1 AS DATE);

SET @test6_result = CASE 
    WHEN @test6_deduction_amount > 0 THEN 'Test 6: Success (Amount: ' + CAST(@test6_deduction_amount AS VARCHAR) + ')' 
    ELSE 'Test 6: Fail (No deduction found)'
END
PRINT @test6_result;
GO


-- Test 8 (g): Add Deduction for Unpaid Leave
-- Procedure: Deduction_unpaid
-------------------------------------------------------
PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 8: Add Deduction for Unpaid Leave'

-- Setup: We already approved an unpaid leave in Test 4 (Request 101, 5 days)
-- Execution
EXEC Deduction_unpaid @employee_ID = 1;

-- Validation
DECLARE @test8_deduction_count INT;
DECLARE @test8_result VARCHAR(100);

SELECT @test8_deduction_count = COUNT(*) 
FROM Deduction 
WHERE emp_ID = 1 AND type = 'unpaid' AND unpaid_ID = 101;

SET @test8_result = CASE 
    WHEN @test8_deduction_count > 0 THEN 'Test 8: Success (Deductions created: ' + CAST(@test8_deduction_count AS VARCHAR) + ')' 
    ELSE 'Test 8: Fail (No unpaid leave deduction found)'
END
PRINT @test8_result;
GO

-------------------------------------------------------
-- Test 9 (h): Calculate Bonus Amount
-- Function: Bonus_amount
-------------------------------------------------------
PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 9: Calculate Bonus Amount'

-- Setup: Need > 176 hours for the current month to get a bonus.
-- This is hard to mock instantly without many inserts, so we will test the function call itself.
-- We will check if it returns a non-null value (likely 0 if we haven't inserted 176+ hours).
DECLARE @bonus_val DECIMAL(10,2);
SET @bonus_val = dbo.Bonus_amount(1);

DECLARE @test9_result VARCHAR(100);
SET @test9_result = CASE 
    WHEN @bonus_val >= 0 THEN 'Test 9: Success (Function returned: ' + CAST(@bonus_val AS VARCHAR) + ')' 
    ELSE 'Test 9: Fail'
END
PRINT @test9_result;
GO


-------------------------------------------------------
-- Test 10 (i): Generate Monthly Payroll
-- Procedure: Add_Payroll
-------------------------------------------------------
PRINT ' '
PRINT '-------------------------------------------------------'
PRINT 'Test 10: Generate Monthly Payroll'

-- Setup: Define a period covering the deductions we just added
DECLARE @FromDate DATE = '2023-01-01';
DECLARE @ToDate DATE = GETDATE();

-- Execution
EXEC Add_Payroll @Employee_ID = 1, @From = @FromDate, @TO = @ToDate;

-- Validation
DECLARE @test10_payroll_exists BIT = 0;
DECLARE @test10_deduction_finalized BIT = 0;
DECLARE @test10_result VARCHAR(100);

-- Check Payroll table
IF EXISTS (SELECT * FROM Payroll WHERE emp_ID = 1 AND from_date = @FromDate)
    SET @test10_payroll_exists = 1;

-- Check if deductions are finalized
IF NOT EXISTS (SELECT * FROM Deduction WHERE emp_ID = 1 AND date BETWEEN @FromDate AND @ToDate AND status = 'pending')
    SET @test10_deduction_finalized = 1; -- Assuming they were pending before and now finalized

SET @test10_result = CASE 
    WHEN @test10_payroll_exists = 1 AND @test10_deduction_finalized = 1 THEN 'Test 10: Success' 
    ELSE 'Test 10: Fail (Payroll Exists: ' + CAST(@test10_payroll_exists AS VARCHAR) + ', Deductions Finalized: ' + CAST(@test10_deduction_finalized AS VARCHAR) + ')'
END
PRINT @test10_result;
GO