package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import java.time.LocalDate;

@Data
@Schema(description = "Request body for adding a new holiday")
public class Add_Holiday {

    @NotBlank(message = "Holiday name is required")
    @Size(min = 1, max = 100, message = "Holiday name must be between 1 and 100 characters")
    @Schema(description = "Name of the holiday", example = "National Day", required = true)
    private String holiday_name;

    @NotNull(message = "From date is required")
    @Schema(description = "Start date of the holiday", example = "2025-12-25", required = true)
    private LocalDate from_Date;

    @NotNull(message = "To date is required")
    @Schema(description = "End date of the holiday", example = "2025-12-26", required = true)
    private LocalDate to_Date;
}
