package com.upn2xt.Aero.HR.Repos;

import com.upn2xt.Aero.HR.Dtos.Employee;
import com.upn2xt.Aero.HR.Dtos.Leave;

import java.time.LocalDate;
import java.util.List;

public interface HrRepo {

    void HR_approval_an_acc(Integer request_id, Integer hr_id);

    void HR_approval_unpaid(Integer request_id, Integer hr_id);

    void HR_approval_comp(Integer request_id, Integer hr_id);

    void Deduction_hours(Integer employee_id);

    void Deduction_days(Integer employee_id);

    void Deduction_unpaid(Integer employee_id);

    void Add_Payroll(Integer employee_id, LocalDate from_date, LocalDate to_date);

    List<Leave> getApprovalOFLeaves(Integer hr_id);

    List<Employee> getEmployeesManaged(Integer hr_id);

}
