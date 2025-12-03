package com.upn2xt.Aero.Admin.Repos;

import com.upn2xt.Aero.Admin.Dtos.*;
import java.util.List;

public interface AdminRepo {

    List<EmployeeProfile> allProfiles();
    List<EmployeeDeptCount> deptCounts();
    List<RejectedMedical> rejectedMedicals();

    void removeDeductionsOfResigned();

    void updateAttendance(UpdateAttendance dto);
    void addHoliday(AddHoliday dto);
    void initiateTodayAttendance();

    List<AdminAttendanceRecord> attendanceYesterday();
    List<AdminPerformanceRecord> winterPerformance();

    void removeHolidayAttendance();
    void removeDayOff(RemoveDayOff dto);
    void removeLeaveFromAttendance(RemoveLeaveFromAttendance dto);

    void replaceEmployee(ReplaceEmployee dto);
    void updateStatuses();
}
