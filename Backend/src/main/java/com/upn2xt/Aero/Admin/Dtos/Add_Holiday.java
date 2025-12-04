package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;

@Data
public class Add_Holiday {
    private String holiday_name;
    private LocalDate from_Date;
    private LocalDate to_Date;
}

