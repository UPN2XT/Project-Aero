package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.time.LocalTime;

@Data
@Schema(description = "Request body for updating employee attendance")
public class UpdateAttendance {

    @NotNull(message = "Employee ID is required")
    @Positive(message = "Employee ID must be a positive integer")
    @Schema(description = "ID of the employee", example = "1", required = true)
    private Integer Employee_id;

    @NotNull(message = "Check-in time is required")
    @Schema(description = "Check-in time of the employee", example = "09:00:00", required = true)
    private LocalTime check_in_time;

    @NotNull(message = "Check-out time is required")
    @Schema(description = "Check-out time of the employee", example = "17:00:00", required = true)
    private LocalTime check_out_time;
}
