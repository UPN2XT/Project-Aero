package com.upn2xt.Aero.HR.Dtos;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.sql.Date;

@EqualsAndHashCode(callSuper = true)
@Data
public class AddPayrollRequest extends EmployeePayrollRequest {

    @NotNull(message = "From date is required")
    private Date fromDate;

    @NotNull(message = "To date is required")
    private Date toDate;
}
