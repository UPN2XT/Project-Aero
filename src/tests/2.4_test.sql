USE University_HR_ManagementSystem_Team_97;
GO

SELECT HRLoginValidation(5,'670') as HRlogin --todo, 'HRLoginValidation' is not a recognized built-in function name.
---------------------------------------------------------------------------------------------------------

exec dbo.HR_approval_an_acc @request_ID = 3 ,@HR_ID = 5--todo, kept getting error that autp_update_annual isnt recognized

exec dbo.HR_approval_an_acc @request_ID = 3 ,@HR_ID = 13

UPDATE dbo.Employee_Approve_Leave
set status = 'pending'
where Leave_ID = 3

select * From dbo. Employee_Approve_Leave
where Leave_ID = 3

select * from dbo.Leave--final status needs to be changed
where request_ID = 3

-----------------------------------------------------------------------------

select * from Unpaid_Leave ul
inner join Leave l ON L.request_ID = ul.request_ID

exec  HR_approval_unpaid @request_id = 15 ,@HR_id =5 --Error:employee within the hierarchy rejected the leave despite commenting out that check to see if the auto updates will work




