package com.upn2xt.Aero.Employee.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class PayRoll {
    private Integer ID;
    private LocalDate paymentDate;
    private Integer finalamount;
    private LocalDate from;
    private LocalDate to;
    private String comments;
    private Integer bonus;
    private Integer deduction;
    private Integer empID;
}
