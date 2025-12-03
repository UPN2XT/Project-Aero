package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;

@Data
public class EmployeeProfile {
    private Integer employeeId;
    private String firstName;
    private String lastName;
    private String email;
    private String department;
    private String employmentStatus;
}
