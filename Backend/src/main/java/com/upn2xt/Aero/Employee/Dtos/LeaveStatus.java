package com.upn2xt.Aero.Employee.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LeaveStatus {
    private Integer requestId;
    private LocalDate dateOfRequest;
    private String finalApprovalStatus;
}
