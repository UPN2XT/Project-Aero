import React, { useState, useEffect, useCallback } from 'react';
import type { EmployeeProfile, RejectedLeave, PerformanceRecord } from '../types';
import { MOCK_EMPLOYEES, mapMockEmployeesToProfiles } from '../types';

type AdminTab = 'employees' | 'attendance' | 'holidays' | 'general';

interface AdminDashboardProps {
  onLogout: () => void;
}

const API_BASE_URL = '';

const getAuthHeaders = (): HeadersInit => {
  const token = localStorage.getItem('jwtToken');
  if (!token) {
    console.warn('No JWT token found in localStorage!');
  }
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export const AdminDashboard: React.FC<AdminDashboardProps> = ({ onLogout }) => {
  const [activeTab, setActiveTab] = useState<AdminTab>('employees');
  const [employees, setEmployees] = useState<EmployeeProfile[]>([]);
  const [rejectedLeaves, setRejectedLeaves] = useState<RejectedLeave[]>([]);
  const [performanceRecords, setPerformanceRecords] = useState<PerformanceRecord[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Attendance modal state
  const [isAttendanceModalOpen, setIsAttendanceModalOpen] = useState(false);
  const [employeeIdToUpdate, setEmployeeIdToUpdate] = useState<string>('');
  const [newCheckIn, setNewCheckIn] = useState('09:00');
  const [newCheckOut, setNewCheckOut] = useState('17:00');

  // Holiday form state
  const [newHolidayName, setNewHolidayName] = useState('');
  const [newHolidayDateFrom, setNewHolidayDateFrom] = useState('');
  const [newHolidayDateTo, setNewHolidayDateTo] = useState('');

  // Replace employee form state
  const [replaceEmp1Id, setReplaceEmp1Id] = useState('');
  const [replaceEmp2Id, setReplaceEmp2Id] = useState('');
  const [replaceFromDate, setReplaceFromDate] = useState('');
  const [replaceToDate, setReplaceToDate] = useState('');

  // Remove day off / approved leaves state
  const [removeDayOffEmpId, setRemoveDayOffEmpId] = useState('');
  const [removeApprovedLeavesEmpId, setRemoveApprovedLeavesEmpId] = useState('');

  const showMessage = (message: string, isError = false) => {
    if (isError) {
      setError(message);
      setTimeout(() => setError(null), 5000);
    } else {
      alert(message);
    }
  };

  const getStatusClass = (status: string) => {
    const statusLower = status?.toLowerCase() || '';
    if (statusLower === 'active') return 'bg-green-500/20 text-green-300';
    if (statusLower === 'onleave' || statusLower === 'on leave') return 'bg-yellow-500/20 text-yellow-300';
    return 'bg-red-500/20 text-red-300';
  };

  const fetchAllEmployees = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/all-employee-profiles`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const text = await response.text();
        const data: EmployeeProfile[] = text ? JSON.parse(text) : [];
        setEmployees(data);
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        showMessage('Failed to fetch employees. Using mock data.', true);
        setEmployees(mapMockEmployeesToProfiles(MOCK_EMPLOYEES));
      }
    } catch (err) {
      console.error('Network error fetching employees:', err);
      showMessage('Network error. Using mock data.', true);
      setEmployees(mapMockEmployeesToProfiles(MOCK_EMPLOYEES));
    } finally {
      setLoading(false);
    }
  }, [onLogout]);

  const fetchRejectedLeaves = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/rejected-medicals`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: RejectedLeave[] = await response.json();
        setRejectedLeaves(data);
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        setRejectedLeaves([]);
      }
    } catch (err) {
      console.error('Network error fetching rejected leaves:', err);
      setRejectedLeaves([]);
    } finally {
      setLoading(false);
    }
  }, [onLogout]);

  const fetchWinterPerformance = useCallback(async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/winter-performance`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: PerformanceRecord[] = await response.json();
        setPerformanceRecords(data);
        showMessage(`Fetched ${data.length} Winter Performance Records.`);
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        showMessage('Failed to fetch performance records.', true);
      }
    } catch (err) {
      console.error('Network error fetching winter performance:', err);
      showMessage('Network error while fetching performance data.', true);
    } finally {
      setLoading(false);
    }
  }, [onLogout]);

  useEffect(() => {
    if (activeTab === 'employees') fetchAllEmployees();
    if (activeTab === 'attendance') fetchRejectedLeaves();
    if (activeTab === 'general') fetchWinterPerformance();
  }, [activeTab, fetchAllEmployees, fetchRejectedLeaves, fetchWinterPerformance]);

  const handleSimplePostAction = async (endpoint: string, actionName: string, body?: object) => {
    try {
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        method: 'POST',
        headers: getAuthHeaders(),
        ...(body && { body: JSON.stringify(body) }),
      });

      if (response.ok) {
        showMessage(`${actionName} completed successfully!`);
        return true;
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        showMessage(`Failed: ${errorData.message || response.statusText}`, true);
      }
    } catch (err) {
      showMessage(`Network error during ${actionName}.`, true);
    }
    return false;
  };

  const handleInitiateAttendance = () => handleSimplePostAction('/api/admin/initiate-attendance', 'Daily Attendance Initiation');

  const handleAddHoliday = async () => {
    if (!newHolidayName || !newHolidayDateFrom || !newHolidayDateTo) {
      showMessage('Please fill in all holiday details.', true);
      return;
    }
    const success = await handleSimplePostAction('/api/admin/add-holiday', `Add Holiday '${newHolidayName}'`, {
      holiday_name: newHolidayName,
      from_Date: newHolidayDateFrom,
      to_Date: newHolidayDateTo,
    });
    if (success) {
      setNewHolidayName('');
      setNewHolidayDateFrom('');
      setNewHolidayDateTo('');
    }
  };

  const handleUpdateAttendance = async () => {
    if (!employeeIdToUpdate) {
      showMessage('Please enter an Employee ID.', true);
      return;
    }
    const success = await handleSimplePostAction('/api/admin/update-attendance', `Update Attendance for ID ${employeeIdToUpdate}`, {
      Employee_id: parseInt(employeeIdToUpdate),
      check_in_time: newCheckIn + ':00',
      check_out_time: newCheckOut + ':00',
    });
    if (success) {
      setIsAttendanceModalOpen(false);
      setEmployeeIdToUpdate('');
    }
  };

  const handleReplaceEmployee = async () => {
    if (!replaceEmp1Id || !replaceEmp2Id || !replaceFromDate || !replaceToDate) {
      showMessage('Please fill in all replacement details.', true);
      return;
    }
    const success = await handleSimplePostAction('/api/admin/replace-employee', 'Employee Replacement', {
      Emp1_ID: parseInt(replaceEmp1Id),
      Emp2_ID: parseInt(replaceEmp2Id),
      from_date: replaceFromDate,
      to_date: replaceToDate,
    });
    if (success) {
      setReplaceEmp1Id('');
      setReplaceEmp2Id('');
      setReplaceFromDate('');
      setReplaceToDate('');
    }
  };

  const handleRemoveDayOff = async () => {
    if (!removeDayOffEmpId) {
      showMessage('Please enter an Employee ID.', true);
      return;
    }
    const success = await handleSimplePostAction('/api/admin/remove-dayoff', 'Remove Day Off', {
      employee_id: parseInt(removeDayOffEmpId),
    });
    if (success) setRemoveDayOffEmpId('');
  };

  const handleRemoveApprovedLeaves = async () => {
    if (!removeApprovedLeavesEmpId) {
      showMessage('Please enter an Employee ID.', true);
      return;
    }
    const success = await handleSimplePostAction('/api/admin/remove-approved-leaves', 'Remove Approved Leaves', {
      employee_id: parseInt(removeApprovedLeavesEmpId),
    });
    if (success) setRemoveApprovedLeavesEmpId('');
  };

  const renderAttendanceModal = () => {
    if (!isAttendanceModalOpen) return null;
    return (
      <div className="fixed inset-0 bg-black/75 flex items-center justify-center z-50">
        <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-md border border-gray-700">
          <h3 className="text-xl font-bold text-cyan-400 mb-4">Update Attendance</h3>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">Employee ID</label>
              <input
                type="number"
                value={employeeIdToUpdate}
                onChange={(e) => setEmployeeIdToUpdate(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
                placeholder="Enter employee ID"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">Check-in Time</label>
              <input
                type="time"
                value={newCheckIn}
                onChange={(e) => setNewCheckIn(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">Check-out Time</label>
              <input
                type="time"
                value={newCheckOut}
                onChange={(e) => setNewCheckOut(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              />
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button
              onClick={() => setIsAttendanceModalOpen(false)}
              className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white transition"
            >
              Cancel
            </button>
            <button
              onClick={handleUpdateAttendance}
              className="px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold transition"
            >
              Update Record
            </button>
          </div>
        </div>
      </div>
    );
  };

  const renderEmployeesTab = () => (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h3 className="text-xl font-bold text-cyan-400">All Employee Profiles</h3>
        <button
          onClick={fetchAllEmployees}
          className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white text-sm transition"
        >
          Refresh
        </button>
      </div>

      {loading ? (
        <div className="text-center py-8 text-gray-400">Loading...</div>
      ) : employees.length === 0 ? (
        <div className="text-center py-8 text-gray-400">No employees found</div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-left text-gray-400 border-b border-gray-700">
                <th className="pb-3 px-2">ID</th>
                <th className="pb-3 px-2">Name</th>
                <th className="pb-3 px-2">Email</th>
                <th className="pb-3 px-2">Contract</th>
                <th className="pb-3 px-2">Day Off</th>
                <th className="pb-3 px-2">Status</th>
              </tr>
            </thead>
            <tbody>
              {employees.map((emp) => (
                <tr key={emp.employee_ID} className="border-b border-gray-800 hover:bg-gray-800/50">
                  <td className="py-3 px-2 text-white">{emp.employee_ID}</td>
                  <td className="py-3 px-2 text-white font-medium">{emp.first_name} {emp.last_name}</td>
                  <td className="py-3 px-2 text-gray-300">{emp.email}</td>
                  <td className="py-3 px-2 text-gray-300">{emp.type_of_contract}</td>
                  <td className="py-3 px-2 text-gray-300">{emp.official_day_off}</td>
                  <td className="py-3 px-2">
                    <span className={`px-2 py-1 rounded-full text-xs ${getStatusClass(emp.employment_status)}`}>
                      {emp.employment_status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Bulk Actions */}
      <div className="grid md:grid-cols-2 gap-4 pt-4 border-t border-gray-700">
        <div className="bg-gray-800/50 p-4 rounded-xl border border-gray-700">
          <h4 className="text-sm font-semibold text-gray-300 mb-3">Remove Day Off</h4>
          <div className="flex gap-2">
            <input
              type="number"
              value={removeDayOffEmpId}
              onChange={(e) => setRemoveDayOffEmpId(e.target.value)}
              className="flex-1 px-3 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white text-sm"
              placeholder="Employee ID"
            />
            <button
              onClick={handleRemoveDayOff}
              className="px-4 py-2 bg-orange-600 hover:bg-orange-500 rounded-lg text-white text-sm transition"
            >
              Remove
            </button>
          </div>
        </div>
        <div className="bg-gray-800/50 p-4 rounded-xl border border-gray-700">
          <h4 className="text-sm font-semibold text-gray-300 mb-3">Remove Approved Leaves</h4>
          <div className="flex gap-2">
            <input
              type="number"
              value={removeApprovedLeavesEmpId}
              onChange={(e) => setRemoveApprovedLeavesEmpId(e.target.value)}
              className="flex-1 px-3 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white text-sm"
              placeholder="Employee ID"
            />
            <button
              onClick={handleRemoveApprovedLeaves}
              className="px-4 py-2 bg-red-600 hover:bg-red-500 rounded-lg text-white text-sm transition"
            >
              Remove
            </button>
          </div>
        </div>
      </div>

      <button
        onClick={() => handleSimplePostAction('/api/admin/remove-deductions', 'Remove All Deductions')}
        className="w-full px-4 py-2 bg-red-600/20 hover:bg-red-600/30 border border-red-600 rounded-lg text-red-300 text-sm transition"
      >
        Remove All Deductions (Resigned Employees)
      </button>
    </div>
  );

  const renderAttendanceTab = () => (
    <div className="space-y-6">
      <h3 className="text-xl font-bold text-cyan-400">Attendance Management</h3>

      {/* Daily Operations */}
      <div className="grid md:grid-cols-2 gap-4">
        <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700">
          <h4 className="text-lg font-semibold text-white mb-4">Daily Operations</h4>
          <div className="space-y-3">
            <button
              onClick={handleInitiateAttendance}
              className="w-full px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold transition"
            >
              Initiate Today's Attendance
            </button>
            <button
              onClick={() => setIsAttendanceModalOpen(true)}
              className="w-full px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white transition"
            >
              Update Employee Attendance
            </button>
          </div>
        </div>

        <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700">
          <h4 className="text-lg font-semibold text-white mb-4">Rejected Medical Leaves</h4>
          <button
            onClick={fetchRejectedLeaves}
            className="w-full px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white transition mb-2"
          >
            Refresh ({rejectedLeaves.length} records)
          </button>
        </div>
      </div>

      {/* Rejected Leaves Table */}
      {rejectedLeaves.length > 0 && (
        <div className="bg-red-900/20 p-4 rounded-xl border border-red-700">
          <h4 className="text-lg font-semibold text-red-300 mb-4">Rejected Medical Leaves</h4>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="text-left text-red-400 border-b border-red-700">
                  <th className="pb-3 px-2">Request ID</th>
                  <th className="pb-3 px-2">Employee ID</th>
                  <th className="pb-3 px-2">Start Date</th>
                  <th className="pb-3 px-2">End Date</th>
                  <th className="pb-3 px-2">Insurance</th>
                </tr>
              </thead>
              <tbody>
                {rejectedLeaves.map((leave) => (
                  <tr key={leave.request_ID} className="border-b border-red-800/50">
                    <td className="py-3 px-2 text-red-100">{leave.request_ID}</td>
                    <td className="py-3 px-2 text-red-100">{leave.emp_ID}</td>
                    <td className="py-3 px-2 text-red-200">{leave.start_date}</td>
                    <td className="py-3 px-2 text-red-200">{leave.end_date}</td>
                    <td className="py-3 px-2">
                      <span className={`px-2 py-1 rounded-full text-xs ${leave.insurance_status ? 'bg-green-500/20 text-green-300' : 'bg-gray-500/20 text-gray-300'}`}>
                        {leave.insurance_status ? 'Yes' : 'No'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );

  const renderHolidaysTab = () => (
    <div className="space-y-6">
      <h3 className="text-xl font-bold text-cyan-400">Holiday Management</h3>

      {/* Add Holiday Form */}
      <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700 max-w-2xl">
        <h4 className="text-lg font-semibold text-white mb-4">Add New Holiday</h4>
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Holiday Name</label>
            <input
              type="text"
              value={newHolidayName}
              onChange={(e) => setNewHolidayName(e.target.value)}
              className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              placeholder="e.g. National Day"
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">From Date</label>
              <input
                type="date"
                value={newHolidayDateFrom}
                onChange={(e) => setNewHolidayDateFrom(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">To Date</label>
              <input
                type="date"
                value={newHolidayDateTo}
                onChange={(e) => setNewHolidayDateTo(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              />
            </div>
          </div>
          <button
            onClick={handleAddHoliday}
            className="w-full px-4 py-2 bg-green-600 hover:bg-green-500 rounded-lg text-white font-semibold transition"
          >
            Add Holiday
          </button>
        </div>
      </div>

      <button
        onClick={() => handleSimplePostAction('/api/admin/remove-holiday', 'Remove Expired Holidays')}
        className="px-4 py-2 bg-red-600/20 hover:bg-red-600/30 border border-red-600 rounded-lg text-red-300 transition"
      >
        Remove Expired Holidays
      </button>
    </div>
  );

  const renderGeneralTab = () => (
    <div className="space-y-6">
      <h3 className="text-xl font-bold text-cyan-400">General Management</h3>

      {/* Performance Records */}
      <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700">
        <div className="flex justify-between items-center mb-4">
          <h4 className="text-lg font-semibold text-white">Winter Performance Records</h4>
          <button
            onClick={fetchWinterPerformance}
            className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white text-sm transition"
          >
            Refresh
          </button>
        </div>
        {performanceRecords.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="text-left text-gray-400 border-b border-gray-700">
                  <th className="pb-3 px-2">ID</th>
                  <th className="pb-3 px-2">Employee ID</th>
                  <th className="pb-3 px-2">Rating</th>
                  <th className="pb-3 px-2">Semester</th>
                  <th className="pb-3 px-2">Comments</th>
                </tr>
              </thead>
              <tbody>
                {performanceRecords.map((record) => (
                  <tr key={record.performance_ID} className="border-b border-gray-800 hover:bg-gray-800/50">
                    <td className="py-3 px-2 text-white">{record.performance_ID}</td>
                    <td className="py-3 px-2 text-white">{record.emp_ID}</td>
                    <td className="py-3 px-2">
                      <span className="text-yellow-400">{'★'.repeat(record.rating)}{'☆'.repeat(5 - record.rating)}</span>
                    </td>
                    <td className="py-3 px-2 text-gray-300">{record.semester}</td>
                    <td className="py-3 px-2 text-gray-300 truncate max-w-xs">{record.comments}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-8 text-gray-400">No performance records found</div>
        )}
      </div>

      {/* Employee Replacement */}
      <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700 max-w-2xl">
        <h4 className="text-lg font-semibold text-white mb-4">Employee Replacement</h4>
        <p className="text-sm text-gray-400 mb-4">Assign a replacement employee for a specific period.</p>
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">Employee to Replace</label>
              <input
                type="number"
                value={replaceEmp1Id}
                onChange={(e) => setReplaceEmp1Id(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
                placeholder="Employee ID"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">Replacement Employee</label>
              <input
                type="number"
                value={replaceEmp2Id}
                onChange={(e) => setReplaceEmp2Id(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
                placeholder="Replacement ID"
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">From Date</label>
              <input
                type="date"
                value={replaceFromDate}
                onChange={(e) => setReplaceFromDate(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">To Date</label>
              <input
                type="date"
                value={replaceToDate}
                onChange={(e) => setReplaceToDate(e.target.value)}
                className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              />
            </div>
          </div>
          <button
            onClick={handleReplaceEmployee}
            className="w-full px-4 py-2 bg-orange-600 hover:bg-orange-500 rounded-lg text-white font-semibold transition"
          >
            Replace Employee
          </button>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6 text-gray-100">
      {renderAttendanceModal()}

      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">
          <span className="text-cyan-400">Admin</span> Dashboard
        </h1>
        <button
          onClick={onLogout}
          className="px-4 py-2 bg-red-600 hover:bg-red-500 rounded-lg text-white font-semibold transition"
        >
          Logout
        </button>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="mb-6 p-4 bg-red-500/20 border border-red-500 rounded-lg text-red-300">
          {error}
        </div>
      )}

      {/* Tabs */}
      <div className="flex gap-2 mb-8 flex-wrap">
        {(['employees', 'attendance', 'holidays', 'general'] as AdminTab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 rounded-lg font-medium transition ${activeTab === tab
                ? 'bg-cyan-600 text-white'
                : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
              }`}
          >
            {tab.charAt(0).toUpperCase() + tab.slice(1)}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div className="bg-gray-800/30 rounded-xl p-6 border border-gray-700">
        {activeTab === 'employees' && renderEmployeesTab()}
        {activeTab === 'attendance' && renderAttendanceTab()}
        {activeTab === 'holidays' && renderHolidaysTab()}
        {activeTab === 'general' && renderGeneralTab()}
      </div>
    </div>
  );
};