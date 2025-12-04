package com.upn2xt.Aero.Auth.Dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LoginRequest {

    @NotNull(message = "Employee ID is required")
    @Positive(message = "Employee ID must be a positive integer")
    private Integer id;

    @NotBlank(message = "Password is required")
    @Size(max = 50, message = "Password must not exceed 50 characters")
    private String password;

}
