package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;
import java.time.LocalTime;

@Data
public class Update_Attendance {
    private Integer Employee_id;
    private LocalTime check_in_time;
    private LocalTime check_out_time;
}
