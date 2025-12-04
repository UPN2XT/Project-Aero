package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
@Schema(description = "Employee attendance record")
public class allEmployeeAttendance {

    @Schema(description = "Unique attendance record identifier", example = "1")
    private Integer attendance_ID;

    @Schema(description = "Date of the attendance record", example = "2025-12-03")
    private LocalDate date;

    @Schema(description = "Time when employee checked in", example = "09:00:00")
    private LocalTime check_in_time;

    @Schema(description = "Time when employee checked out", example = "17:30:00")
    private LocalTime check_out_time;

    @Schema(description = "Total working duration in minutes", example = "510")
    private Integer total_duration;

    @Schema(description = "Attendance status", example = "Present")
    private String status;

    @Schema(description = "Employee ID", example = "1")
    private Integer emp_ID;
}
