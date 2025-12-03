package com.upn2xt.Aero.HR.Repos.Imp;

import com.upn2xt.Aero.HR.Dtos.Employee;
import com.upn2xt.Aero.HR.Dtos.Leave;
import com.upn2xt.Aero.HR.Mapper.HRMapper;
import com.upn2xt.Aero.HR.Repos.HrRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.util.List;

@Repository
public class HrRepoImp implements HrRepo {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void HR_approval_an_acc(Integer request_id, Integer hr_id) {
        String sql = "EXEC HR_Approval_An_Acc ?, ?";
        jdbcTemplate.update(sql, request_id, hr_id);
    }

    @Override
    public void HR_approval_unpaid(Integer request_id, Integer hr_id) {
        String sql = "EXEC HR_Approval_Unpaid ?, ?";
        jdbcTemplate.update(sql, request_id, hr_id);
    }

    @Override
    public void HR_approval_comp(Integer request_id, Integer hr_id) {
        String sql = "EXEC HR_Approval_Comp ?, ?";
        jdbcTemplate.update(sql, request_id, hr_id);
    }

    @Override
    public void Deduction_hours(Integer employee_id) {
        String sql = "EXEC Deduction_hours ?";
        jdbcTemplate.update(sql, employee_id);
    }

    @Override
    public void Deduction_days(Integer employee_id) {
        String sql = "EXEC Deduction_days ?";
        jdbcTemplate.update(sql, employee_id);
    }

    @Override
    public void Deduction_unpaid(Integer employee_id) {
        String sql = "EXEC Deduction_unpaid ?";
        jdbcTemplate.update(sql, employee_id);
    }

    @Override
    public void Add_Payroll(Integer employee_id, Date from_date, Date to_date) {
        String sql = "EXEC Add_Payroll ?, ?";
        jdbcTemplate.update(sql, employee_id, from_date, to_date);
    }

    @Override
    public List<Leave> getApprovalOFLeaves(Integer hr_id) {
        String sql = "SELECT * FROM get_approvals(?)";
        return jdbcTemplate.query(
                sql,
                HRMapper::mapLeave,
                hr_id
        );
    }

    @Override
    public List<Employee> getEmployeesManaged(Integer hr_id) {
        String sql = "SELECT * FROM get_employee_managed_by_hr(?)";

        return jdbcTemplate.query(
                sql,
                HRMapper::mapManagedEmployee,
                hr_id
        );
    }
}
