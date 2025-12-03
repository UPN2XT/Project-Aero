package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class AdminAttendanceRecord {
    private Integer empId;
    private LocalDate date;
    private LocalTime checkIn;
    private LocalTime checkOut;
    private Integer totalDuration;
    private String status;
}
