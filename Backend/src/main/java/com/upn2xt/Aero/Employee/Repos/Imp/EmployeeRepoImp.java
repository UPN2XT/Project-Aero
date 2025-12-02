package com.upn2xt.Aero.Employee.Repos.Imp;

import com.upn2xt.Aero.Employee.Dtos.Attendance;
import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class EmployeeRepoImp implements EmployeeRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public List<Attendance> myAttendance(Integer empId) {
        String sql = "SELECT * FROM dbo.MyAttendance(?)";

        return jdbcTemplate.query(
                sql,
                (rs, rowNum) -> {
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
                },
                empId
        );
    }
}
