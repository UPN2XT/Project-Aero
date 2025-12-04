package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class allEmployeeAttendance {
    private Integer attendance_ID;
    private LocalDate date;
    private LocalTime check_in_time;
    private LocalTime check_out_time;
    private Integer total_duration;
    private String status;
    private Integer emp_ID;
}
