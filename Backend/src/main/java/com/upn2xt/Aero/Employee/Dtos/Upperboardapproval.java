package com.upn2xt.Aero.Employee.Dtos;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Upperboardapproval {
    private Integer requestId;
    private Integer UpperboardId;
    private Integer replacmentId;
}
