package com.upn2xt.Aero.Admin.Mapper;

import com.upn2xt.Aero.Admin.Dtos.*;

import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminMapper {

    public static allEmployeeProfiles mapAllEmployeeProfiles(ResultSet rs, int rowNum) throws SQLException {
        allEmployeeProfiles p = new allEmployeeProfiles();
        p.setEmployee_ID(rs.getInt("employee_ID"));
        p.setFirst_name(rs.getString("first_name"));
        p.setLast_name(rs.getString("last_name"));
        p.setGender(rs.getString("gender"));
        p.setEmail(rs.getString("email"));
        p.setAddress(rs.getString("address"));
        p.setYears_of_experience(rs.getInt("years_of_experience"));
        p.setOfficial_day_off(rs.getString("official_day_off"));
        p.setType_of_contract(rs.getString("type_of_contract"));
        p.setEmployment_status(rs.getString("employment_status"));
        p.setAnnual_balance(rs.getInt("annual_balance"));
        p.setAccidental_balance(rs.getInt("accidental_balance"));
        return p;
    }

    public static NoEmployeeDept mapNoEmployeeDept(ResultSet rs, int rowNum) throws SQLException {
        NoEmployeeDept n = new NoEmployeeDept();
        n.setDept_name(rs.getString("Department"));
        n.setNum_employees(rs.getInt("Number of Employees"));
        return n;
    }

    public static allRejectedMedicals mapAllRejectedMedicals(ResultSet rs, int rowNum) throws SQLException {
        allRejectedMedicals m = new allRejectedMedicals();

        m.setRequest_ID(rs.getInt("request_ID"));
        m.setEmp_ID(rs.getInt("Emp_ID"));

        if (rs.getDate("date_of_request") != null) {
            m.setDate_of_request(rs.getDate("date_of_request").toLocalDate());
        }
        if (rs.getDate("start_date") != null) {
            m.setStart_date(rs.getDate("start_date").toLocalDate());
        }
        if (rs.getDate("end_date") != null) {
            m.setEnd_date(rs.getDate("end_date").toLocalDate());
        }

        m.setType(rs.getString("type"));
        m.setInsurance_status(rs.getBoolean("insurance_status"));
        m.setDisability_details(rs.getString("disability_details"));
        m.setFinal_approval_status(rs.getString("final_approval_status"));

        return m;
    }

    public static allEmployeeAttendance mapAllEmployeeAttendance(ResultSet rs, int rowNum) throws SQLException {
        allEmployeeAttendance a = new allEmployeeAttendance();

        a.setAttendance_ID(rs.getInt("attendance_ID"));

        if (rs.getDate("date") != null) {
            a.setDate(rs.getDate("date").toLocalDate());
        }
        if (rs.getTime("check_in_time") != null) {
            a.setCheck_in_time(rs.getTime("check_in_time").toLocalTime());
        }
        if (rs.getTime("check_out_time") != null) {
            a.setCheck_out_time(rs.getTime("check_out_time").toLocalTime());
        }

        a.setTotal_duration(rs.getInt("total_duration"));
        a.setStatus(rs.getString("status"));
        a.setEmp_ID(rs.getInt("emp_ID"));

        return a;
    }

    public static allPerformance mapAllPerformance(ResultSet rs, int rowNum) throws SQLException {
        allPerformance p = new allPerformance();

        p.setPerformance_ID(rs.getInt("performance_ID"));
        p.setRating(rs.getInt("rating"));
        p.setComments(rs.getString("comments"));
        p.setSemester(rs.getString("semester"));
        p.setEmp_ID(rs.getInt("emp_ID"));

        return p;
    }
}
