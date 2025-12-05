import React, { useState, useEffect, useCallback } from 'react';
import { showSuccess } from '../utils/toast';
import type { UserRole } from '../types';

// Types matching the backend HR DTOs
interface ManagedEmployee {
  employeeId: number;
  name: string;
}

interface LeaveApproval {
  requestId: number;
  empId: number;
  type: string;
  dateOfRequest: string;
  status: string;
}

type HRTab = 'employees' | 'approvals' | 'deductions' | 'payroll';

interface HRDashboardProps {
  onLogout: () => void;
  onSwitchRole: (role: UserRole) => void;
}

const API_BASE_URL = ''; // your backend URL

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

export const HRDashboard: React.FC<HRDashboardProps> = ({ onLogout, onSwitchRole }) => {
  const [activeTab, setActiveTab] = useState<HRTab>('employees');
  const [employees, setEmployees] = useState<ManagedEmployee[]>([]);
  const [approvals, setApprovals] = useState<LeaveApproval[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Deduction form state
  const [deductionEmployeeId, setDeductionEmployeeId] = useState<string>('');
  const [deductionType, setDeductionType] = useState<'hours' | 'days' | 'unpaid'>('hours');

  // Payroll form state
  const [payrollEmployeeId, setPayrollEmployeeId] = useState<string>('');
  const [payrollFromDate, setPayrollFromDate] = useState<string>('');
  const [payrollToDate, setPayrollToDate] = useState<string>('');

  const showMessage = (message: string, isError = false) => {
    if (isError) {
      setError(message);
      setTimeout(() => setError(null), 5000);
    } else {
      showSuccess(message);
    }
  };

  const fetchManagedEmployees = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/api/hr/get-managed-employees`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        const data: ManagedEmployee[] = await response.json();
        setEmployees(data);
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        showMessage(`Failed to fetch employees: ${errorData.message || response.statusText}`, true);
      }
    } catch (err) {
      console.error('Network error fetching employees:', err);
      showMessage('Network error. Please check your connection.', true);
    } finally {
      setLoading(false);
    }
  }, [onLogout]);

  const fetchApprovals = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE_URL}/api/hr/approvals/get-all`, {
        method: 'POST',
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        const data: LeaveApproval[] = await response.json();
        setApprovals(data);
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        showMessage(`Failed to fetch approvals: ${errorData.message || response.statusText}`, true);
      }
    } catch (err) {
      console.error('Network error fetching approvals:', err);
      showMessage('Network error. Please check your connection.', true);
    } finally {
      setLoading(false);
    }
  }, [onLogout]);

  useEffect(() => {
    if (activeTab === 'employees') {
      fetchManagedEmployees();
    } else if (activeTab === 'approvals') {
      fetchApprovals();
    }
  }, [activeTab, fetchManagedEmployees, fetchApprovals]);

  const handleApproval = async (requestId: number, type: 'accidental' | 'annual' | 'unpaid' | 'compensation') => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/hr/approvals/${type}`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ request_id: requestId }),
      });

      if (response.ok) {
        showMessage(`Leave request #${requestId} processed successfully!`);
        fetchApprovals(); // Refresh the list
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        showMessage(`Failed to process request: ${errorData.message || response.statusText}`, true);
      }
    } catch (err) {
      console.error('Network error processing approval:', err);
      showMessage('Network error. Please check your connection.', true);
    }
  };

  const handleAddDeduction = async () => {
    if (!deductionEmployeeId) {
      showMessage('Please enter an Employee ID', true);
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/api/hr/deductions/${deductionType}`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ employee_id: parseInt(deductionEmployeeId) }),
      });

      if (response.ok) {
        showMessage(`Deduction (${deductionType}) added successfully for employee #${deductionEmployeeId}!`);
        setDeductionEmployeeId('');
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        showMessage(`Failed to add deduction: ${errorData.message || response.statusText}`, true);
      }
    } catch (err) {
      console.error('Network error adding deduction:', err);
      showMessage('Network error. Please check your connection.', true);
    }
  };

  const handleGeneratePayroll = async () => {
    if (!payrollEmployeeId || !payrollFromDate || !payrollToDate) {
      showMessage('Please fill in all payroll fields', true);
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/api/hr/payrolls/add`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({
          employee_id: parseInt(payrollEmployeeId),
          fromDate: payrollFromDate,
          toDate: payrollToDate,
        }),
      });

      if (response.ok) {
        showMessage(`Payroll generated successfully for employee #${payrollEmployeeId}!`);
        setPayrollEmployeeId('');
        setPayrollFromDate('');
        setPayrollToDate('');
      } else if (response.status === 401) {
        showMessage('Session expired. Please log in again.', true);
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        showMessage(`Failed to generate payroll: ${errorData.message || response.statusText}`, true);
      }
    } catch (err) {
      console.error('Network error generating payroll:', err);
      showMessage('Network error. Please check your connection.', true);
    }
  };

  const renderEmployeesTab = () => (
    <div className="space-y-4">
      <h3 className="text-xl font-bold text-cyan-400">Managed Employees</h3>
      {loading ? (
        <div className="text-center py-8 text-gray-400">Loading...</div>
      ) : employees.length === 0 ? (
        <div className="text-center py-8 text-gray-400">No employees found</div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {employees.map((emp) => (
            <div
              key={emp.employeeId}
              className="bg-gray-800/50 p-4 rounded-xl border border-gray-700 hover:border-cyan-500/50 transition"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-cyan-600 rounded-full flex items-center justify-center text-white font-bold">
                  {emp.name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <p className="font-semibold text-white">{emp.name}</p>
                  <p className="text-sm text-gray-400">ID: {emp.employeeId}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );

  const renderApprovalsTab = () => (
    <div className="space-y-4">
      <h3 className="text-xl font-bold text-cyan-400">Pending Leave Approvals</h3>
      {loading ? (
        <div className="text-center py-8 text-gray-400">Loading...</div>
      ) : approvals.length === 0 ? (
        <div className="text-center py-8 text-gray-400">No pending approvals</div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-left text-gray-400 border-b border-gray-700">
                <th className="pb-3 px-2">Request ID</th>
                <th className="pb-3 px-2">Employee ID</th>
                <th className="pb-3 px-2">Type</th>
                <th className="pb-3 px-2">Date</th>
                <th className="pb-3 px-2">Status</th>
                <th className="pb-3 px-2">Actions</th>
              </tr>
            </thead>
            <tbody>
              {approvals.map((approval) => (
                <tr key={approval.requestId} className="border-b border-gray-800 hover:bg-gray-800/50">
                  <td className="py-3 px-2 text-white">{approval.requestId}</td>
                  <td className="py-3 px-2 text-white">{approval.empId}</td>
                  <td className="py-3 px-2 text-cyan-300">{approval.type}</td>
                  <td className="py-3 px-2 text-gray-300">{approval.dateOfRequest}</td>
                  <td className="py-3 px-2">
                    <span className={`px-2 py-1 rounded-full text-xs ${approval.status === 'Pending' ? 'bg-yellow-500/20 text-yellow-300' :
                      approval.status === 'Approved' ? 'bg-green-500/20 text-green-300' :
                        'bg-red-500/20 text-red-300'
                      }`}>
                      {approval.status}
                    </span>
                  </td>
                  <td className="py-3 px-2">
                    <div className="flex gap-2">
                      {approval.type.toLowerCase().includes('annual') && (
                        <button
                          onClick={() => handleApproval(approval.requestId, 'annual')}
                          className="px-3 py-1 bg-green-600 hover:bg-green-500 rounded text-xs text-white"
                        >
                          Process
                        </button>
                      )}
                      {approval.type.toLowerCase().includes('accidental') && (
                        <button
                          onClick={() => handleApproval(approval.requestId, 'accidental')}
                          className="px-3 py-1 bg-green-600 hover:bg-green-500 rounded text-xs text-white"
                        >
                          Process
                        </button>
                      )}
                      {approval.type.toLowerCase().includes('unpaid') && (
                        <button
                          onClick={() => handleApproval(approval.requestId, 'unpaid')}
                          className="px-3 py-1 bg-green-600 hover:bg-green-500 rounded text-xs text-white"
                        >
                          Process
                        </button>
                      )}
                      {approval.type.toLowerCase().includes('compensation') && (
                        <button
                          onClick={() => handleApproval(approval.requestId, 'compensation')}
                          className="px-3 py-1 bg-green-600 hover:bg-green-500 rounded text-xs text-white"
                        >
                          Process
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );

  const renderDeductionsTab = () => (
    <div className="space-y-6">
      <h3 className="text-xl font-bold text-cyan-400">Add Employee Deduction</h3>
      <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700 max-w-md">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Employee ID</label>
            <input
              type="number"
              value={deductionEmployeeId}
              onChange={(e) => setDeductionEmployeeId(e.target.value)}
              className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              placeholder="Enter employee ID"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Deduction Type</label>
            <select
              value={deductionType}
              onChange={(e) => setDeductionType(e.target.value as 'hours' | 'days' | 'unpaid')}
              className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
            >
              <option value="hours">Missing Hours</option>
              <option value="days">Missing Days</option>
              <option value="unpaid">Unpaid Leave</option>
            </select>
          </div>
          <button
            onClick={handleAddDeduction}
            className="w-full px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold transition"
          >
            Add Deduction
          </button>
        </div>
      </div>
    </div>
  );

  const renderPayrollTab = () => (
    <div className="space-y-6">
      <h3 className="text-xl font-bold text-cyan-400">Generate Monthly Payroll</h3>
      <div className="bg-gray-800/50 p-6 rounded-xl border border-gray-700 max-w-md">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Employee ID</label>
            <input
              type="number"
              value={payrollEmployeeId}
              onChange={(e) => setPayrollEmployeeId(e.target.value)}
              className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
              placeholder="Enter employee ID"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">From Date</label>
            <input
              type="date"
              value={payrollFromDate}
              onChange={(e) => setPayrollFromDate(e.target.value)}
              className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">To Date</label>
            <input
              type="date"
              value={payrollToDate}
              onChange={(e) => setPayrollToDate(e.target.value)}
              className="w-full px-4 py-2 bg-gray-900 border border-gray-600 rounded-lg text-white focus:border-cyan-500 focus:outline-none"
            />
          </div>
          <button
            onClick={handleGeneratePayroll}
            className="w-full px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold transition"
          >
            Generate Payroll
          </button>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6 text-gray-100">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">
          <span className="text-cyan-400">HR</span> Dashboard
        </h1>
        <div className="flex items-center gap-3">
          <button
            onClick={() => {
              localStorage.setItem('userRole', 'Academic');
              onSwitchRole('Academic');
            }}
            className="px-4 py-2 bg-cyan-600 hover:bg-cyan-500 rounded-lg text-white font-semibold transition flex items-center gap-2"
          >
            <span>🎓</span> Switch to Academic Portal
          </button>
          <button
            onClick={onLogout}
            className="px-4 py-2 bg-red-600 hover:bg-red-500 rounded-lg text-white font-semibold transition"
          >
            Logout
          </button>
        </div>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="mb-6 p-4 bg-red-500/20 border border-red-500 rounded-lg text-red-300">
          {error}
        </div>
      )}

      {/* Tabs */}
      <div className="flex gap-2 mb-8 flex-wrap">
        {(['employees', 'approvals', 'deductions', 'payroll'] as HRTab[]).map((tab) => (
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
        {activeTab === 'approvals' && renderApprovalsTab()}
        {activeTab === 'deductions' && renderDeductionsTab()}
        {activeTab === 'payroll' && renderPayrollTab()}
      </div>
    </div>
  );
};
