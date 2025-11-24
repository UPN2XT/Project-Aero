DROP DATABASE University_HR_ManagementSystem_Team_97;

USE University_HR_ManagementSystem_Team_97;

EXEC dbo.createAllTables
GO

-- test 1 a
DROP PROCEDURE dbo.init_values
EXECUTE dbo.createAllTables
EXECUTE dbo.init_values
GO

PRINT dbo.HRLoginValidation(4, '904')

SELECT *
FROM Employee


