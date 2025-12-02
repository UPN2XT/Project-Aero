package com.upn2xt.Aero.Employee.Repos;

import com.upn2xt.Aero.Employee.Dtos.*;

import java.time.LocalDate;
import java.util.List;

public interface EmployeeRepo {

    List<Attendance> myAttendance (Integer empId);
    List<Performance> myPerformance (Integer empId,String sem);
    List<PayRoll> last_month_payroll(Integer empId);
    List<Deduction> Deductions_Attendance(Integer empId,Integer month);
    void Submit_annual(SubmitAnnual annual);
    void Upperboard_approve_annual(Upperboardapproval uba);
    void Submit_accidental(SubmitAccidental accidental);
    void Submit_medical(SubmitMedical medical);
    void Submit_unpaid(Submitunpaid unpaid);
    void Upperboard_approve_unpaids(Upperboardapproval uba);
    void Submit_compensation(Submitcomp compensation);
    void Dean_andHR_Evaluation(Eval eval);
    List<Object> Status_leaves();//TODO




}
