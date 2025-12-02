package com.upn2xt.Aero.HR.Controller;

import com.upn2xt.Aero.HR.Repos.HrRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/hr")
public class HrController {

    @Autowired
    private HrRepo hrRepo;

}
