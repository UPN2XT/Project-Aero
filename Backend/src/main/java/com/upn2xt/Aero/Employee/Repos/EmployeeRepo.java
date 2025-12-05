package com.upn2xt.Aero.Employee.Repos;

import com.upn2xt.Aero.Employee.Dtos.*;
import com.upn2xt.Aero.HR.Dtos.Employee;

import java.time.LocalDate;
import java.util.List;

public interface EmployeeRepo {

    List<Attendance> myAttendance (Integer empId);
    List<Performance> myPerformance (Integer empId,String sem);
    List<PayRoll> last_month_payroll(Integer empId);
    List<Deduction> Deductions_Attendance(Integer empId,Integer month);
    void Submit_annual(SubmitAnnual annual, Integer empId);
    void Upperboard_approve_annual(Upperboardapproval uba, Integer id);
    void Submit_accidental(SubmitAccidental accidental, Integer empId);
    void Submit_medical(SubmitMedical medical, Integer empId);
    void Submit_unpaid(Submitunpaid unpaid, Integer empId);
    void Upperboard_approve_unpaids(Upperboardapproval uba, Integer id);
    void Submit_compensation(Submitcomp compensation, Integer empId);
    void Dean_andHR_Evaluation(Eval eval);
    List<LeaveStatus> Status_leaves(Integer empId);
    List<Employee> getEmployeesManged(Integer empId);
    Me getMe(Integer empId);




}
