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
    public List<allEmployeeProfiles> allEmployeeProfiles() {
        String sql = "SELECT * FROM allEmployeeProfiles";
        return jdbcTemplate.query(
                sql,
                AdminMapper::mapAllEmployeeProfiles);
    }

    @Override
    public List<NoEmployeeDept> NoEmployeeDept() {
        String sql = "SELECT * FROM NoEmployeeDept";
        return jdbcTemplate.query(
                sql,
                AdminMapper::mapNoEmployeeDept);
    }

    @Override
    public List<allRejectedMedicals> allRejectedMedicals() {
        String sql = "SELECT * FROM allRejectedMedicals";
        return jdbcTemplate.query(
                sql,
                AdminMapper::mapAllRejectedMedicals);
    }

    @Override
    public List<allEmployeeAttendance> allEmployeeAttendance() {
        String sql = "SELECT * FROM allEmployeeAttendance";
        return jdbcTemplate.query(
                sql,
                AdminMapper::mapAllEmployeeAttendance);
    }

    @Override
    public List<allPerformance> allPerformance() {
        String sql = "SELECT * FROM allPerformance";
        return jdbcTemplate.query(
                sql,
                AdminMapper::mapAllPerformance);
    }

    @Override
    public void Remove_Deductions() {
        String sql = "EXEC Remove_Deductions";
        jdbcTemplate.update(sql);
    }

    @Override
    public void Add_Holiday(String holiday_name,
            java.time.LocalDate from_date,
            java.time.LocalDate to_date) {
        String sql = "EXEC Add_Holiday ?, ?, ?";
        jdbcTemplate.update(
                sql,
                holiday_name,
                Date.valueOf(from_date),
                Date.valueOf(to_date));
    }

    @Override
    public void Intitiate_Attendance() {
        String sql = "EXEC Initiate_Attendance";
        jdbcTemplate.update(sql);
    }

    @Override
    public void Update_Attendance(Integer Employee_id,
            java.time.LocalTime check_in_time,
            java.time.LocalTime check_out_time) {
        String sql = "EXEC Update_Attendance ?, ?, ?";
        jdbcTemplate.update(
                sql,
                Employee_id,
                Time.valueOf(check_in_time),
                Time.valueOf(check_out_time));
    }

    @Override
    public void Remove_Holiday() {
        String sql = "EXEC Remove_Holiday";
        jdbcTemplate.update(sql);
    }

    @Override
    public void Remove_DayOff(Integer Employee_id) {
        String sql = "EXEC Remove_DayOff ?";
        jdbcTemplate.update(
                sql,
                Employee_id);
    }

    @Override
    public void Remove_Approved_Leaves(Integer Employee_id) {
        String sql = "EXEC Remove_Approved_Leaves ?";
        jdbcTemplate.update(
                sql,
                Employee_id);
    }

    @Override
    public void Replace_employee(Integer Emp1_ID,
            Integer Emp2_ID,
            java.time.LocalDate from_date,
            java.time.LocalDate to_date) {
        String sql = "EXEC Replace_employee ?, ?, ?, ?";
        jdbcTemplate.update(
                sql,
                Emp1_ID,
                Emp2_ID,
                Date.valueOf(from_date),
                Date.valueOf(to_date));
    }
}
