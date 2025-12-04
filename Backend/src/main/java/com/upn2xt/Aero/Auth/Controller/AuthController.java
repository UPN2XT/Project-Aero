package com.upn2xt.Aero.Auth.Controller;

import com.upn2xt.Aero.Auth.Config.User;
import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;
import com.upn2xt.Aero.Auth.Dtos.LoginRequest;
import com.upn2xt.Aero.Auth.Repos.AuthRepo;
import com.upn2xt.Aero.Auth.Services.JwtService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/auth")
@Api(tags = "Authentication", description = "Authentication endpoints for HR and Employee login")
public class AuthController {

    @Autowired
    private AuthRepo authRepo;

    @Autowired
    private JwtService jwtService;

    @ApiOperation(value = "HR Login", notes = "Authenticates an HR employee using their employee ID and password. " +
            "Uses HRLoginValidation SQL function which validates credentials against " +
            "employees in the HR department. Returns a JWT token on successful authentication.", response = String.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully authenticated. Returns JWT token"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Invalid credentials - employee ID or password is incorrect", response = ErrorResponse.class),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/login/hr")
    public ResponseEntity<?> loginHR(
            @ApiParam(value = "Login credentials containing employee ID and password", required = true) @Valid @RequestBody LoginRequest loginRequest) {
        Integer result = authRepo.hrLogin(loginRequest.getId(), loginRequest.getPassword());

        if (result == 1) {
            User user = User.builder().id(loginRequest.getId()).build();
            return ResponseEntity.ok(jwtService.generateToken(user));
        }

        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.UNAUTHORIZED.value(),
                "Unauthorized",
                "Invalid employee ID or password",
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
    }

    @ApiOperation(value = "Employee Login", notes = "Authenticates an employee using their employee ID and password. " +
            "Uses EmployeeLoginValidation SQL function which validates credentials. " +
            "Returns a JWT token on successful authentication.", response = String.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully authenticated. Returns JWT token"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Invalid credentials - employee ID or password is incorrect", response = ErrorResponse.class),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/login/employee")
    public ResponseEntity<?> loginEmployee(
            @ApiParam(value = "Login credentials containing employee ID and password", required = true) @Valid @RequestBody LoginRequest loginRequest) {
        Integer result = authRepo.employeeLogin(loginRequest.getId(), loginRequest.getPassword());

        if (result == 1) {
            User user = User.builder().id(loginRequest.getId()).build();
            return ResponseEntity.ok(jwtService.generateToken(user));
        }

        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.UNAUTHORIZED.value(),
                "Unauthorized",
                "Invalid employee ID or password",
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
    }

}
