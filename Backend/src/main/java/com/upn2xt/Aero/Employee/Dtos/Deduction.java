package com.upn2xt.Aero.Employee.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class Deduction {
    private Integer deductionID;
    private Integer empID;
    private LocalDate date;
    private Integer amount;
    private String type;
    private String status;
    private Integer unpaidID;
    private Integer attendanceID;
}
