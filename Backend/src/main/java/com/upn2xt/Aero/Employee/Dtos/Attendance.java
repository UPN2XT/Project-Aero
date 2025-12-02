package com.upn2xt.Aero.Employee.Dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Attendance {
    private Integer attendanceId;
    private LocalDate date;
    private LocalTime checkInTime;
    private LocalTime checkOutTime;
    private Integer totalDuration; // Computed column (minutes)
    private String status;
    private Integer empId;
}
