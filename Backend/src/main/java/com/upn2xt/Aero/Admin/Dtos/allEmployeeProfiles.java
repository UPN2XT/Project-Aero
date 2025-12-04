package com.upn2xt.Aero.Admin.Dtos;

import lombok.Data;

@Data
public class allEmployeeProfiles {
    private Integer employee_ID;
    private String first_name;
    private String last_name;
    private Character gender;
    private String email;
    private String address;
    private Integer years_of_experience;
    private String official_day_off;
    private String type_of_contract;
    private String employment_status;
    private Integer annual_balance;
    private Integer accidental_balance;
}
