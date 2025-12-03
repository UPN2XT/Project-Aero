package com.upn2xt.Aero.Admin.Repos.Imp;

import com.upn2xt.Aero.Admin.Dtos.*;
import com.upn2xt.Aero.Admin.Mapper.AdminMapper;
import com.upn2xt.Aero.Admin.Repos.AdminRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.sql.Time;
import java.util.List;

@Repository
public class AdminRepoImp implements AdminRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public List<EmployeeProfile> allProfiles() {
        String sql = "SELECT * FROM dbo.AllEmployeeProfiles";
        return jdbcTemplate.query(sql, AdminMapper::mapProfile);
    }

    @Override
    public List<EmployeeDeptCount> deptCounts() {
        String sql = "SELECT * FROM dbo.EmployeeCountPerDepartment";
        return jdbcTemplate.query(sql, AdminMapper::mapDeptCount);
    }

    @Override
    public List<RejectedMedical> rejectedMedicals() {
        String sql = "SELECT * FROM dbo.RejectedMedicalLeaves";
        return jdbcTemplate.query(sql, AdminMapper::mapRejectedMedical);
    }

    @Override
    public void removeDeductionsOfResigned() {
        String sql = "EXEC dbo.RemoveDeductionsOfResignedEmployees";
        jdbcTemplate.update(sql);
    }

    @Override
    public void updateAttendance(UpdateAttendance dto) {
        String sql = "EXEC dbo.UpdateAttendance ?, ?, ?, ?";
        jdbcTemplate.update(
                sql,
                dto.getEmpId(),
                Time.valueOf(dto.getCheckIn()),
                Time.valueOf(dto.getCheckOut()),
                dto.getStatus()
        );
    }

    @Override
    public void addHoliday(AddHoliday dto) {
        String sql = "EXEC dbo.AddOfficialHoliday ?, ?";
        jdbcTemplate.update(
                sql,
                Date.valueOf(dto.getDate()),
                dto.getDescription()
        );
    }

    @Override
    public void initiateTodayAttendance() {
        String sql = "EXEC dbo.InitiateTodayAttendance";
        jdbcTemplate.update(sql);
    }

    @Override
    public List<AdminAttendanceRecord> attendanceYesterday() {
        String sql = "SELECT * FROM dbo.AttendanceYesterday";
        return jdbcTemplate.query(sql, AdminMapper::mapAdminAttendance);
    }

    @Override
    public List<AdminPerformanceRecord> winterPerformance() {
        String sql = "SELECT * FROM dbo.WinterSemesterPerformance";
        return jdbcTemplate.query(sql, AdminMapper::mapAdminPerformance);
    }

    @Override
    public void removeHolidayAttendance() {
        String sql = "EXEC dbo.RemoveHolidayAttendance";
        jdbcTemplate.update(sql);
    }

    @Override
    public void removeDayOff(RemoveDayOff dto) {
        String sql = "EXEC dbo.RemoveUnattendedDayOff ?, ?";
        jdbcTemplate.update(
                sql,
                dto.getEmpId(),
                Date.valueOf(dto.getDate())
        );
    }

    @Override
    public void removeLeaveFromAttendance(RemoveLeaveFromAttendance dto) {
        String sql = "EXEC dbo.RemoveLeaveFromAttendance ?, ?";
        jdbcTemplate.update(
                sql,
                dto.getEmpId(),
                dto.getRequestId()
        );
    }

    @Override
    public void replaceEmployee(ReplaceEmployee dto) {
        String sql = "EXEC dbo.ReplaceEmployee ?, ?, ?, ?";
        jdbcTemplate.update(
                sql,
                dto.getEmp1Id(),
                dto.getEmp2Id(),
                Date.valueOf(dto.getFromDate()),
                Date.valueOf(dto.getToDate())
        );
    }

    @Override
    public void updateStatuses() {
        String sql = "EXEC dbo.UpdateEmploymentStatuses";
        jdbcTemplate.update(sql);
    }
}
