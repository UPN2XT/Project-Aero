package com.upn2xt.Aero.Admin.Controller;

import com.upn2xt.Aero.Admin.Dtos.*;
import com.upn2xt.Aero.Admin.Repos.AdminRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminRepo adminRepo;

    @PostMapping("/all-employee-profiles")
    public List<allEmployeeProfiles> allEmployeeProfiles() {
        return adminRepo.allEmployeeProfiles();
    }

    @PostMapping("/employees-per-department")
    public List<NoEmployeeDept> NoEmployeeDept() {
        return adminRepo.NoEmployeeDept();
    }

    @PostMapping("/rejected-medicals")
    public List<allRejectedMedicals> allRejectedMedicals() {
        return adminRepo.allRejectedMedicals();
    }

    @PostMapping("/yesterday-attendance")
    public List<allEmployeeAttendance> allEmployeeAttendance() {
        return adminRepo.allEmployeeAttendance();
    }

    @PostMapping("/winter-performance")
    public List<allPerformance> allPerformance() {
        return adminRepo.allPerformance();
    }

    @PostMapping("/remove-deductions")
    public void Remove_Deductions() {
        adminRepo.Remove_Deductions();
    }

    @PostMapping("/add-holiday")
    public void Add_Holiday(@RequestBody Add_Holiday holiday) {
        adminRepo.Add_Holiday(
                holiday.getHoliday_name(),
                holiday.getFrom_date(),
                holiday.getTo_date()
        );
    }

    @PostMapping("/initiate-attendance")
    public void Intitiate_Attendance() {
        adminRepo.Intitiate_Attendance();
    }

    @PostMapping("/update-attendance")
    public void Update_Attendance(@RequestBody UpdateAttendance update) {
        adminRepo.Update_Attendance(
                update.getEmployee_id(),
                update.getCheck_in_time(),
                update.getCheck_out_time()
        );
    }

    @PostMapping("/remove-holiday")
    public void Remove_Holiday() {
        adminRepo.Remove_Holiday();
    }

    @PostMapping("/remove-dayoff")
    public void Remove_DayOff(@RequestBody RemoveDayOff request) {
        adminRepo.Remove_DayOff(request.getEmployee_id());
    }

    @PostMapping("/remove-approved-leaves")
    public void Remove_Approved_Leaves(@RequestBody RemoveApprovedLeaves request) {
        adminRepo.Remove_Approved_Leaves(request.getEmployee_id());
    }

    @PostMapping("/replace-employee")
    public void Replace_employee(@RequestBody Replace_employee rep) {
        adminRepo.Replace_employee(
                rep.getEmp1_ID(),
                rep.getEmp2_ID(),
                rep.getFrom_date(),
                rep.getTo_date()
        );
    }
}
