package com.upn2xt.Aero.Employee.Repos.Imp;

import com.upn2xt.Aero.Employee.Dtos.Attendance;
import com.upn2xt.Aero.Employee.Mapper.EmployeeMapper;
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
                EmployeeMapper::mapAttendance,
                empId
        );
    }

    @Override
    public List<Object> myPerformance(Integer empId) {
        return List.of();
    }
}
