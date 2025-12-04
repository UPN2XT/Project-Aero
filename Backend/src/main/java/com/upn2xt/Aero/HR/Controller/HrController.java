package com.upn2xt.Aero.HR.Controller;

import com.upn2xt.Aero.Auth.Dtos.ErrorResponse;
import com.upn2xt.Aero.HR.Dtos.*;
import com.upn2xt.Aero.HR.Repos.HrRepo;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import io.swagger.annotations.ApiResponse;
import io.swagger.annotations.ApiResponses;
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
@Api(tags = "HR Operations", description = "Human Resources Management endpoints (Spring Security Role: HR)")
public class HrController {

    @Autowired
    private HrRepo hrRepo;

    @ApiOperation(value = "Get Managed Employees", notes = "Retrieves a list of employees managed by the authenticated HR employee. "
            +
            "Uses get_employee_managed_by_hr SQL function.", response = Employee.class, responseContainer = "List")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully retrieved list of managed employees"),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/get-managed-employees")
    public List<Employee> getEmployeesManaged(Principal principal) {
        return hrRepo.getEmployeesManaged(Integer.parseInt(principal.getName()));
    }

    @ApiOperation(value = "Approve/Reject Accidental Leave", notes = "Processes an accidental leave request. Uses HR_approval_an_acc stored procedure. "
            +
            "Conditions: Accidental leave must be 1 day only, submitted within 2 days after start date, " +
            "and employee must have sufficient accidental_balance. Approves if conditions met, otherwise rejects.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Accidental leave request processed successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/approvals/accidental")
    public void approval_accidental(
            @ApiParam(value = "Leave request ID to process", required = true) @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_an_acc(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @ApiOperation(value = "Approve/Reject Annual Leave", notes = "Processes an annual leave request. Uses HR_approval_an_acc stored procedure. "
            +
            "Approves if employee has sufficient annual_balance (>= num_days requested). " +
            "If approved, deducts from annual_balance and creates replacement record in Employee_Replace_Employee table.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Annual leave request processed successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/approvals/annual")
    public void approval_annual(
            @ApiParam(value = "Leave request ID to process", required = true) @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_an_acc(request.getRequest_id(), Integer.parseInt(principal.getName()));

    }

    @ApiOperation(value = "Approve/Reject Unpaid Leave", notes = "Processes an unpaid leave request. Uses HR_approval_unpaid stored procedure. "
            +
            "Conditions: Employee's annual_balance must be 0, duration <= 30 days, " +
            "no other approved unpaid leave in the same year, and no rejection in approval hierarchy.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Unpaid leave request processed successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/approvals/unpaid")
    public void approval_unpaid(
            @ApiParam(value = "Leave request ID to process", required = true) @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_unpaid(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @ApiOperation(value = "Approve/Reject Compensation Leave", notes = "Processes a compensation leave request. Uses HR_approval_comp stored procedure. "
            +
            "Condition: Employee must have worked >8 hours on a day off to qualify for compensation leave.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Compensation leave request processed successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/approvals/compensation")
    public void approval_compensation(
            @ApiParam(value = "Leave request ID to process", required = true) @Valid @RequestBody LeaveRequestApprovalRequest request,
            Principal principal) {
        hrRepo.HR_approval_comp(request.getRequest_id(), Integer.parseInt(principal.getName()));
    }

    @ApiOperation(value = "Get All Pending Approvals", notes = "Retrieves all leave requests pending approval by the authenticated HR employee. "
            +
            "Uses get_approvals SQL function. Returns leave details including request_ID, emp_ID, type, " +
            "date_of_request, and status.", response = Leave.class, responseContainer = "List")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully retrieved list of pending approvals"),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/approvals/get-all")
    public List<Leave> get_approvals(Principal principal) {
        return hrRepo.getApprovalOFLeaves(Integer.parseInt(principal.getName()));
    }

    @ApiOperation(value = "Add Deduction for Missing Hours", notes = "Adds a deduction for an employee who has missing work hours. "
            +
            "Uses Deduction_hours stored procedure. Adds deduction of type 'missing_hours' " +
            "referenced to the first attendance record where total_duration < 8 hours (480 minutes).", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Deduction for missing hours added successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/deductions/hours")
    public void deduction_hours(
            @ApiParam(value = "Employee ID for deduction", required = true) @Valid @RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_hours(request.getEmployee_id());
    }

    @ApiOperation(value = "Add Deduction for Missing Days", notes = "Adds a deduction for an employee who has missing work days. "
            +
            "Uses Deduction_days stored procedure. Adds deduction of type 'missing_days'.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Deduction for missing days added successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/deductions/days")
    public void deduction_days(
            @ApiParam(value = "Employee ID for deduction", required = true) @Valid @RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_days(request.getEmployee_id());
    }

    @ApiOperation(value = "Add Deduction for Unpaid Leave", notes = "Adds a deduction for an employee's unpaid leave. "
            +
            "Uses Deduction_unpaid stored procedure. Adds deduction of type 'unpaid'. " +
            "If leave spans multiple months, the deduction is split by month.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Deduction for unpaid leave added successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/deductions/unpaid")
    public void deduction_unpaid(
            @ApiParam(value = "Employee ID for deduction", required = true) @Valid @RequestBody EmployeePayrollRequest request) {
        hrRepo.Deduction_unpaid(request.getEmployee_id());
    }

    @ApiOperation(value = "Generate Monthly Payroll", notes = "Generates monthly payroll for an employee. Uses Add_Payroll stored procedure. "
            +
            "Calculates final salary using: base_salary + (years_of_experience * 0.01 * base_salary). " +
            "Includes bonus calculation using Bonus_amount function based on overtime guidelines: " +
            "(employee_salary / 22 / 8) * (overtime_factor * extra_hours / 100). " +
            "Deductions amount is also calculated and included.", response = Void.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Payroll generated successfully"),
            @ApiResponse(code = 400, message = "Validation error - Invalid input data", response = ErrorResponse.class),
            @ApiResponse(code = 401, message = "Unauthorized - JWT token missing or invalid"),
            @ApiResponse(code = 500, message = "Database error - SQL exception occurred", response = ErrorResponse.class)
    })
    @PostMapping("/payrolls/add")
    public void add_payroll(
            @ApiParam(value = "Payroll generation request with employee ID and date range", required = true) @Valid @RequestBody AddPayrollRequest request) {
        hrRepo.Add_Payroll(request.getEmployee_id(), request.getFromDate(), request.getToDate());
    }

}
