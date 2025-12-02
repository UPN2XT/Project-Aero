package com.upn2xt.Aero.Admin.Controller;

import com.upn2xt.Aero.Admin.Repos.AdminRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminRepo adminRepo;


}
