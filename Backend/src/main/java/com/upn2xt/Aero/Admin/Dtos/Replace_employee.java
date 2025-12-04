package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;

@Data
public class Replace_employee {
    private Integer Emp1_ID;
    private Integer Emp2_ID;
    private LocalDate from_date;
    private LocalDate to_date;
}
