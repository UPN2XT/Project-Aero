USE University_HR_ManagementSystem
SELECT *
FROM Annual_Leave al
INNER JOIN Leave l ON l.request_id = al.request_id
WHERE emp_id = 1