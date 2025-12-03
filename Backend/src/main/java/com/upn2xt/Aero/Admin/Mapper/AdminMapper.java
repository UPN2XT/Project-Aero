package com.upn2xt.Aero.Admin.Mapper;

import com.upn2xt.Aero.Admin.Dtos.*;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminMapper {

    public static EmployeeProfile mapProfile(ResultSet rs, int rowNum) throws SQLException {
        EmployeeProfile dto = new EmployeeProfile();
        dto.setEmployeeId(rs.getInt("employee_ID"));
        dto.setFirstName(rs.getString("first_name"));
        dto.setLastName(rs.getString("last_name"));
        dto.setEmail(rs.getString("email"));
        dto.setDepartment(rs.getString("dept_name"));
        dto.setEmploymentStatus(rs.getString("employment_status"));
        return dto;
    }

    public static EmployeeDeptCount mapDeptCount(ResultSet rs, int rowNum) throws SQLException {
        EmployeeDeptCount dto = new EmployeeDeptCount();
        dto.setDepartment(rs.getString("department"));
        dto.setCount(rs.getInt("count"));
        return dto;
    }

    public static RejectedMedical mapRejectedMedical(ResultSet rs, int rowNum) throws SQLException {
        RejectedMedical dto = new RejectedMedical();
        dto.setRequestId(rs.getInt("request_ID"));
        dto.setEmpId(rs.getInt("emp_ID"));
        dto.setStartDate(rs.getDate("start_date").toLocalDate());
        dto.setEndDate(rs.getDate("end_date").toLocalDate());
        dto.setType(rs.getString("type"));
        dto.setInsuranceStatus(rs.getBoolean("insurance_status"));
        dto.setDisabilityDetails(rs.getString("disability_details"));
        dto.setFinalStatus(rs.getString("final_approval_status"));
        return dto;
    }

    public static AdminAttendanceRecord mapAdminAttendance(ResultSet rs, int rowNum) throws SQLException {
        AdminAttendanceRecord dto = new AdminAttendanceRecord();
        dto.setEmpId(rs.getInt("emp_ID"));
        dto.setDate(rs.getDate("date").toLocalDate());
        dto.setCheckIn(rs.getTime("check_in_time") != null ? rs.getTime("check_in_time").toLocalTime() : null);
        dto.setCheckOut(rs.getTime("check_out_time") != null ? rs.getTime("check_out_time").toLocalTime() : null);
        dto.setTotalDuration(rs.getInt("total_duration"));
        dto.setStatus(rs.getString("status"));
        return dto;
    }

    public static AdminPerformanceRecord mapAdminPerformance(ResultSet rs, int rowNum) throws SQLException {
        AdminPerformanceRecord dto = new AdminPerformanceRecord();
        dto.setEmpId(rs.getInt("emp_ID"));
        dto.setRating(rs.getInt("rating"));
        dto.setComments(rs.getString("comments"));
        dto.setSemester(rs.getString("semester"));
        return dto;
    }
}
