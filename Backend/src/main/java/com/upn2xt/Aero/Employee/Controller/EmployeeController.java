package com.upn2xt.Aero.Employee.Controller;

import com.upn2xt.Aero.Employee.Dtos.Attendance;
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
}
