package com.upn2xt.Aero.HR.Controller;

import com.upn2xt.Aero.HR.Dtos.*;
import com.upn2xt.Aero.HR.Repos.HrRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/hr")
public class HrController {

    @Autowired
    private HrRepo hrRepo;

    @PostMapping("/get-managed-employees")
    public List<Employee> getEmployeesManaged(Principal principal) {
        return hrRepo.getEmployeesManaged(Integer.parseInt(principal.getName()));
    }

    @PostMapping("/approvals/accidental")
    public void approval_accidental(@RequestBody LeaveRequestApprovalRequest request, Principal principal) {
        hrRepo.HR_approval_an_acc(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @PostMapping("/approvals/annual")
    public void approval_annual(@RequestBody LeaveRequestApprovalRequest request, Principal principal) {
        hrRepo.HR_approval_an_acc(request.getRequest_id(), Integer.parseInt(principal.getName()));

    }

    @PostMapping("/approvals/unpaid")
    public void approval_unpaid(@RequestBody LeaveRequestApprovalRequest request, Principal principal) {
        hrRepo.HR_approval_unpaid(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @PostMapping("/approvals/compensation")
    public void approval_compensation(@RequestBody LeaveRequestApprovalRequest request, Principal principal) {
        hrRepo.HR_approval_comp(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @PostMapping("/approvals/get-all")
    public List<Leave> get_approvals(Principal principal) {
        return hrRepo.getApprovalOFLeaves(Integer.parseInt(principal.getName()));
    }

    @PostMapping("/deductions/hours")
    public void deduction_hours(@RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_hours(request.getEmployee_id());
    }

    @PostMapping("/deductions/days")
    public void deduction_days(@RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_days(request.getEmployee_id());
    }

    @PostMapping("/deductions/unpaid")
    public void deduction_unpaid(@RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_unpaid(request.getEmployee_id());
    }

    @PostMapping("/payrolls/add")
    public void add_payroll(@RequestBody AddPayrollRequest request) {
        hrRepo.Add_Payroll(request.getEmployee_id(), request.getFromDate(), request.getToDate());
    }

}
