package com.upn2xt.Aero.Employee.Repos.Imp;

import com.upn2xt.Aero.Employee.Dtos.*;
import com.upn2xt.Aero.Employee.Mapper.EmployeeMapper;
import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
import com.upn2xt.Aero.HR.Dtos.Employee;
import com.upn2xt.Aero.HR.Mapper.HRMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@Repository
public class EmployeeRepoImp implements EmployeeRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public List<Attendance> myAttendance(Integer empId) {
        String sql = "SELECT * FROM dbo.MyAttendance(?)";

        return jdbcTemplate.query(
                sql,
                EmployeeMapper::mapAttendance,
                empId
        );
    }

    @Override
    public List<Performance> myPerformance(Integer empId,String sem) {
        String sql = "SELECT * FROM dbo.MyPerformance(?,?)";
        return jdbcTemplate.query(sql,EmployeeMapper::mapPerformance,empId,sem);
    }

    public List<PayRoll> last_month_payroll(Integer empId) {
        String sql = "SELECT * FROM dbo.Last_month_payroll(?)";

        return jdbcTemplate.query(
                sql,
                EmployeeMapper::mapPayRoll,
                empId
        );
    }

    public List<Deduction> Deductions_Attendance(Integer empID,Integer month) {
        String sql = "SELECT * FROM dbo.Deductions(?,?)";
        return jdbcTemplate.query(sql,EmployeeMapper::mapDeduction,empID,month);
    }

    public void Submit_annual(SubmitAnnual annual, Integer empId) {
        //got this from gpt so not sure if this style is correct
        String sql = "EXEC dbo.Submit_annual ?, ?, ?, ?";

        jdbcTemplate.update(
                sql,
                empId,
                annual.getReplacementID(),
                Date.valueOf(annual.getStart()),
                Date.valueOf(annual.getEnd())
        );
    }

public void Upperboard_approve_annual(Upperboardapproval uba, Integer id) {
        String sql = "EXEC dbo.Upperboard_approve(?,?,?)";
        jdbcTemplate.update(
                sql,uba.getRequestId(),id,uba.getReplacmentId()
        );
}

public void Submit_accidental(SubmitAccidental accidental, Integer empId){
        String sql = "EXEC dbo.Submit_accidental(?,?,?)";
        jdbcTemplate.update(sql,empId,accidental.getStart(),accidental.getEnd());
}

    public void Submit_medical(SubmitMedical medical, Integer empId){
        String sql = "EXEC dbo.Submit_medical(?,?,?,?,?,?,?,?)";
        jdbcTemplate.update(
             sql,
                empId,
                medical.getStart(),
                medical.getEnd(),
                medical.getType(),
                medical.getInsurancestatus(),
                medical.getDisability(),
                medical.getDocument(),
                medical.getFileName()
        );
    }

public void Submit_unpaid(Submitunpaid unpaid, Integer empId){
        String sql = "EXEC dbo.Submit_unpaid(?,?,?,?,?)";
    jdbcTemplate.update(
            sql,
            empId,
            unpaid.getStart(),
            unpaid.getEnd(),
            unpaid.getDocument(),
            unpaid.getFilename()
    );
}
public void Upperboard_approve_unpaids(Upperboardapproval uba, Integer id){//might have to change the input to a new class
        String sql = "EXEC dbo.Upperboard_approve(?,?)";
    jdbcTemplate.update(sql,uba.getRequestId(),id);
}
public void Submit_compensation(Submitcomp compensation, Integer empId){
        String sql = "EXEC dbo.Submit_compensation(?,?,?,?,?)";
        jdbcTemplate.update(sql,
                empId,
                compensation.getCompdate(),
                compensation.getReason(),
                compensation.getOrgianlday(),
                compensation.getReplacementId());
}
public void Dean_andHR_Evaluation(Eval eval){
        String sql = "EXEC dbo.Dean_andHR_Evaluate(?,?,?,?)";
        jdbcTemplate.update(
                sql,
                eval.getEmpId(),
                eval.getRating(),
                eval.getComment(),
                eval.getSem()
        );
}

    @Override
    public List<LeaveStatus> Status_leaves(Integer id) {//TODO not sure if the table is just leave table or not
        String sql = "SELECT * FROM status_leaves(?)";

        return jdbcTemplate.query(
                sql,
                EmployeeMapper::mapLeaveStatus,
                id
        );
    }

    @Override
    public List<Employee> getEmployeesManged(Integer empId) {
        String sql = "SELECT e1.employee_id, e1.first_name + ' ' + e1.last_name AS name " +
                "FROM Employees e1 " +
                "JOIN Employees e2 ON e1.dept_name = e2.dept_name " +
                "WHERE e2.employee_id = ? AND e1.employee_id <> e2.employee_id";
        return jdbcTemplate.query(
                sql,
                HRMapper::mapManagedEmployee,
                empId);
    }


}
