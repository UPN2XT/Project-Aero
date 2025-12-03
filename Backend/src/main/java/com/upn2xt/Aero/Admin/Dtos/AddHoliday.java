package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;

@Data
public class AddHoliday {
    private LocalDate date;
    private String occasion;
}
