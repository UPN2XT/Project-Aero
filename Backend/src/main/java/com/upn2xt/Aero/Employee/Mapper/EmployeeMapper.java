package com.upn2xt.Aero.Employee.Mapper;

import com.upn2xt.Aero.Employee.Dtos.Attendance;

import java.sql.ResultSet;
import java.sql.SQLException;

public class EmployeeMapper {

    public static Attendance mapAttendance(ResultSet rs, int rowNum) throws SQLException {

            Attendance attendance = new Attendance();
            attendance.setAttendanceId(rs.getInt("attendance_ID"));
            if (rs.getDate("date") != null) {
                attendance.setDate(rs.getDate("date").toLocalDate());
            }
            if (rs.getTime("check_in_time") != null) {
                attendance.setCheckInTime(rs.getTime("check_in_time").toLocalTime());
            }
            if (rs.getTime("check_out_time") != null) {
                attendance.setCheckOutTime(rs.getTime("check_out_time").toLocalTime());
            }
            attendance.setTotalDuration(rs.getInt("total_duration"));
            attendance.setStatus(rs.getString("status"));
            attendance.setEmpId(rs.getInt("emp_ID"));
            return attendance;

    }

}
