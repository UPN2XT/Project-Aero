package com.upn2xt.Aero.HR.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Leave {
    private Integer requestId;
    private Integer empId;
    private String type;
    private LocalDate dateOfRequest;
    private String status;
}
