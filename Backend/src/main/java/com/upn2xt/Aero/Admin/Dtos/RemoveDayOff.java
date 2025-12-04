package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
@Schema(description = "Request body for removing an employee's day off")
public class RemoveDayOff {

    @NotNull(message = "Employee ID is required")
    @Positive(message = "Employee ID must be a positive integer")
    @Schema(description = "ID of the employee", example = "1", required = true)
    private Integer employee_id;
}
