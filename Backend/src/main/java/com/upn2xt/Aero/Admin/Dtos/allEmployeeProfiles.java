package com.upn2xt.Aero.Admin.Dtos;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "Employee profile information")
public class allEmployeeProfiles {

    @Schema(description = "Unique employee identifier", example = "1")
    private Integer employee_ID;

    @Schema(description = "Employee's first name", example = "John")
    private String first_name;

    @Schema(description = "Employee's last name", example = "Doe")
    private String last_name;

    @Schema(description = "Employee's gender", example = "Male")
    private String gender;

    @Schema(description = "Employee's email address", example = "john.doe@university.edu")
    private String email;

    @Schema(description = "Employee's address", example = "123 Main Street")
    private String address;

    @Schema(description = "Years of work experience", example = "5")
    private Integer years_of_experience;

    @Schema(description = "Official weekly day off", example = "Friday")
    private String official_day_off;

    @Schema(description = "Type of employment contract", example = "Full-time")
    private String type_of_contract;

    @Schema(description = "Current employment status", example = "Active")
    private String employment_status;

    @Schema(description = "Remaining annual leave balance in days", example = "21")
    private Integer annual_balance;

    @Schema(description = "Remaining accidental leave balance in days", example = "5")
    private Integer accidental_balance;
}
