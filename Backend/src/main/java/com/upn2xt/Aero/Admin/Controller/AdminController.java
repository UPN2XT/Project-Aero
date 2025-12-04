package com.upn2xt.Aero.Admin.Controller;

import com.upn2xt.Aero.Admin.Dtos.*;
import com.upn2xt.Aero.Admin.Repos.AdminRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
/*
    @Autowired
    private AdminRepo adminRepo;

    @PostMapping("/profiles")
    public List<EmployeeProfile> allProfiles() {
        return adminRepo.allProfiles();
    }

    @PostMapping("/dept-count")
    public List<EmployeeDeptCount> deptCount() {
        return adminRepo.deptCounts();
    }

    @PostMapping("/rejected-medicals")
    public List<RejectedMedical> rejectedMedicals() {
        return adminRepo.rejectedMedicals();
    }

    @PostMapping("/remove-resigned-deductions")
    public void removeDeductions() {
        adminRepo.removeDeductionsOfResigned();
    }

    @PostMapping("/update-attendance")
    public void updateAttendance(@RequestBody UpdateAttendance dto) {
        adminRepo.updateAttendance(dto);
    }

    @PostMapping("/add-holiday")
    public void addHoliday(@RequestBody AddHoliday dto) {
        adminRepo.addHoliday(dto);
    }

    @PostMapping("/init-today-attendance")
    public void initTodayAttendance() {
        adminRepo.initiateTodayAttendance();
    }

    @PostMapping("/attendance-yesterday")
    public List<AdminAttendanceRecord> attendanceYesterday() {
        return adminRepo.attendanceYesterday();
    }

    @PostMapping("/winter-performance")
    public List<AdminPerformanceRecord> winterPerformance() {
        return adminRepo.winterPerformance();
    }

    @PostMapping("/remove-holiday-attendance")
    public void removeHolidayAttendance() {
        adminRepo.removeHolidayAttendance();
    }

    @PostMapping("/remove-dayoff")
    public void removeDayOff(@RequestBody RemoveDayOff dto) {
        adminRepo.removeDayOff(dto);
    }

    @PostMapping("/remove-leave-attendance")
    public void removeLeaveAttendance(@RequestBody RemoveLeaveFromAttendance dto) {
        adminRepo.removeLeaveFromAttendance(dto);
    }

    @PostMapping("/replace-employee")
    public void replaceEmployee(@RequestBody ReplaceEmployee dto) {
        adminRepo.replaceEmployee(dto);
    }

    @PostMapping("/update-status")
    public void updateStatuses() {
        adminRepo.updateStatuses();
    }*/
}
