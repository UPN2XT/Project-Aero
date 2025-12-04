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
public class SubmitAnnual {

    @NotNull(message = "Replacement employee ID is required")
    @Positive(message = "Replacement employee ID must be a positive integer")
    private Integer replacementID;

    @NotNull(message = "Start date is required")
    private LocalDate start;

    @NotNull(message = "End date is required")
    private LocalDate end;
}
