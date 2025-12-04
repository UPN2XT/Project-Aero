package com.upn2xt.Aero.Admin.Repos;

import com.upn2xt.Aero.Admin.Dtos.*;

import java.util.List;

public interface AdminRepo {

    List<allEmployeeProfiles> allEmployeeProfiles();

    List<NoEmployeeDept> NoEmployeeDept();

    List<allRejectedMedicals> allRejectedMedicals();

    List<allEmployeeAttendance> allEmployeeAttendance();

    List<allPerformance> allPerformance();

    void Remove_Deductions();

    void Add_Holiday(String holiday_name,
                     java.time.LocalDate from_date,
                     java.time.LocalDate to_date);

    void Intitiate_Attendance();

    void Update_Attendance(Integer Employee_id,
                           java.time.LocalTime check_in_time,
                           java.time.LocalTime check_out_time);

    void Remove_Holiday();

    void Remove_DayOff(Integer Employee_id);

    void Remove_Approved_Leaves(Integer Employee_id);

    void Replace_employee(Integer Emp1_ID,
                          Integer Emp2_ID,
                          java.time.LocalDate from_date,
                          java.time.LocalDate to_date);
}
