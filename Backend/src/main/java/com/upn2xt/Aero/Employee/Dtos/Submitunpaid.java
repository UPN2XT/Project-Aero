package com.upn2xt.Aero.Employee.Dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Submitunpaid {

    @NotNull(message = "Start date is required")
    private LocalDate start;

    @NotNull(message = "End date is required")
    private LocalDate end;

    @NotBlank(message = "Document is required")
    private String document;

    @NotBlank(message = "Filename is required")
    @Size(max = 50, message = "Filename must not exceed 50 characters")
    private String filename;
}
