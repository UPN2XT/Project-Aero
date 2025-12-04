package com.upn2xt.Aero.HR.Dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class EmployeePayrollRequest {

    @NotNull(message = "Employee ID is required")
    @Positive(message = "Employee ID must be a positive integer")
    Integer employee_id;

}
