package com.upn2xt.Aero.Employee.Repos.Imp;

import com.upn2xt.Aero.Employee.Dtos.*;
import com.upn2xt.Aero.Employee.Mapper.EmployeeMapper;
import com.upn2xt.Aero.Employee.Repos.EmployeeRepo;
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

    public void Submit_annual(SubmitAnnual annual) {
        //got this from gpt so not sure if this style is correct
        String sql = "EXEC dbo.Submit_annual ?, ?, ?, ?";

        jdbcTemplate.update(
                sql,
                annual.getEmpID(),
                annual.getReplacementID(),
                Date.valueOf(annual.getStart()),
                Date.valueOf(annual.getEnd())
        );
    }

public void Upperboard_approve_annual(Upperboardapproval uba) {
        String sql = "EXEC dbo.Upperboard_approve(?,?,?)";
        jdbcTemplate.update(
                sql,uba.getRequestId(),uba.getUpperboardId(),uba.getReplacmentId()
        );
}

public void Submit_accidental(SubmitAccidental accidental){
        String sql = "EXEC dbo.Submit_accidental(?,?,?)";
        jdbcTemplate.update(sql,accidental.getEmpId(),accidental.getStart(),accidental.getEnd());
}

    public void Submit_medical(SubmitMedical medical){
        String sql = "EXEC dbo.Submit_medical(?,?,?,?,?,?,?,?)";
        jdbcTemplate.update(
             sql,
                medical.getEmpId(),
                medical.getStart(),
                medical.getEnd(),
                medical.getType(),
                medical.getInsurancestatus(),
                medical.getDisability(),
                medical.getDocument(),
                medical.getFileName()
        );
    }

public void Submit_unpaid(Submitunpaid unpaid){
        String sql = "EXEC dbo.Submit_unpaid(?,?,?,?,?)";
    jdbcTemplate.update(
            sql,
            unpaid.getEmpId(),
            unpaid.getStart(),
            unpaid.getEnd(),
            unpaid.getDocument(),
            unpaid.getFilename()
    );
}
public void Upperboard_approve_unpaids(Upperboardapproval uba){//might have to change the input to a new class
        String sql = "EXEC dbo.Upperboard_approve(?,?)";
    jdbcTemplate.update(sql,uba.getRequestId(),uba.getUpperboardId());
}
public void Submit_compensation(Submitcomp compensation){
        String sql = "EXEC dbo.Submit_compensation(?,?,?,?,?)";
        jdbcTemplate.update(sql,
                compensation.getEmpId(),
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
    public List<Object> Status_leaves() {//TODO not sure if the table is just leave table or not
        return List.of();
    }
}
