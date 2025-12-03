package com.upn2xt.Aero.HR.Dtos;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.sql.Date;

@EqualsAndHashCode(callSuper = true)
@Data
public class AddPayrollRequest extends  EmployeePayrollRequest {
    private Date fromDate;
    private Date toDate;
}
