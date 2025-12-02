package com.upn2xt.Aero.Employee.Repos;

import com.upn2xt.Aero.Employee.Dtos.Attendance;

import java.util.List;

public interface EmployeeRepo {

    List<Attendance> myAttendance (Integer empId);

}
