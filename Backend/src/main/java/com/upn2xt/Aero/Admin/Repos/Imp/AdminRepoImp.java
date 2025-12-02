package com.upn2xt.Aero.Admin.Repos.Imp;

import com.upn2xt.Aero.Admin.Repos.AdminRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AdminRepoImp implements AdminRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

}
