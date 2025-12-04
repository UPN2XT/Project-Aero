package com.upn2xt.Aero.Employee.Dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubmitAccidental {

    @Positive(message = "Employee ID must be a positive integer")
    private Integer empId;

    @NotNull(message = "Start date is required")
    private LocalDate start;

    @NotNull(message = "End date is required")
    private LocalDate end;
}
