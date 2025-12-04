package com.upn2xt.Aero.Admin.Controller;

import com.upn2xt.Aero.Admin.Dtos.*;
import com.upn2xt.Aero.Admin.Repos.AdminRepo;
import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@Tag(name = "Admin Operations", description = "Administrative Management endpoints (Spring Security Role: ADMIN)")
public class AdminController {
    @Autowired
    private AdminRepo adminRepo;

    @Operation(summary = "Get All Employee Profiles", description = "Retrieves a comprehensive list of all employee profiles in the system. "
            + "Returns employee details including personal information, employment status, and leave balances.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved all employee profiles", content = @Content(array = @ArraySchema(schema = @Schema(implementation = allEmployeeProfiles.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/all-employee-profiles")
    public List<allEmployeeProfiles> allEmployeeProfiles() {
        return adminRepo.allEmployeeProfiles();
    }

    @Operation(summary = "Get Employees Per Department", description = "Retrieves the count of employees in each department. "
            + "Useful for organizational analytics and workforce distribution analysis.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved employee count per department", content = @Content(array = @ArraySchema(schema = @Schema(implementation = NoEmployeeDept.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/employees-per-department")
    public List<NoEmployeeDept> NoEmployeeDept() {
        return adminRepo.NoEmployeeDept();
    }

    @Operation(summary = "Get All Rejected Medical Leaves", description = "Retrieves a list of all rejected medical leave requests. "
            + "Includes request details, employee information, and rejection status.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved all rejected medical leaves", content = @Content(array = @ArraySchema(schema = @Schema(implementation = allRejectedMedicals.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/rejected-medicals")
    public List<allRejectedMedicals> allRejectedMedicals() {
        return adminRepo.allRejectedMedicals();
    }

    @Operation(summary = "Get Yesterday's Attendance", description = "Retrieves attendance records for all employees from the previous day. "
            + "Includes check-in/check-out times, total duration, and attendance status.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved yesterday's attendance records", content = @Content(array = @ArraySchema(schema = @Schema(implementation = allEmployeeAttendance.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/yesterday-attendance")
    public List<allEmployeeAttendance> allEmployeeAttendance() {
        return adminRepo.allEmployeeAttendance();
    }

    @Operation(summary = "Get Winter Performance Records", description = "Retrieves performance evaluation records for the winter semester. "
            + "Includes performance ratings, comments, and employee information.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved winter performance records", content = @Content(array = @ArraySchema(schema = @Schema(implementation = allPerformance.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/winter-performance")
    public List<allPerformance> allPerformance() {
        return adminRepo.allPerformance();
    }

    @Operation(summary = "Remove All Deductions", description = "Removes all deduction records from the system. "
            + "This is an administrative cleanup operation that clears all employee deductions.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully removed all deductions"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/remove-deductions")
    public void Remove_Deductions() {
        adminRepo.Remove_Deductions();
    }

    @Operation(summary = "Add Holiday", description = "Adds a new holiday to the system calendar. "
            + "Holidays affect attendance tracking and leave calculations for all employees.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Holiday added successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/add-holiday")
    public void Add_Holiday(
            @Parameter(description = "Holiday details to add", required = true) @Valid @RequestBody Add_Holiday holiday) {
        adminRepo.Add_Holiday(
                holiday.getHoliday_name(),
                holiday.getFrom_Date(),
                holiday.getTo_Date());
    }

    @Operation(summary = "Initiate Daily Attendance", description = "Initializes attendance records for the current day. "
            + "Creates attendance entries for all active employees with default status.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Attendance initiated successfully for all employees"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/initiate-attendance")
    public void Intitiate_Attendance() {
        adminRepo.Intitiate_Attendance();
    }

    @Operation(summary = "Update Employee Attendance", description = "Updates the check-in and check-out times for a specific employee's attendance record. "
            + "Used for manual attendance corrections by administrators.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Attendance updated successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/update-attendance")
    public void Update_Attendance(
            @Parameter(description = "Attendance update details", required = true) @Valid @RequestBody UpdateAttendance update) {
        adminRepo.Update_Attendance(
                update.getEmployee_id(),
                update.getCheck_in_time(),
                update.getCheck_out_time());
    }

    @Operation(summary = "Remove Expired Holidays", description = "Removes holidays that have passed from the system calendar. "
            + "Cleans up old holiday records to maintain database hygiene.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Expired holidays removed successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/remove-holiday")
    public void Remove_Holiday() {
        adminRepo.Remove_Holiday();
    }

    @Operation(summary = "Remove Employee Day Off", description = "Removes the official day off designation for a specific employee. "
            + "This operation clears the employee's assigned weekly day off.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Day off removed successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/remove-dayoff")
    public void Remove_DayOff(
            @Parameter(description = "Employee ID to remove day off from", required = true) @Valid @RequestBody RemoveDayOff request) {
        adminRepo.Remove_DayOff(request.getEmployee_id());
    }

    @Operation(summary = "Remove Approved Leaves", description = "Removes all approved leave records for a specific employee. "
            + "Used for administrative corrections or when leave records need to be reset.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Approved leaves removed successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/remove-approved-leaves")
    public void Remove_Approved_Leaves(
            @Parameter(description = "Employee ID to remove approved leaves from", required = true) @Valid @RequestBody RemoveApprovedLeaves request) {
        adminRepo.Remove_Approved_Leaves(request.getEmployee_id());
    }

    @Operation(summary = "Replace Employee", description = "Creates a temporary replacement assignment where one employee covers for another. "
            + "Records the replacement period in the Employee_Replace_Employee table for tracking purposes.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Employee replacement created successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "403", description = "Forbidden - User does not have ADMIN role"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/replace-employee")
    public void Replace_employee(
            @Parameter(description = "Employee replacement details", required = true) @Valid @RequestBody Replace_employee rep) {
        adminRepo.Replace_employee(
                rep.getEmp1_ID(),
                rep.getEmp2_ID(),
                rep.getFrom_date(),
                rep.getTo_date());
    }
}
