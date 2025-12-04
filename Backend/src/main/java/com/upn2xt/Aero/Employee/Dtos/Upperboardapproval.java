package com.upn2xt.Aero.Employee.Dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Upperboardapproval {

    @NotNull(message = "Request ID is required")
    @Positive(message = "Request ID must be a positive integer")
    private Integer requestId;

    @Positive(message = "Replacement ID must be a positive integer")
    private Integer replacmentId;
}
