package com.upn2xt.Aero.Employee.Controller;

import com.upn2xt.Aero.Employee.Dtos.Attendance;
import com.upn2xt.Aero.Employee.Dtos.Deduction;
import com.upn2xt.Aero.Employee.Dtos.PayRoll;
import com.upn2xt.Aero.Employee.Dtos.Performance;
import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
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
    //TODO leave_status is missing
}
