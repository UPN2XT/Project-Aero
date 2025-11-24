USE University_HR_ManagementSystem_Team_97;
GO

SELECT HRLoginValidation(5,'670') as HRlogin --todo, 'HRLoginValidation' is not a recognized built-in function name.

exec dbo.HR_approval_an_acc @request_ID = 3 ,@HR_ID = 5

exec dbo.HR_approval_an_acc @request_ID = 3 ,@HR_ID = 13

select * From dbo. Employee_Approve_Leave
where Leave_ID = 3


