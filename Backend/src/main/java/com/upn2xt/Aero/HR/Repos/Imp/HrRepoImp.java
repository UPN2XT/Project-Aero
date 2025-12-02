package com.upn2xt.Aero.HR.Repos.Imp;

import com.upn2xt.Aero.HR.Repos.HrRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class HrRepoImp implements HrRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

}
