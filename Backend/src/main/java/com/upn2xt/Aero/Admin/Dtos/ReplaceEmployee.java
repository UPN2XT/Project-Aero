package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;

@Data
public class ReplaceEmployee {
    private Integer emp1Id;
    private Integer emp2Id;
    private LocalDate fromDate;
    private LocalDate toDate;
}
