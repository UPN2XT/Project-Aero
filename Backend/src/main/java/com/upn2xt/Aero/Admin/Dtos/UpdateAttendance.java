package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalTime;

@Data
public class UpdateAttendance {
    private Integer empId;
    private LocalTime checkIn;
    private LocalTime checkOut;
    private String status;
}
