package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;

@Data
public class allRejectedMedicals {
    private Integer request_ID;
    private Integer Emp_ID;
    private LocalDate date_of_request;
    private LocalDate start_date;
    private LocalDate end_date;
    private String type;
    private Boolean insurance_status;
    private String disability_details;
    private String final_approval_status;
}
