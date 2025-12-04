package com.upn2xt.Aero.Employee.Controller;

import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;
import com.upn2xt.Aero.Employee.Dtos.*;
import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
import com.upn2xt.Aero.HR.Dtos.Employee;

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
@RequestMapping("/api/employee")
@Tag(name = "Employee Self-Service", description = "Employee Portal endpoints (Spring Security Role: USER)")
public class EmployeeController {

    @Autowired
    private EmployeeRepo employeeRepo;

    @Operation(summary = "Get My Attendance", description = "Retrieves the authenticated employee's attendance records for the current month. "
            + "Uses MyAttendance table-valued function. Excludes unattended official days off. " +
            "Returns attendance_ID, date, check_in_time, check_out_time, total_duration (in minutes), status, and emp_ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved attendance records",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = Attendance.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/my-attendance")
    public List<Attendance> myAttendance(Principal p) {
        return employeeRepo.myAttendance(Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Get Leave Request Status", description = "Retrieves the status of all leave requests submitted by the authenticated employee. "
            + "Uses Status_leaves table-valued function. Returns request_ID, date_of_request, and status (Approved/Pending/Rejected).")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved leave statuses",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = LeaveStatus.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/status-leaves")
    public List<LeaveStatus> status_leaves(Principal p) {
        return employeeRepo.Status_leaves(Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Get My Performance", description = "Retrieves the authenticated employee's performance records for a specific semester. "
            + "Uses MyPerformance table-valued function. Semester format: 'W25' (Winter 2025), 'S25' (Summer 2025). " +
            "Returns performance_ID, rating (1-5), comments, semester, and emp_ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved performance records",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = Performance.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/my-performance")
    public List<Performance> myPerformance(
            Principal p,
            @Parameter(description = "Semester code (e.g., 'W25' for Winter 2025)", required = true) String sem) {
        return employeeRepo.myPerformance(Integer.parseInt(p.getName()), sem);
    }

    @Operation(summary = "Get Last Month Payroll", description = "Retrieves the authenticated employee's payroll details for the previous month. "
            + "Uses Last_month_payroll table-valued function. Returns ID, payment_date, final_salary_amount, " +
            "from_date, to_date, comments, bonus_amount, deductions_amount, and emp_ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved payroll records",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = PayRoll.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/last-month-payroll")
    public List<PayRoll> last_month_payroll(Principal p) {
        return employeeRepo.last_month_payroll(Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Get Deductions by Attendance", description = "Retrieves deductions caused by attendance issues for the authenticated employee in a specific month. "
            + "Uses Deductions_Attendance table-valued function. Returns deduction_ID, emp_ID, date, amount, " +
            "type (unpaid/missing_hours/missing_days), status (pending/finalized), unpaid_ID, and attendance_ID.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved deductions",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = Deduction.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/deduction-attendance")
    public List<Deduction> Deductions_Attendance(
            Principal p,
            @Parameter(description = "Month number (1-12)", required = true) Integer month) {
        return employeeRepo.Deductions_Attendance(Integer.parseInt(p.getName()), month);
    }

    @Operation(summary = "Submit Annual Leave Request", description = "Submits an annual leave request for the authenticated employee. "
            + "Uses Submit_annual stored procedure. Requires a replacement employee ID. " +
            "Initial status is 'Pending'. HR will approve/reject based on annual_balance availability.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Annual leave request submitted successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/submit/annual")
    public void submit_annual(
            Principal p,
            @Parameter(description = "Annual leave submission with replacement ID, start date, and end date", required = true)
            @Valid @RequestBody SubmitAnnual submitAnnual) {
        employeeRepo.Submit_annual(submitAnnual, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Submit Compensation Leave Request", description = "Submits a compensation leave request for the authenticated employee. "
            + "Uses Submit_compensation stored procedure. Requires the original workday date when employee " +
            "worked >8 hours on a day off, reason for compensation, and optional replacement employee.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Compensation leave request submitted successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/submit/compensation")
    public void submit_compensation(
            Principal p,
            @Parameter(description = "Compensation leave submission with comp date, reason, original workday, and replacement ID", required = true)
            @Valid @RequestBody Submitcomp submitCompensation) {
        employeeRepo.Submit_compensation(submitCompensation, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Submit Accidental Leave Request", description = "Submits an accidental leave request for the authenticated employee. "
            + "Uses Submit_accidental stored procedure. Accidental leave must be submitted within 2 days " +
            "after the start date and can only be for 1 day. Deducts from accidental_balance if approved.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Accidental leave request submitted successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/submit/accidental")
    public void submit_accidental(
            Principal p,
            @Parameter(description = "Accidental leave submission with start and end date", required = true)
            @Valid @RequestBody SubmitAccidental submitAccidental) {
        employeeRepo.Submit_accidental(submitAccidental, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Submit Unpaid Leave Request", description = "Submits an unpaid leave request for the authenticated employee. "
            + "Uses Submit_unpaid stored procedure. Conditions: annual_balance must be 0, " +
            "duration <= 30 days, and no other approved unpaid leave in the same year. " +
            "Requires supporting document.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Unpaid leave request submitted successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/submit/unpaid")
    public void submit_unpaid(
            Principal p,
            @Parameter(description = "Unpaid leave submission with start date, end date, document, and filename", required = true)
            @Valid @RequestBody Submitunpaid submitUnpaid) {
        employeeRepo.Submit_unpaid(submitUnpaid, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Submit Medical Leave Request", description = "Submits a medical leave request for the authenticated employee. "
            + "Uses Submit_medical stored procedure. Type can be 'sick' or 'maternity'. " +
            "Requires insurance status, disability details (if applicable), and supporting document.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Medical leave request submitted successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("submit/medical")
    public void submit_medical(
            Principal p,
            @Parameter(description = "Medical leave submission with start/end date, type (sick/maternity), insurance status, disability details, and document", required = true)
            @Valid @RequestBody SubmitMedical submitMedical) {
        employeeRepo.Submit_medical(submitMedical, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Upper Board Approve Annual Leave", description = "Allows upper board members (Dean/Department Head) to approve annual leave requests. "
            + "Uses Dean_approve_annual stored procedure. Part of the multi-level approval hierarchy.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Annual leave approved by upper board successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/upperboard/approve/annual")
    public void upperboard_approve_annual(
            Principal p,
            @Parameter(description = "Approval request with request ID and replacement ID", required = true)
            @Valid @RequestBody Upperboardapproval uba) {
        employeeRepo.Upperboard_approve_annual(uba, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Upper Board Approve Unpaid Leave", description = "Allows upper board members to approve unpaid leave requests. "
            + "Uses Upperboard_approve_unpaids stored procedure. Part of the multi-level approval hierarchy.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Unpaid leave approved by upper board successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/upperboard/approve/unpaid")
    public void upperboard_approve_unpaid(
            Principal p,
            @Parameter(description = "Approval request with request ID and replacement ID", required = true)
            @Valid @RequestBody Upperboardapproval uba) {
        employeeRepo.Upperboard_approve_unpaids(uba, Integer.parseInt(p.getName()));
    }

    @Operation(summary = "Submit Performance Evaluation", description = "Submits a performance evaluation for an employee. "
            + "Uses DeanandHR_Evaluation stored procedure. Can be submitted by Dean or HR. " +
            "Rating must be between 1-5. Semester format: 'W25' (Winter), 'S25' (Summer).")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Performance evaluation submitted successfully"),
            @ApiResponse(responseCode = "400", description = "Validation error - Invalid input data",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/dean-hr-evaluation")
    public void dean_andHR_evaluation(
            @Parameter(description = "Evaluation with employee ID, rating (1-5), comment, and semester", required = true)
            @Valid @RequestBody Eval eval) {
        employeeRepo.Dean_andHR_Evaluation(eval);
    }

    @Operation(summary = "Get Managed Employees", description = "Retrieves a list of employees managed by the authenticated employee (for managers/supervisors). "
            + "Uses get_employee_managed_by_hr SQL function.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved list of managed employees",
                    content = @Content(array = @ArraySchema(schema = @Schema(implementation = Employee.class)))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(responseCode = "500", description = "Database error - SQL exception occurred",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/get-managed-employees")
    public List<Employee> getEmployeesManged(Principal p) {
        return employeeRepo.getEmployeesManged(Integer.parseInt(p.getName()));
    }
}