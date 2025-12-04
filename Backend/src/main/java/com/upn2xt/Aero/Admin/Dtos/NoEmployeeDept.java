package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "Department employee count information")
public class NoEmployeeDept {

    @Schema(description = "Name of the department", example = "Computer Science")
    private String dept_name;

    @Schema(description = "Number of employees in the department", example = "25")
    private Integer num_employees;
}
