package com.upn2xt.Aero.HR.Mapper;

import com.upn2xt.Aero.HR.Dtos.Employee;
import com.upn2xt.Aero.HR.Dtos.Leave;

import java.sql.ResultSet;
import java.sql.SQLException;

public class HRMapper {

    public static Leave mapLeave(ResultSet rs, int rowNum) throws SQLException {
        Leave leave = new Leave();

        // Mapping columns from the 'Leaves' view (ls.*)
        leave.setRequestId(rs.getInt("request_ID"));
        leave.setEmpId(rs.getInt("emp_ID"));
        leave.setType(rs.getString("type"));

        // Mapping columns from the 'Leave' table
        if (rs.getDate("date_of_request") != null) {
            leave.setDateOfRequest(rs.getDate("date_of_request").toLocalDate());
        }

        // Mapping the aliased column 'status' (from final_approval_status)
        leave.setStatus(rs.getString("status"));

        return leave;
    }

    public static Employee mapManagedEmployee(ResultSet rs, int rowNum) throws SQLException {
        Employee employee = new Employee();

        employee.setEmployeeId(rs.getInt("employee_ID"));
        employee.setName(rs.getString("name"));

        return employee;
    }

}
