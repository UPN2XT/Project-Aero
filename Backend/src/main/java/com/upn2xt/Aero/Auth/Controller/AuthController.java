package com.upn2xt.Aero.Auth.Controller;

import com.upn2xt.Aero.Auth.Config.User;
import com.upn2xt.Aero.Auth.Dtos.LoginRequest;
import com.upn2xt.Aero.Auth.Repos.AuthRepo;
import com.upn2xt.Aero.Auth.Services.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthRepo authRepo;

    @Autowired
    private JwtService jwtService;

    @PostMapping("/login/hr")
    private String loginHR(@RequestBody LoginRequest loginRequest) {
        Integer result = authRepo.hrLogin(loginRequest.getId(), loginRequest.getPassword());

        if (result == 1) {
            User user = User.builder().id(loginRequest.getId()).build();
            return jwtService.generateToken(user);
        }
        return "Login Failed";
    }

    @PostMapping("/login/employee")
    private String loginEmployee(@RequestBody LoginRequest loginRequest) {
        Integer result = authRepo.employeeLogin(loginRequest.getId(), loginRequest.getPassword());

        if (result == 1) {
            User user = User.builder().id(loginRequest.getId()).build();
            return jwtService.generateToken(user);
        }
        return "Login Failed";
    }

}
