package com.upn2xt.Aero.Employee.Mapper;

import com.upn2xt.Aero.Employee.Dtos.*;

import java.sql.ResultSet;
import java.sql.SQLException;

public class EmployeeMapper {

    public static Attendance mapAttendance(ResultSet rs, int rowNum) throws SQLException {

        Attendance attendance = new Attendance();
        attendance.setAttendanceId(rs.getInt("attendance_ID"));
        if (rs.getDate("date") != null) {
            attendance.setDate(rs.getDate("date").toLocalDate());
        }
        if (rs.getTime("check_in_time") != null) {
            attendance.setCheckInTime(rs.getTime("check_in_time").toLocalTime());
        }
        if (rs.getTime("check_out_time") != null) {
            attendance.setCheckOutTime(rs.getTime("check_out_time").toLocalTime());
        }
        attendance.setTotalDuration(rs.getInt("total_duration"));
        attendance.setStatus(rs.getString("status"));
        attendance.setEmpId(rs.getInt("emp_ID"));
        return attendance;

    }

    public static Performance mapPerformance(ResultSet rs, int rowNum) throws SQLException {
        Performance performance = new Performance();
        performance.setPerformanceID(rs.getInt("performanceID"));
        performance.setRating(rs.getInt("rating"));
        performance.setComments(rs.getString("comments"));
        performance.setEmpID(rs.getInt("empID"));
        performance.setSem(rs.getString("sem"));
        return performance;
    }

    public static PayRoll mapPayRoll(ResultSet rs, int rowNum) throws SQLException {
        PayRoll payroll = new PayRoll();
        payroll.setID(rs.getInt("payroll_ID"));
        payroll.setEmpID(rs.getInt("empID"));
        if (payroll.getPaymentDate() != null) {
            payroll.setPaymentDate(rs.getDate("paymentDate").toLocalDate());
        }
        if (payroll.getFrom() != null) {
            payroll.setPaymentDate(rs.getDate("from").toLocalDate());
        }
        if (payroll.getTo() != null) {
            payroll.setPaymentDate(rs.getDate("to").toLocalDate());
        }
        payroll.setFinalamount(rs.getInt("finalamount"));
        payroll.setComments(rs.getString("comments"));
        payroll.setDeduction(rs.getInt("deduction"));
        payroll.setBonus(rs.getInt("bonus"));
        return payroll;
    }

    public static Deduction mapDeduction(ResultSet rs, int rowNum) throws SQLException {
        Deduction deduction = new Deduction();
        deduction.setDeductionID(rs.getInt("deductionID"));
        deduction.setEmpID(rs.getInt("empID"));
        deduction.setDate(rs.getDate("date").toLocalDate());
        deduction.setAmount(rs.getInt("amount"));
        deduction.setType(rs.getString("type"));
        deduction.setStatus(rs.getString("status"));
        deduction.setUnpaidID(rs.getInt("unpaidID"));
        deduction.setAttendanceID(rs.getInt("attendance_ID"));
        return deduction;
    }

    public static LeaveStatus mapLeaveStatus(ResultSet rs, int rowNum) throws SQLException {
        LeaveStatus leaveStatus = new LeaveStatus();

        leaveStatus.setRequestId(rs.getInt("request_ID"));

        if (rs.getDate("date_of_request") != null) {
            leaveStatus.setDateOfRequest(rs.getDate("date_of_request").toLocalDate());
        }

        leaveStatus.setFinalApprovalStatus(rs.getString("final_approval_status"));

        return leaveStatus;
    }

    public static Me mapMe(ResultSet rs, int rowNum) throws SQLException {
        return Me.builder()
                .name(rs.getString("name"))
                .role(rs.getString("role"))
                .build();
    }
}