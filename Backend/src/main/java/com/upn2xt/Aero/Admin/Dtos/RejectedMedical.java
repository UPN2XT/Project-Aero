package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalDate;

@Data
public class RejectedMedical {
    private Integer requestId;
    private Integer empId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String type;
    private Boolean insuranceStatus;
    private String disabilityDetails;
    private String finalStatus;
}
