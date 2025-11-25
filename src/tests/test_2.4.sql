DROP DATABASE University_HR_ManagementSystem_Team_97;

USE University_HR_ManagementSystem_Team_97;

EXEC dbo.createAllTables
GO

-- test 1 (a): hr -> right password
EXECUTE dbo.init_values

DECLARE @test1 VARCHAR(50) = CASE WHEN dbo.HRLoginValidation(4, '908') = 1 THEN 'Test 1: Sucesses' ELSE 'Test 1: fail' END
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

-- Execution
EXEC HR_approval_an_acc @request_ID = 6, @HR_ID = 5

-- Validation
DECLARE @test1_status VARCHAR(50)
DECLARE @test1_balance INT
DECLARE @test1_result VARCHAR(100)

SELECT @test1_status = final_approval_status FROM Leave WHERE request_ID = 6
SELECT @test1_balance = accidental_balance FROM Employee WHERE employee_ID = 1

SET @test1_result = CASE 
    WHEN @test1_status = 'approved' AND @test1_balance = 5 THEN 'Test 1: Success' 
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

-- Execution
EXEC HR_approval_an_acc @request_ID = 3, @HR_ID = 5

-- Validation
DECLARE @test2_status VARCHAR(50)
DECLARE @test2_balance INT
DECLARE @test2_result VARCHAR(100)

SELECT @test2_status = final_approval_status FROM Leave WHERE request_ID = 3
SELECT @test2_balance = annual_balance FROM Employee WHERE employee_ID = 3

SET @test2_result = CASE 
    WHEN @test2_status = 'rejected' AND @test2_balance = 0 THEN 'Test 2: Success' 
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

