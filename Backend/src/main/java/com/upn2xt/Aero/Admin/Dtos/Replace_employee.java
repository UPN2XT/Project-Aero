package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import java.time.LocalDate;

@Data
@Schema(description = "Request body for replacing one employee with another")
public class Replace_employee {

    @NotNull(message = "First employee ID is required")
    @Positive(message = "First employee ID must be a positive integer")
    @Schema(description = "ID of the employee to be replaced", example = "1", required = true)
    private Integer Emp1_ID;

    @NotNull(message = "Second employee ID is required")
    @Positive(message = "Second employee ID must be a positive integer")
    @Schema(description = "ID of the replacement employee", example = "2", required = true)
    private Integer Emp2_ID;

    @NotNull(message = "From date is required")
    @Schema(description = "Start date of the replacement period", example = "2025-12-01", required = true)
    private LocalDate from_date;

    @NotNull(message = "To date is required")
    @Schema(description = "End date of the replacement period", example = "2025-12-15", required = true)
    private LocalDate to_date;
}
