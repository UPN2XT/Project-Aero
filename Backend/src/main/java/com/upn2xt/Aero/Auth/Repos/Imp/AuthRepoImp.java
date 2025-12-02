package com.upn2xt.Aero.Auth.Repos.Imp;

import com.upn2xt.Aero.Auth.Repos.AuthRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AuthRepoImp implements AuthRepo {

    private JdbcTemplate jdbcTemplate;

    @Autowired
    public AuthRepoImp(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }


    @Override
    public Integer hrLogin(Integer id, String password) {
        String sql = "SELECT dbo.HRLoginValidation(?,?)";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, id, password);
        return result != null ? result : 0;
    }

    @Override
    public Integer employeeLogin(Integer id, String password) {
        String sql = "SELECT dbo.EmployeeLoginValidation(?,?)";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, id, password);
        return result != null ? result : 0;
    }
}
