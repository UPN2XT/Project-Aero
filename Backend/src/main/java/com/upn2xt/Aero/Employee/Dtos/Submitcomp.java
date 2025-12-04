package com.upn2xt.Aero.Employee.Dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Submitcomp {

    @NotNull(message = "Compensation date is required")
    private LocalDate compdate;

    @NotBlank(message = "Reason is required")
    @Size(max = 50, message = "Reason must not exceed 50 characters")
    private String reason;

    @NotNull(message = "Original workday date is required")
    private LocalDate orgianlday;

    @Positive(message = "Replacement ID must be a positive integer")
    private Integer replacementId;
}
