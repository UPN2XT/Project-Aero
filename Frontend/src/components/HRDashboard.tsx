import React, { useState, useEffect, useCallback } from 'react';
import type { EmployeeProfile, RejectedLeave, PerformanceRecord } from '../types';
import { MOCK_EMPLOYEES, mapMockEmployeesToProfiles } from '../types';

type AdminTab = 'employees' | 'attendance' | 'general';

interface AdminDashboardProps {
  onLogout: () => void;
}

const API_BASE_URL = ''; // your backend URL
const getAuthHeaders = () => {
  const token = localStorage.getItem('jwtToken'); // Bearer token
  if (!token) console.warn('No JWT token found in localStorage!');
  return {
    'Content-Type': 'application/json',
    ...(token && { 'Authorization': `Bearer ${token}` }),
  };
};

export const HRDashboard: React.FC<AdminDashboardProps> = ({ onLogout: _onLogout }) => {
  const [activeTab, _setActiveTab] = useState<AdminTab>('employees');
  const [employees, _setEmployees] = useState<EmployeeProfile[]>([]);
  const [rejectedLeaves, _setRejectedLeaves] = useState<RejectedLeave[]>([]);
  const [isAttendanceModalOpen, setIsAttendanceModalOpen] = useState(false);
  const [employeeIdToUpdate, setEmployeeIdToUpdate] = useState<number | null>(null);
  const [newCheckIn, setNewCheckIn] = useState('09:00:00');
  const [newCheckOut, setNewCheckOut] = useState('17:00:00');
  const [newHolidayName, setNewHolidayName] = useState('');
  const [newHolidayDateFrom, setNewHolidayDateFrom] = useState('');
  const [newHolidayDateTo, setNewHolidayDateTo] = useState('');

  const handleAction = (action: string) => alert(`${action}`);

  const _getStatusClass = (status: string) => status === 'Active'
    ? 'bg-green-500/20 text-green-300'
    : 'bg-red-500/20 text-red-300';

  const fetchAllEmployees = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/all-employee-profiles`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: EmployeeProfile[] = await response.json();
        _setEmployees(data);
      } else {
        console.error("Failed to fetch employees:", response.statusText);
        _setEmployees(mapMockEmployeesToProfiles(MOCK_EMPLOYEES));
      }
    } catch (error) {
      console.error('Network error fetching employees:', error);
      _setEmployees(mapMockEmployeesToProfiles(MOCK_EMPLOYEES));
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
        _setRejectedLeaves(data);
      } else {
        console.error("Failed to fetch rejected leaves:", response.statusText);
        _setRejectedLeaves([]);
      }
    } catch (error) {
      console.error('Network error fetching rejected leaves:', error);
      _setRejectedLeaves([]);
    }
  }, []);

  const _fetchWinterPerformance = useCallback(async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/admin/winter-performance`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });
      if (response.ok) {
        const data: PerformanceRecord[] = await response.json();
        alert(`Fetched ${data.length} Winter Performance Records.`);
        console.log("Winter Performance Data:", data);
      } else {
        const error = await response.json();
        alert(`Failed to fetch Winter Performance: ${error.message || response.statusText}`);
      }
    } catch (error) {
      console.error('Network error fetching winter performance:', error);
      alert('A network error occurred while fetching performance data.');
    }
  }, []);

  useEffect(() => {
    if (activeTab === 'employees') fetchAllEmployees();
    if (activeTab === 'attendance') fetchRejectedLeaves();
  }, [activeTab, fetchAllEmployees, fetchRejectedLeaves]);

  const handleSimplePostAction = async (endpoint: string, actionName: string, body?: any) => {
    try {
      const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        method: 'POST',
        headers: getAuthHeaders(),
        ...(body && { body: JSON.stringify(body) }),
      });
      if (response.ok) {
        const result = await response.json();
        handleAction(`${actionName} completed successfully! Message: ${result.message || 'No message.'}`);
      } else {
        const error = await response.json();
        handleAction(`Failed to perform ${actionName}: ${error.message || response.statusText}`);
      }
    } catch (error) {
      handleAction(`A network error occurred during ${actionName}.`);
    }
  };

  const _handleInitiateAttendance = () => handleSimplePostAction('/api/admin/initiate-attendance', 'Daily Attendance Initiation');
  const _handleAddHoliday = () => {
    if (!newHolidayName || !newHolidayDateFrom || !newHolidayDateTo) return alert("Please fill in all holiday details.");
    handleSimplePostAction('/api/admin/add-holiday', `Add Holiday '${newHolidayName}'`, {
      holiday_name: newHolidayName,
      from_Date: newHolidayDateFrom,
      to_Date: newHolidayDateTo,
    });
    setNewHolidayName('');
    setNewHolidayDateFrom('');
    setNewHolidayDateTo('');
  };
  const handleUpdateAttendance = () => {
    if (employeeIdToUpdate === null) return;
    handleSimplePostAction('/api/admin/update-attendance', `Update Attendance for ID ${employeeIdToUpdate}`, {
      check_in_time: newCheckIn,
      check_out_time: newCheckOut,
      Employee_id: employeeIdToUpdate,
    });
    setIsAttendanceModalOpen(false);
    setEmployeeIdToUpdate(null);
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
              <input type="time" value={newCheckIn} onChange={e => setNewCheckIn(e.target.value)} className="w-full px-3 py-2 bg-gray-900 border border-gray-700 rounded-lg text-white" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-1">Check-out Time</label>
              <input type="time" value={newCheckOut} onChange={e => setNewCheckOut(e.target.value)} className="w-full px-3 py-2 bg-gray-900 border border-gray-700 rounded-lg text-white" />
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-6">
            <button onClick={() => setIsAttendanceModalOpen(false)} className="px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white">Cancel</button>
            <button onClick={handleUpdateAttendance} className="px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold">Update Record</button>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6 text-gray-100">
      {renderAttendanceUpdateModal()}
      {/* ...rest of your JSX unchanged... */}
    </div>
  );
};
