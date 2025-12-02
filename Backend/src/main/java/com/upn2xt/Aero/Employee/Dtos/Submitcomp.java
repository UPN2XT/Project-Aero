package com.upn2xt.Aero.Employee.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class Submitcomp {
    private Integer empId;
    private LocalDate compdate;
    private String reason;
    private LocalDate orgianlday;
    private Integer replacementId;
}
