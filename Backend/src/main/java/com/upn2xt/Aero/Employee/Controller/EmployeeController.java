package com.upn2xt.Aero.Employee.Controller;

import com.upn2xt.Aero.Employee.Dtos.*;
import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
import com.upn2xt.Aero.HR.Dtos.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/employee")
public class EmployeeController {

    @Autowired
    private EmployeeRepo employeeRepo;

    @PostMapping("/my-attendance")
    public List<Attendance> myAttendance(Principal p) {
        return employeeRepo.myAttendance(Integer.parseInt(p.getName()));
    }

    @PostMapping("/status-leaves")
    public List<LeaveStatus> status_leaves(Principal p) {
        return employeeRepo.Status_leaves(Integer.parseInt(p.getName()));
    }

    @PostMapping("/my-performance")
    public List<Performance> myPerformance(Principal p,String sem) {
        return employeeRepo.myPerformance(Integer.parseInt(p.getName()),sem);
    }
    @PostMapping("/last-month-payroll")
    public List<PayRoll> last_month_payroll(Principal p){
        return employeeRepo.last_month_payroll(Integer.parseInt(p.getName()));
    }
    @PostMapping("/deduction-attendance")
    public List<Deduction> Deductions_Attendance(Principal p,Integer month){
        return employeeRepo.Deductions_Attendance(Integer.parseInt(p.getName()),month);
    }

    @PostMapping("/submit/annual")
    public void submit_annual(Principal p, @RequestBody SubmitAnnual submitAnnual){
        employeeRepo.Submit_annual(submitAnnual,Integer.parseInt(p.getName()));
    }

    @PostMapping("/submit/compensation")
    public void submit_compensation(Principal p, @RequestBody Submitcomp submitCompensation){
        employeeRepo.Submit_compensation(submitCompensation,Integer.parseInt(p.getName()));
    }

    @PostMapping("/submit/accidental")
    public void submit_accidental(Principal p, @RequestBody SubmitAccidental submitAccidental) {
        employeeRepo.Submit_accidental(submitAccidental, Integer.parseInt(p.getName()));
    }

    @PostMapping("/submit/unpaid")
    public void submit_unpaid(Principal p, @RequestBody Submitunpaid submitUnpaid) {
        employeeRepo.Submit_unpaid(submitUnpaid, Integer.parseInt(p.getName()));
    }

    @PostMapping("submit/medical")
    public void submit_medical(Principal p, @RequestBody SubmitMedical submitMedical) {
        employeeRepo.Submit_medical(submitMedical, Integer.parseInt(p.getName()));
    }

    @PostMapping("/upperboard/approve/annual")
    public void upperboard_approve_annual(Principal p, @RequestBody Upperboardapproval uba) {
        employeeRepo.Upperboard_approve_annual(uba, Integer.parseInt(p.getName()));
    }

    @PostMapping("/upperboard/approve/unpaid")
    public void upperboard_approve_unpaid(Principal p, @RequestBody Upperboardapproval uba) {
        employeeRepo.Upperboard_approve_unpaids(uba, Integer.parseInt(p.getName()));
    }

    @PostMapping("/dean-hr-evaluation")
    public void dean_andHR_evaluation(@RequestBody Eval eval) {
        employeeRepo.Dean_andHR_Evaluation(eval);
    }

    @PostMapping("/get-managed-employees")
    public List<Employee> getEmployeesManged(Principal p) {
        return employeeRepo.getEmployeesManged(Integer.parseInt(p.getName()));
    }
}
