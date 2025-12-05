import React, { useState, useEffect, useCallback } from 'react';
import type { EmployeeProfile, RejectedLeave, PerformanceRecord } from '../types';
import { MOCK_EMPLOYEES, mapMockEmployeesToProfiles } from '../types';

type AdminTab = 'employees' | 'attendance' | 'general';

interface AdminDashboardProps {
  onLogout: () => void;
}

const API_BASE_URL = '';
const getAuthHeaders = () => {
  const token = localStorage.getItem('jwtToken');
  return {
    'Content-Type': 'application/json',
    ...(token && { 'Authorization': `Bearer ${token}` }),
  };
};

export const AdminDashboard: React.FC<AdminDashboardProps> = ({ onLogout }) => {
  const [activeTab, setActiveTab] = useState<AdminTab>('employees');
  const [employees, setEmployees] = useState<EmployeeProfile[]>([]);
  const [rejectedLeaves, setRejectedLeaves] = useState<RejectedLeave[]>([]);
  const [isAttendanceModalOpen, setIsAttendanceModalOpen] = useState(false);
  const [employeeIdToUpdate, setEmployeeIdToUpdate] = useState<number | null>(null);
  const [newCheckIn, setNewCheckIn] = useState('09:00:00');
  const [newCheckOut, setNewCheckOut] = useState('17:00:00');
  const [newHolidayName, setNewHolidayName] = useState('');
  const [newHolidayDateFrom, setNewHolidayDateFrom] = useState('');
  const [newHolidayDateTo, setNewHolidayDateTo] = useState('');


  const handleAction = (action: string) => alert(`${action}`);

  const getStatusClass = (status: string) => {
    if (status === 'Active') return 'bg-green-500/20 text-green-300';
    return 'bg-red-500/20 text-red-300';
  };

  const fetchAllEmployees = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/all-employee-profiles`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const text = await response.text();
        console.log("Raw response from employees:", text);
        try {
          const data: EmployeeProfile[] = text ? JSON.parse(text) : [];
          setEmployees(data);
        } catch (e) {
          console.error("JSON Parse Error:", e);
          setEmployees([]);
        }
      } else {
        console.error("Failed to fetch employees:", response.statusText);
        setEmployees(mapMockEmployeesToProfiles(MOCK_EMPLOYEES));
      }
    } catch (error) {
      console.error('Network error fetching employees:', error);
      setEmployees(mapMockEmployeesToProfiles(MOCK_EMPLOYEES));
    }
  }, []);

  const fetchRejectedLeaves = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/rejected-medicals`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: RejectedLeave[] = await response.json();
        setRejectedLeaves(data);
      } else {
        console.error("Failed to fetch rejected leaves:", response.statusText);
        setRejectedLeaves([]);
      }
    } catch (error) {
      console.error('Network error fetching rejected leaves:', error);
      setRejectedLeaves([]);
    }
  }, []);

  const fetchWinterPerformance = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/winter-performance`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: PerformanceRecord[] = await response.json();
        alert(`Fetched ${data.length} Winter Performance Records. Check the console for details.`);
        console.log("Winter Performance Data:", data);
      } else {
        console.error("Failed to fetch winter performance:", response.statusText);
        alert(`Failed to fetch Winter Performance. Status: ${response.status}`);
      }
    } catch (error) {
      console.error('Network error fetching winter performance:', error);
      alert('A network error occurred while fetching performance data.');
    }
  }, []);

  useEffect(() => {
    if (activeTab === 'employees') {
      fetchAllEmployees();
    }
    if (activeTab === 'attendance') {
      fetchRejectedLeaves();
    }
  }, [activeTab, fetchAllEmployees, fetchRejectedLeaves]);

  const handleInitiateAttendance = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/initiate-attendance`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        const result = await response.json();
        handleAction(`Daily attendance initiated successfully! Message: ${result.message || 'No message.'}`);
      } else {
        const error = await response.json();
        handleAction(`Failed to initiate attendance: ${error.message || response.statusText}`);
      }
    } catch (error) {
      handleAction('A network error occurred while initiating attendance.');
    }
  };

  const handleAddHoliday = async () => {
    if (!newHolidayName || !newHolidayDateFrom || !newHolidayDateTo) {
      alert("Please fill in all holiday details.");
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/add-holiday`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({
          holiday_name: newHolidayName,
          from_Date: newHolidayDateFrom,
          to_Date: newHolidayDateTo,
        }),
      });

      if (response.ok) {
        handleAction(`Holiday '${newHolidayName}' added successfully!`);
        setNewHolidayName('');
        setNewHolidayDateFrom('');
        setNewHolidayDateTo('');
      } else {
        const error = await response.json();
        handleAction(`Failed to add holiday: ${error.message || response.statusText}`);
      }
    } catch (error) {
      handleAction('A network error occurred while adding the holiday.');
    }
  };

  const handleUpdateAttendance = async () => {
    if (employeeIdToUpdate === null) return;

    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/update-attendance`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({
          check_in_time: newCheckIn,
          check_out_time: newCheckOut,
          Employee_id: employeeIdToUpdate,
        }),
      });

      if (response.ok) {
        handleAction(`Attendance updated for employee ID ${employeeIdToUpdate}.`);
      } else {
        const error = await response.json();
        handleAction(`Failed to update attendance: ${error.message || response.statusText}`);
      }
    } catch (error) {
      handleAction('A network error occurred while updating attendance.');
    } finally {
      setIsAttendanceModalOpen(false);
      setEmployeeIdToUpdate(null);
    }
  };

  const handleSimplePostAction = async (endpoint: string, actionName: string, body?: any) => {
    try {
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        method: 'POST',
        headers: getAuthHeaders(),
        ...(body && { body: JSON.stringify(body) }),
      });

      // --- SAFE RESPONSE HANDLING ---
      const contentType = response.headers.get("content-type");
      const isJson = contentType && contentType.includes("application/json");

      if (response.ok) {
        let message = 'Operation completed successfully!';

        if (isJson) {
          const result = await response.json();
          message = result.message || message;
        }

        handleAction(`${actionName} completed successfully! Message: ${message}`);
      } else {
        let message = response.statusText;

        if (isJson) {
          const error = await response.json();
          message = error.message || message;
        }
        handleAction(`Failed to perform ${actionName}: ${message}`);
      }
    } catch (error) {
      handleAction(`A network error or parse error occurred during ${actionName}.`);
    }
  };
  const renderAttendanceUpdateModal = () => {
    if (!isAttendanceModalOpen) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
        <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-md border border-cyan-700/50">
          <h3 className="text-xl font-bold text-white mb-4">Update Attendance for ID: {employeeIdToUpdate}</h3>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-1">Check-in Time</label>
              <input
                type="time"
                value={newCheckIn}
                onChange={(e) => setNewCheckIn(e.target.value)}
                className="w-full px-3 py-2 bg-gray-900 border border-gray-700 rounded-lg text-white"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-1">Check-out Time</label>
              <input
                type="time"
                value={newCheckOut}
                onChange={(e) => setNewCheckOut(e.target.value)}
                className="w-full px-3 py-2 bg-gray-900 border border-gray-700 rounded-lg text-white"
              />
            </div>
          </div>

          <div className="flex justify-end gap-3 mt-6">
            <button
              onClick={() => setIsAttendanceModalOpen(false)}
              className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white"
            >
              Cancel
            </button>
            <button
              onClick={handleUpdateAttendance}
              className="px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold"
            >
              Update Record
            </button>
          </div>
        </div>
      </div>
    );
  };


  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6 text-gray-100">
      {renderAttendanceUpdateModal()}
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
                  <span className="material-symbols-outlined">group</span> View Employees
                </button>
                <button
                  onClick={() => setActiveTab('attendance')}
                  className={`w-full text-left p-3 rounded-xl transition flex items-center gap-3 ${activeTab === 'attendance' ? 'bg-cyan-900/50 text-cyan-300 border border-cyan-700/50' : 'hover:bg-gray-700'}`}
                >
                  <span className="material-symbols-outlined">calendar_month</span> Attendance
                </button>
                <button
                  onClick={() => setActiveTab('general')}
                  className={`w-full text-left p-3 rounded-xl transition flex items-center gap-3 ${activeTab === 'general' ? 'bg-cyan-900/50 text-cyan-300 border border-cyan-700/50' : 'hover:bg-gray-700'}`}
                >
                  <span className="material-symbols-outlined">settings</span> General Mgmt
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
                    <span className="material-symbols-outlined text-sm align-middle mr-1">refresh</span> Refresh Data
                  </button>
                </div>
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
                  <h4 className="font-semibold text-gray-300 mb-2">Bulk Management</h4>
                  <div className="grid grid-cols-2 gap-4">
                    <button onClick={() => handleSimplePostAction('/api/admin/remove-deductions', 'Deductions Removal')} className="p-2 bg-red-800/50 hover:bg-red-800/70 rounded text-sm text-red-300 border border-red-600">
                      Remove All Deductions
                    </button>
                    <button onClick={() => handleSimplePostAction('/api/admin/remove-dayoff', 'Day Off Removal')} className="p-2 bg-gray-800 hover:bg-gray-700 rounded text-sm text-gray-300 border border-gray-600">
                      Remove Employee Day Off
                    </button>
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
                    <button onClick={handleInitiateAttendance} className="w-full mb-2 bg-cyan-700 hover:bg-cyan-600 text-white py-2 rounded transition">
                      Initiate Today's Records
                    </button>
                    <button
                      onClick={() => {
                        setEmployeeIdToUpdate(1);
                        setIsAttendanceModalOpen(true);
                      }}
                      className="w-full bg-gray-700 hover:bg-gray-600 text-white py-2 rounded transition"
                    >
                      Update Employee Record (Manual)
                    </button>
                  </div>
                  <div className="p-5 bg-gray-900 rounded-xl border border-gray-600">
                    <h4 className="text-purple-400 font-bold mb-2">Leaves & Clearing</h4>
                    <button onClick={() => handleSimplePostAction('/api/admin/remove-approved-leaves', 'Approved Leaves Removal')} className="w-full mb-2 bg-red-700/50 border border-red-600 hover:bg-red-700/70 text-red-300 py-2 rounded transition">
                      Clear Approved Leaves
                    </button>
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
                    <span className="material-symbols-outlined text-sm">arrow_forward</span>
                  </button>
                </div>

                <div className="border-t border-gray-600 pt-6">
                  <h2 className="text-xl font-bold mb-4">Employee Replacement (Manual) 🔄</h2>
                  <p className="text-sm text-gray-400 mb-3">Manually replace one employee with another for a given period.</p>
                  <div className="p-4 bg-gray-900/50 rounded-xl border border-gray-600 space-y-3">
                    <input type="number" placeholder="Employee 1 ID (to be replaced)" className="w-full bg-gray-800 border border-gray-700 rounded p-2 text-white" />
                    <input type="number" placeholder="Employee 2 ID (replacement)" className="w-full bg-gray-800 border border-gray-700 rounded p-2 text-white" />
                    <div className="flex gap-2">
                      <input type="date" placeholder="From Date" className="w-1/2 bg-gray-800 border border-gray-700 rounded p-2 text-white" />
                      <input type="date" placeholder="To Date" className="w-1/2 bg-gray-800 border border-gray-700 rounded p-2 text-white" />
                    </div>
                    <button onClick={() => handleAction('Replacement logic triggered.')} className="bg-orange-600 hover:bg-orange-500 text-white px-6 py-2 rounded-lg w-full">
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