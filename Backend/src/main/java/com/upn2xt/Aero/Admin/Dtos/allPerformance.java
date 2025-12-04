package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "Employee performance evaluation record")
public class allPerformance {

    @Schema(description = "Unique performance record identifier", example = "1")
    private Integer performance_ID;

    @Schema(description = "Performance rating (1-5 scale)", example = "4")
    private Integer rating;

    @Schema(description = "Performance review comments", example = "Excellent work on the project")
    private String comments;

    @Schema(description = "Semester of the evaluation", example = "Winter")
    private String semester;

    @Schema(description = "Employee ID", example = "1")
    private Integer emp_ID;
}
