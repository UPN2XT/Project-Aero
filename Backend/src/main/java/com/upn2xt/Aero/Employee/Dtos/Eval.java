package com.upn2xt.Aero.Employee.Dtos;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Eval {

    @NotNull(message = "Employee ID is required")
    @Positive(message = "Employee ID must be a positive integer")
    private Integer empId;

    @NotNull(message = "Rating is required")
    @Min(value = 1, message = "Rating must be at least 1")
    @Max(value = 5, message = "Rating must not exceed 5")
    private Integer rating;

    @Size(max = 50, message = "Comment must not exceed 50 characters")
    private String comment;

    @NotBlank(message = "Semester is required")
    @Pattern(regexp = "^[WS]\\d{2}$", message = "Semester must be in format 'W25' or 'S25' (W/S followed by 2 digits)")
    private String sem;
}
