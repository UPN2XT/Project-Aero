package com.upn2xt.Aero.Employee.Repos.Imp;

import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class EmployeeRepoImp implements EmployeeRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

}
