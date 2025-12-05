import React, { useState, useEffect, useCallback } from 'react';
import type { EmployeeProfile, RejectedLeave, PerformanceRecord } from '../types';
import { MOCK_EMPLOYEES, mapMockEmployeesToProfiles } from '../types';
import { Users, Calendar, Settings, RefreshCw, X, ArrowRight } from 'lucide-react';

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

  /* Replacement State */
  const [replaceEmpId1, setReplaceEmpId1] = useState('');
  const [replaceEmpId2, setReplaceEmpId2] = useState('');
  const [replaceFromDate, setReplaceFromDate] = useState('');
  const [replaceToDate, setReplaceToDate] = useState('');

  /* Targeted Actions State */
  const [targetDayOffEmpId, setTargetDayOffEmpId] = useState('');
  const [targetLeaveEmpId, setTargetLeaveEmpId] = useState('');

  /* Department & Yesterday Attendance State */
  const [employeesPerDept, setEmployeesPerDept] = useState<{ dept_name: string, num_employees: number }[]>([]);
  const [yesterdayAttendance, setYesterdayAttendance] = useState<any[]>([]);
  const [showYesterdayModal, setShowYesterdayModal] = useState(false);

  // Performance modal state
  const [showPerformanceModal, setShowPerformanceModal] = useState(false);

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
    const normalizedStatus = status?.toLowerCase() || '';

    // Active employees - Green
    if (normalizedStatus === 'active') {
      return 'bg-green-500/20 text-green-400 border border-green-500/30';
    }

    // On Leave - Yellow/Amber
    if (normalizedStatus.includes('leave') || normalizedStatus === 'on leave') {
      return 'bg-amber-500/20 text-amber-400 border border-amber-500/30';
    }

    // Resigned/Terminated - Red
    if (normalizedStatus === 'resigned' || normalizedStatus === 'terminated') {
      return 'bg-red-500/20 text-red-400 border border-red-500/30';
    }

    // Suspended - Orange
    if (normalizedStatus === 'suspended') {
      return 'bg-orange-500/20 text-orange-400 border border-orange-500/30';
    }

    // Inactive - Gray
    if (normalizedStatus === 'inactive') {
      return 'bg-gray-500/20 text-gray-400 border border-gray-500/30';
    }

    // Default - Blue
    return 'bg-blue-500/20 text-blue-400 border border-blue-500/30';
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
        setShowPerformanceModal(true);
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

  const fetchEmployeesPerDepartment = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/employees-per-department`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: { dept_name: string, num_employees: number }[] = await response.json();
        setEmployeesPerDept(data);
      } else {
        console.error("Failed to fetch employees per department:", response.statusText);
        setEmployeesPerDept([]);
      }
    } catch (error) {
      console.error('Network error fetching employees per department:', error);
      setEmployeesPerDept([]);
    }
  }, []);

  const fetchYesterdayAttendance = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/yesterday-attendance`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data = await response.json();
        setYesterdayAttendance(data);
        setShowYesterdayModal(true);
      } else {
        console.error("Failed to fetch yesterday's attendance:", response.statusText);
        alert(`Failed to fetch yesterday's attendance: ${response.statusText}`);
      }
    } catch (error) {
      console.error('Network error fetching yesterday\'s attendance:', error);
      alert('Network error occurred while fetching yesterday\'s attendance.');
    }
  }, []);

  useEffect(() => {
    if (activeTab === 'employees') {
      fetchAllEmployees();
      fetchEmployeesPerDepartment();
    }
    if (activeTab === 'attendance') {
      fetchRejectedLeaves();
    }
  }, [activeTab, fetchAllEmployees, fetchEmployeesPerDepartment, fetchRejectedLeaves]);





  const handleSimplePostAction = async (endpoint: string, actionName: string, body?: any) => {
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
    if (!replaceEmpId1 || !replaceEmpId2 || !replaceFromDate || !replaceToDate) {
      showMessage('Please fill in all replacement details.', true);
      return;
    }
    const success = await handleSimplePostAction('/api/admin/replace-employee', 'Employee Replacement', {
      Emp1_ID: parseInt(replaceEmpId1),
      Emp2_ID: parseInt(replaceEmpId2),
      from_date: replaceFromDate,
      to_date: replaceToDate,
    });
    if (success) {
      setReplaceEmpId1('');
      setReplaceEmpId2('');
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

  const renderYesterdayModal = () => {
    if (!showYesterdayModal) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
        <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-4xl border border-cyan-700/50 max-h-[80vh] overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-xl font-bold text-white">Yesterday's Attendance Records</h3>
            <button
              onClick={() => setShowYesterdayModal(false)}
              className="text-gray-400 hover:text-white"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          {yesterdayAttendance.length === 0 ? (
            <div className="text-center py-8 text-gray-400">No attendance records found for yesterday</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="border-b border-gray-600 text-gray-400">
                    <th className="p-2">Attendance ID</th>
                    <th className="p-2">Employee ID</th>
                    <th className="p-2">Date</th>
                    <th className="p-2">Check In</th>
                    <th className="p-2">Check Out</th>
                    <th className="p-2">Duration</th>
                    <th className="p-2">Status</th>
                  </tr>
                </thead>
                <tbody className="text-gray-200">
                  {yesterdayAttendance.map((record: any) => (
                    <tr key={record.attendance_ID || Math.random()} className="border-b border-gray-700/50">
                      <td className="p-2">{record.attendance_ID}</td>
                      <td className="p-2">{record.emp_ID}</td>
                      <td className="p-2">{record.date}</td>
                      <td className="p-2">{record.check_in_time}</td>
                      <td className="p-2">{record.check_out_time}</td>
                      <td className="p-2">{record.total_duration}</td>
                      <td className="p-2">
                        <span className={`px-2 py-1 rounded text-xs ${record.status === 'Present' ? 'bg-green-500/20 text-green-300' :
                          record.status === 'Absent' ? 'bg-red-500/20 text-red-300' :
                            'bg-yellow-500/20 text-yellow-300'
                          }`}>
                          {record.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          <div className="flex justify-end mt-6">
            <button
              onClick={() => setShowYesterdayModal(false)}
              className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    );
  };

  const renderPerformanceModal = () => {
    if (!showPerformanceModal) return null;

    // Calculate statistics
    const avgRating = performanceRecords.length > 0
      ? (performanceRecords.reduce((sum, record) => sum + record.rating, 0) / performanceRecords.length).toFixed(2)
      : '0.00';

    const getRatingColor = (rating: number) => {
      if (rating >= 4.5) return 'bg-green-500/20 text-green-300 border-green-500/30';
      if (rating >= 3.5) return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
      if (rating >= 2.5) return 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30';
      if (rating >= 1.5) return 'bg-orange-500/20 text-orange-300 border-orange-500/30';
      return 'bg-red-500/20 text-red-300 border-red-500/30';
    };

    const getRatingStars = (rating: number) => {
      const fullStars = Math.floor(rating);
      const hasHalfStar = rating % 1 >= 0.5;
      return (
        <div className="flex items-center gap-0.5">
          {[...Array(5)].map((_, i) => (
            <span key={i} className={`text-lg ${i < fullStars ? 'text-yellow-400' :
              i === fullStars && hasHalfStar ? 'text-yellow-400/50' :
                'text-gray-600'
              }`}>
              ★
            </span>
          ))}
        </div>
      );
    };

    return (
      <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
        <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-5xl border border-cyan-700/50 max-h-[85vh] overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-xl font-bold text-white">Winter Performance Records</h3>
            <button
              onClick={() => setShowPerformanceModal(false)}
              className="text-gray-400 hover:text-white transition"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Summary Statistics */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <div className="bg-cyan-900/30 p-4 rounded-lg border border-cyan-700/50">
              <div className="text-sm text-gray-400 mb-1">Total Records</div>
              <div className="text-2xl font-bold text-cyan-400">{performanceRecords.length}</div>
            </div>
            <div className="bg-green-900/30 p-4 rounded-lg border border-green-700/50">
              <div className="text-sm text-gray-400 mb-1">Average Rating</div>
              <div className="text-2xl font-bold text-green-400">{avgRating} / 5.0</div>
            </div>
            <div className="bg-purple-900/30 p-4 rounded-lg border border-purple-700/50">
              <div className="text-sm text-gray-400 mb-1">Unique Employees</div>
              <div className="text-2xl font-bold text-purple-400">
                {new Set(performanceRecords.map(r => r.emp_ID)).size}
              </div>
            </div>
          </div>

          {performanceRecords.length === 0 ? (
            <div className="text-center py-8 text-gray-400">No performance records found</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="border-b border-gray-600 text-gray-400">
                    <th className="p-3">Performance ID</th>
                    <th className="p-3">Employee ID</th>
                    <th className="p-3">Semester</th>
                    <th className="p-3">Rating</th>
                    <th className="p-3">Stars</th>
                    <th className="p-3">Comments</th>
                  </tr>
                </thead>
                <tbody className="text-gray-200">
                  {performanceRecords.map((record) => (
                    <tr key={record.performance_ID} className="border-b border-gray-700/50 hover:bg-gray-700/30 transition">
                      <td className="p-3">{record.performance_ID}</td>
                      <td className="p-3 font-medium">{record.emp_ID}</td>
                      <td className="p-3">
                        <span className="px-2 py-1 rounded text-xs bg-blue-500/20 text-blue-300 border border-blue-500/30">
                          {record.semester}
                        </span>
                      </td>
                      <td className="p-3">
                        <span className={`px-3 py-1 rounded-lg text-sm font-bold border ${getRatingColor(record.rating)}`}>
                          {record.rating.toFixed(1)}
                        </span>
                      </td>
                      <td className="p-3">
                        {getRatingStars(record.rating)}
                      </td>
                      <td className="p-3 max-w-xs truncate" title={record.comments}>
                        {record.comments || 'No comments'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          <div className="flex justify-end mt-6">
            <button
              onClick={() => setShowPerformanceModal(false)}
              className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white transition"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6 text-gray-100">
      {renderAttendanceModal()}
      {renderYesterdayModal()}
      {renderPerformanceModal()}
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-8 bg-gray-800/50 p-4 rounded-2xl border border-gray-700 backdrop-blur-md">
          <h1 className="text-2xl font-bold text-white"><span className="text-cyan-400">Admin</span> Dashboard</h1>
          <button onClick={onLogout} className="text-sm bg-red-500/20 text-red-400 px-4 py-2 rounded-lg hover:bg-red-500/30 transition">Logout</button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="md:col-span-1 space-y-4">
            <div className="bg-gray-800/80 p-6 rounded-2xl border border-gray-700">
              <h3 className="text-lg font-semibold text-cyan-400 mb-4">Quick Actions</h3>
              <div className="space-y-3">
                <button
                  onClick={() => setActiveTab('employees')}
                  className={`w-full text-left p-3 rounded-xl transition flex items-center gap-3 ${activeTab === 'employees' ? 'bg-cyan-900/50 text-cyan-300 border border-cyan-700/50' : 'hover:bg-gray-700'}`}
                >
                  <Users className="w-4 h-4" /> View Employees
                </button>
                <button
                  onClick={() => setActiveTab('attendance')}
                  className={`w-full text-left p-3 rounded-xl transition flex items-center gap-3 ${activeTab === 'attendance' ? 'bg-cyan-900/50 text-cyan-300 border border-cyan-700/50' : 'hover:bg-gray-700'}`}
                >
                  <Calendar className="w-4 h-4" /> Attendance
                </button>
                <button
                  onClick={() => setActiveTab('general')}
                  className={`w-full text-left p-3 rounded-xl transition flex items-center gap-3 ${activeTab === 'general' ? 'bg-cyan-900/50 text-cyan-300 border border-cyan-700/50' : 'hover:bg-gray-700'}`}
                >
                  <Settings className="w-4 h-4" /> General Mgmt
                </button>
              </div>
            </div>
          </div>

          <div className="md:col-span-3 bg-gray-800/80 p-8 rounded-2xl border border-gray-700 min-h-[500px]">
            {activeTab === 'employees' && (
              <div>
                <div className="flex justify-between items-center mb-6">
                  <h2 className="text-xl font-bold">Employee Profiles ({employees.length} Records)</h2>
                  <button onClick={fetchAllEmployees} className="bg-gray-700/50 hover:bg-gray-700 px-3 py-1 text-sm rounded-lg border border-gray-600">
                    <RefreshCw className="w-4 h-4 inline mr-1" /> Refresh Data
                  </button>
                </div>

                {/* Department Summary */}
                {employeesPerDept.length > 0 && (
                  <div className="mb-6 p-4 bg-gray-900/50 rounded-xl border border-gray-600">
                    <h4 className="font-semibold text-cyan-400 mb-3">Employees Per Department</h4>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                      {employeesPerDept.map((dept) => (
                        <div key={dept.dept_name} className="bg-gray-800/50 p-3 rounded-lg border border-gray-700 text-center">
                          <div className="text-2xl font-bold text-cyan-400">{dept.num_employees}</div>
                          <div className="text-sm text-gray-400">{dept.dept_name}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="border-b border-gray-600 text-gray-400 text-sm">
                        <th className="p-3">ID</th>
                        <th className="p-3">Name</th>
                        <th className="p-3">Contract</th>
                        <th className="p-3">Day Off</th>
                        <th className="p-3">Status</th>
                      </tr>
                    </thead>
                    <tbody className="text-gray-200">
                      {employees.map(emp => (
                        <tr key={emp.employee_ID} className="border-b border-gray-700/50 hover:bg-gray-700/30 transition">
                          <td className="p-3">{emp.employee_ID}</td>
                          <td className="p-3 font-medium">{emp.first_name} {emp.last_name}</td>
                          <td className="p-3">{emp.type_of_contract}</td>
                          <td className="p-3">{emp.official_day_off}</td>
                          <td className="p-3">
                            <span className={`px-2 py-1 rounded text-xs ${getStatusClass(emp.employment_status)}`}>{emp.employment_status}</span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="mt-6 p-4 bg-gray-900/50 rounded-xl border border-gray-600">
                  <h4 className="font-semibold text-gray-300 mb-2">Employee Management</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <button onClick={() => handleSimplePostAction('/api/admin/remove-deductions', 'Deductions Removal')} className="p-2 bg-red-800/50 hover:bg-red-800/70 rounded text-sm text-red-300 border border-red-600">
                      Remove All Deductions
                    </button>
                    <div className="flex gap-2">
                      <input
                        type="number"
                        placeholder="Emp ID"
                        value={targetDayOffEmpId}
                        onChange={e => setTargetDayOffEmpId(e.target.value)}
                        className="w-24 bg-gray-800 border border-gray-600 rounded p-2 text-white text-sm"
                      />
                      <button onClick={() => {
                        if (!targetDayOffEmpId) return alert("Enter Employee ID");
                        handleSimplePostAction('/api/admin/remove-dayoff', 'Day Off Removal', { employee_id: Number(targetDayOffEmpId) });
                      }} className="flex-1 p-2 bg-gray-800 hover:bg-gray-700 rounded text-sm text-gray-300 border border-gray-600">
                        Remove Day Off
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'attendance' && (
              <div>
                <h2 className="text-xl font-bold mb-6">Attendance Management</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="p-5 bg-gray-900 rounded-xl border border-gray-600">
                    <h4 className="text-cyan-400 font-bold mb-2">Daily Operations</h4>
                    <button onClick={handleInitiateAttendance} className="w-full mb-3 bg-cyan-700 hover:bg-cyan-600 text-white py-2 rounded transition">
                      Initiate Today's Records
                    </button>
                    <button
                      onClick={() => {
                        setEmployeeIdToUpdate(1);
                        setIsAttendanceModalOpen(true);
                      }}
                      className="w-full mb-3 bg-gray-700 hover:bg-gray-600 text-white py-2 rounded transition"
                    >
                      Update Employee Record (Manual)
                    </button>
                    <button
                      onClick={fetchYesterdayAttendance}
                      className="w-full bg-purple-700 hover:bg-purple-600 text-white py-2 rounded transition"
                    >
                      View Yesterday's Attendance
                    </button>
                  </div>
                  <div className="p-5 bg-gray-900 rounded-xl border border-gray-600">
                    <h4 className="text-purple-400 font-bold mb-2">Leaves & Clearing</h4>
                    <div className="flex gap-2 mb-2">
                      <input
                        type="number"
                        placeholder="Emp ID"
                        value={targetLeaveEmpId}
                        onChange={e => setTargetLeaveEmpId(e.target.value)}
                        className="w-24 bg-gray-800 border border-gray-600 rounded p-2 text-white text-sm"
                      />
                      <button onClick={() => {
                        if (!targetLeaveEmpId) return alert("Enter Employee ID");
                        handleSimplePostAction('/api/admin/remove-approved-leaves', 'Approved Leaves Removal', { employee_id: Number(targetLeaveEmpId) });
                      }} className="flex-1 bg-red-700/50 border border-red-600 hover:bg-red-700/70 text-red-300 py-2 rounded transition">
                        Clear Approved Leaves
                      </button>
                    </div>
                    <button onClick={fetchRejectedLeaves} className="w-full bg-gray-800 border border-gray-600 hover:bg-gray-700 text-gray-300 py-2 rounded transition">
                      View Rejected Medical Leaves ({rejectedLeaves.length})
                    </button>
                  </div>
                </div>

                {rejectedLeaves.length > 0 && (
                  <div className="mt-6 p-4 bg-red-900/20 rounded-xl border border-red-700">
                    <h3 className="font-semibold text-red-300 mb-3">Rejected Medical Leaves</h3>
                    <div className="overflow-x-auto max-h-48">
                      <table className="w-full text-left text-sm">
                        <thead>
                          <tr className="border-b border-red-700 text-red-400">
                            <th className="p-2">ID</th>
                            <th className="p-2">Employee ID</th>
                            <th className="p-2">Dates</th>
                            <th className="p-2">Insurance Status</th>
                          </tr>
                        </thead>
                        <tbody className="text-red-100">
                          {rejectedLeaves.map(leave => (
                            <tr key={leave.request_ID} className="border-b border-red-800/50">
                              <td className="p-2">{leave.request_ID}</td>
                              <td className="p-2">{leave.emp_ID}</td>
                              <td className="p-2">{leave.start_date} to {leave.end_date}</td>
                              <td className="p-2">{leave.insurance_status ? 'Yes' : 'No'}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}

              </div>
            )}

            {activeTab === 'general' && (
              <div className="space-y-6">
                <div>
                  <h2 className="text-xl font-bold mb-4">Official Holidays 🗓️</h2>
                  <div className="flex gap-3 items-end p-4 bg-gray-900/50 rounded-xl border border-gray-600">
                    <div className="flex-1">
                      <label className="text-xs text-gray-400">Holiday Name</label>
                      <input
                        type="text"
                        value={newHolidayName}
                        onChange={(e) => setNewHolidayName(e.target.value)}
                        className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1"
                        placeholder="e.g. National Day"
                      />
                    </div>
                    <div className="flex-1">
                      <label className="text-xs text-gray-400">From Date</label>
                      <input
                        type="date"
                        value={newHolidayDateFrom}
                        onChange={(e) => setNewHolidayDateFrom(e.target.value)}
                        className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1"
                      />
                    </div>
                    <div className="flex-1">
                      <label className="text-xs text-gray-400">To Date</label>
                      <input
                        type="date"
                        value={newHolidayDateTo}
                        onChange={(e) => setNewHolidayDateTo(e.target.value)}
                        className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1"
                      />
                    </div>
                    <button onClick={handleAddHoliday} className="bg-green-600 hover:bg-green-500 text-white px-6 py-2 rounded h-10">Add</button>
                  </div>
                  <button
                    onClick={() => handleSimplePostAction('/api/admin/remove-holiday', 'Expired Holidays Removal')}
                    className="mt-4 p-2 bg-red-800/50 hover:bg-red-800/70 rounded-lg w-full text-center text-sm text-red-300 border border-red-600"
                  >
                    Remove Expired Holidays
                  </button>
                </div>

                <div className="border-t border-gray-600 pt-6">
                  <h2 className="text-xl font-bold mb-4">Performance Reviews 🏆</h2>
                  <button onClick={fetchWinterPerformance} className="p-3 bg-gray-700 hover:bg-gray-600 rounded-lg w-full text-left flex justify-between items-center">
                    <span>Fetch All Winter Semesters Performance</span>
                    <ArrowRight className="w-4 h-4" />
                  </button>
                </div>

                <div className="border-t border-gray-600 pt-6">
                  <h2 className="text-xl font-bold mb-4">Employee Replacement (Manual) 🔄</h2>
                  <p className="text-sm text-gray-400 mb-3">Manually replace one employee with another for a given period.</p>
                  <div className="p-4 bg-gray-900/50 rounded-xl border border-gray-600 space-y-3">
                    <input
                      type="number"
                      placeholder="Employee 1 ID (to be replaced)"
                      value={replaceEmpId1}
                      onChange={e => setReplaceEmpId1(e.target.value)}
                      className="w-full bg-gray-800 border border-gray-700 rounded p-2 text-white"
                    />
                    <input
                      type="number"
                      placeholder="Employee 2 ID (replacement)"
                      value={replaceEmpId2}
                      onChange={e => setReplaceEmpId2(e.target.value)}
                      className="w-full bg-gray-800 border border-gray-700 rounded p-2 text-white"
                    />
                    <div className="flex gap-2">
                      <input
                        type="date"
                        placeholder="From Date"
                        value={replaceFromDate}
                        onChange={e => setReplaceFromDate(e.target.value)}
                        className="w-1/2 bg-gray-800 border border-gray-700 rounded p-2 text-white"
                      />
                      <input
                        type="date"
                        placeholder="To Date"
                        value={replaceToDate}
                        onChange={e => setReplaceToDate(e.target.value)}
                        className="w-1/2 bg-gray-800 border border-gray-700 rounded p-2 text-white"
                      />
                    </div>
                    <button onClick={handleReplaceEmployee} className="bg-orange-600 hover:bg-orange-500 text-white px-6 py-2 rounded-lg w-full">
                      Replace Employee
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};