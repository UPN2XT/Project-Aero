package com.upn2xt.Aero.Employee.Dtos;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubmitAnnual {
    private Integer empID;
    private Integer replacementID;
    private LocalDate start;
    private LocalDate end;
}
