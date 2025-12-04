package com.upn2xt.Aero.Employee.Dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SubmitMedical {

    @NotNull(message = "Start date is required")
    private LocalDate start;

    @NotNull(message = "End date is required")
    private LocalDate end;

    @NotBlank(message = "Medical leave type is required")
    @Pattern(regexp = "^(sick|maternity)$", message = "Type must be either 'sick' or 'maternity'")
    private String type;

    @NotNull(message = "Insurance status is required")
    private Integer insurancestatus;

    @Size(max = 50, message = "Disability details must not exceed 50 characters")
    private String disability;

    @NotBlank(message = "Document is required")
    private String document;

    @NotBlank(message = "File name is required")
    @Size(max = 50, message = "File name must not exceed 50 characters")
    private String fileName;
}
