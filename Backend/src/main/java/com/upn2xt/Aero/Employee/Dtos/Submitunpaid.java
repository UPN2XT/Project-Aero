package com.upn2xt.Aero.Employee.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class Submitunpaid {
    private Integer empId;
    private LocalDate start;
    private LocalDate end;
    private String document;
    private String filename;
}
