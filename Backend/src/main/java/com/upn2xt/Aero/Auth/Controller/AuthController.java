package com.upn2xt.Aero.Auth.Controller;

import com.upn2xt.Aero.Auth.Config.User;
import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;
import com.upn2xt.Aero.Auth.Dtos.LoginRequest;
import com.upn2xt.Aero.Auth.Repos.AuthRepo;
import com.upn2xt.Aero.Auth.Services.JwtService;

// New OpenAPI 3 Imports
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Authentication endpoints for HR and Employee login")
public class AuthController {

    @Autowired
    private AuthRepo authRepo;

    @Autowired
    private JwtService jwtService;

    @Operation(
            summary = "HR Login",
            description = "Authenticates an HR employee using their employee ID and password. " +
                    "Uses HRLoginValidation SQL function which validates credentials against " +
                    "employees in the HR department. Returns a JWT token on successful authentication."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully authenticated. Returns JWT token"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Invalid credentials - employee ID or password is incorrect",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/login/hr")
    public ResponseEntity<?> loginHR(
            @Parameter(description = "Login credentials containing employee ID and password", required = true)
            @Valid @RequestBody LoginRequest loginRequest) {

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

    @Operation(
            summary = "Employee Login",
            description = "Authenticates an employee using their employee ID and password. " +
                    "Uses EmployeeLoginValidation SQL function which validates credentials. " +
                    "Returns a JWT token on successful authentication."
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully authenticated. Returns JWT token"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Invalid credentials - employee ID or password is incorrect",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/login/employee")
    public ResponseEntity<?> loginEmployee(
            @Parameter(description = "Login credentials containing employee ID and password", required = true)
            @Valid @RequestBody LoginRequest loginRequest) {

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