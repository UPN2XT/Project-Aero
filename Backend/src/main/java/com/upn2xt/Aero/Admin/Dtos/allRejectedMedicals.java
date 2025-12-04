package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.time.LocalDate;

@Data
@Schema(description = "Rejected medical leave request information")
public class allRejectedMedicals {

    @Schema(description = "Unique request identifier", example = "1")
    private Integer request_ID;

    @Schema(description = "Employee ID who made the request", example = "5")
    private Integer Emp_ID;

    @Schema(description = "Date when the request was submitted", example = "2025-11-15")
    private LocalDate date_of_request;

    @Schema(description = "Requested leave start date", example = "2025-11-20")
    private LocalDate start_date;

    @Schema(description = "Requested leave end date", example = "2025-11-25")
    private LocalDate end_date;

    @Schema(description = "Type of medical leave", example = "Medical")
    private String type;

    @Schema(description = "Whether the employee has insurance coverage", example = "true")
    private Boolean insurance_status;

    @Schema(description = "Details about any disability if applicable", example = "None")
    private String disability_details;

    @Schema(description = "Final approval status of the request", example = "Rejected")
    private String final_approval_status;
}
