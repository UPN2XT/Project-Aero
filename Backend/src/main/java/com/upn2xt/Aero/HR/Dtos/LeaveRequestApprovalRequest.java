package com.upn2xt.Aero.HR.Dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class LeaveRequestApprovalRequest {

    @NotNull(message = "Request ID is required")
    @Positive(message = "Request ID must be a positive integer")
    private Integer request_id;

}
