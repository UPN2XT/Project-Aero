package com.upn2xt.Aero.HR.Controller;

import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;
import com.upn2xt.Aero.HR.Dtos.*;
import com.upn2xt.Aero.HR.Repos.HrRepo;

// New OpenAPI 3 Imports
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/hr")
@Tag(name = "HR Operations", description = "Human Resources Management endpoints (Spring Security Role: HR)")
public class HrController {

    @Autowired
    private HrRepo hrRepo;

    @Operation(summary = "Get Managed Employees", description = "Retrieves a list of employees managed by the authenticated HR employee. "
            + "Uses get_employee_managed_by_hr SQL function.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved list of managed employees",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = Employee.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/get-managed-employees")
    public List<Employee> getEmployeesManaged(Principal principal) {
        return hrRepo.getEmployeesManaged(Integer.parseInt(principal.getName()));
    }

    @Operation(summary = "Approve/Reject Accidental Leave", description = "Processes an accidental leave request. Uses HR_approval_an_acc stored procedure. "
            + "Conditions: Accidental leave must be 1 day only, submitted within 2 days after start date, " +
            "and employee must have sufficient accidental_balance. Approves if conditions met, otherwise rejects.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Accidental leave request processed successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/approvals/accidental")
    public void approval_accidental(
            @Parameter(description = "Leave request ID to process", required = true)
            @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_an_acc(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @Operation(summary = "Approve/Reject Annual Leave", description = "Processes an annual leave request. Uses HR_approval_an_acc stored procedure. "
            + "Approves if employee has sufficient annual_balance (>= num_days requested). " +
            "If approved, deducts from annual_balance and creates replacement record in Employee_Replace_Employee table.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Annual leave request processed successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/approvals/annual")
    public void approval_annual(
            @Parameter(description = "Leave request ID to process", required = true)
            @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_an_acc(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @Operation(summary = "Approve/Reject Unpaid Leave", description = "Processes an unpaid leave request. Uses HR_approval_unpaid stored procedure. "
            + "Conditions: Employee's annual_balance must be 0, duration <= 30 days, " +
            "no other approved unpaid leave in the same year, and no rejection in approval hierarchy.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Unpaid leave request processed successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/approvals/unpaid")
    public void approval_unpaid(
            @Parameter(description = "Leave request ID to process", required = true)
            @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_unpaid(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @Operation(summary = "Approve/Reject Compensation Leave", description = "Processes a compensation leave request. Uses HR_approval_comp stored procedure. "
            + "Condition: Employee must have worked >8 hours on a day off to qualify for compensation leave.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Compensation leave request processed successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/approvals/compensation")
    public void approval_compensation(
            @Parameter(description = "Leave request ID to process", required = true)
            @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_comp(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @Operation(summary = "Get All Pending Approvals", description = "Retrieves all leave requests pending approval by the authenticated HR employee. "
            + "Uses get_approvals SQL function. Returns leave details including request_ID, emp_ID, type, " +
            "date_of_request, and status.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved list of pending approvals",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = Leave.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/approvals/get-all")
    public List<Leave> get_approvals(Principal principal) {
        return hrRepo.getApprovalOFLeaves(Integer.parseInt(principal.getName()));
    }

    @Operation(summary = "Add Deduction for Missing Hours", description = "Adds a deduction for an employee who has missing work hours. "
            + "Uses Deduction_hours stored procedure. Adds deduction of type 'missing_hours' " +
            "referenced to the first attendance record where total_duration < 8 hours (480 minutes).")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Deduction for missing hours added successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/deductions/hours")
    public void deduction_hours(
            @Parameter(description = "Employee ID for deduction", required = true)
            @Valid @RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_hours(request.getEmployee_id());
    }

    @Operation(summary = "Add Deduction for Missing Days", description = "Adds a deduction for an employee who has missing work days. "
            + "Uses Deduction_days stored procedure. Adds deduction of type 'missing_days'.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Deduction for missing days added successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/deductions/days")
    public void deduction_days(
            @Parameter(description = "Employee ID for deduction", required = true)
            @Valid @RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_days(request.getEmployee_id());
    }

    @Operation(summary = "Add Deduction for Unpaid Leave", description = "Adds a deduction for an employee's unpaid leave. "
            + "Uses Deduction_unpaid stored procedure. Adds deduction of type 'unpaid'. " +
            "If leave spans multiple months, the deduction is split by month.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Deduction for unpaid leave added successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/deductions/unpaid")
    public void deduction_unpaid(
            @Parameter(description = "Employee ID for deduction", required = true)
            @Valid @RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_unpaid(request.getEmployee_id());
    }

    @Operation(summary = "Generate Monthly Payroll", description = "Generates monthly payroll for an employee. Uses Add_Payroll stored procedure. "
            + "Calculates final salary using: base_salary + (years_of_experience * 0.01 * base_salary). " +
            "Includes bonus calculation using Bonus_amount function based on overtime guidelines: " +
            "(employee_salary / 22 / 8) * (overtime_factor * extra_hours / 100). " +
            "Deductions amount is also calculated and included.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Payroll generated successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/payrolls/add")
    public void add_payroll(
            @Parameter(description = "Payroll generation request with employee ID and date range", required = true)
            @Valid @RequestBody AddPayrollRequest request) {
        hrRepo.Add_Payroll(request.getEmployee_id(), request.getFromDate(), request.getToDate());
    }
}