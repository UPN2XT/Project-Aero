import React, { useState } from 'react';
import { MOCK_EMPLOYEES } from '../types';

type AdminTab = 'employees' | 'attendance' | 'general';

interface AdminDashboardProps {
  onLogout: () => void;
}

export const AdminDashboard: React.FC<AdminDashboardProps> = ({ onLogout }) => {
  const [activeTab, setActiveTab] = useState<AdminTab>('employees');

  const handleAction = (action: string) => alert(`${action} executed successfully!`);
// hn7ot el api calls hena ya omar do your thing
  const getStatusClass = (status: string) => {
    if (status === 'Active') return 'bg-green-500/20 text-green-300';
    return 'bg-red-500/20 text-red-300';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6">
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
                  <h2 className="text-xl font-bold">Employee Details</h2>
                  <div className="flex gap-2">
                    <input type="text" placeholder="Search ID..." className="bg-gray-900 border border-gray-600 rounded-lg px-3 py-1 text-sm focus:outline-none" />
                  </div>
                </div>
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                        {/* we should fill the table with the sql shit */}
                      <tr className="border-b border-gray-600 text-gray-400 text-sm">
                        <th className="p-3">ID</th>
                        <th className="p-3">Name</th>
                        <th className="p-3">Role</th>
                        <th className="p-3">Department</th>
                        <th className="p-3">Status</th>
                        <th className="p-3">Action</th>
                      </tr>
                    </thead>
                    <tbody className="text-gray-200">
                        {/* hena manipulation 3l4an el data formatting in tables (bro code tutorial) */}
                      {MOCK_EMPLOYEES.map(emp => (
                        <tr key={emp.id} className="border-b border-gray-700/50 hover:bg-gray-700/30 transition">
                          <td className="p-3">{emp.id}</td>
                          <td className="p-3 font-medium">{emp.name}</td>
                          <td className="p-3">{emp.role}</td>
                          <td className="p-3">{emp.dept}</td>
                          <td className="p-3">
                            <span className={`px-2 py-1 rounded text-xs ${getStatusClass(emp.status)}`}>{emp.status}</span>
                          </td>
                          <td className="p-3">
                            <button className="text-cyan-400 hover:text-cyan-200 text-sm">Edit</button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="mt-6 p-4 bg-gray-900/50 rounded-xl border border-gray-600">
                  <h4 className="font-semibold text-gray-300 mb-2">Update Info</h4>
                   <div className="grid grid-cols-2 gap-4">
                {/* This 2 buttons doesn't do anything for now */}
                      <button onClick={() => handleAction('Removed deductions for resigned employees')} className="p-2 bg-gray-800 hover:bg-gray-700 rounded text-sm text-gray-300 border border-gray-600">
                        Remove Resigned Deductions
                      </button>
                      <button onClick={() => handleAction('Daily status updated')} className="p-2 bg-gray-800 hover:bg-gray-700 rounded text-sm text-gray-300 border border-gray-600">
                        Update Employment Status
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
                    <button onClick={() => handleAction('Attendance records initiated')} className="w-full mb-2 bg-cyan-700 hover:bg-cyan-600 text-white py-2 rounded transition">
                      Initiate Today's Records
                    </button>
                    <button onClick={() => handleAction('Updated specific attendance')} className="w-full bg-gray-700 hover:bg-gray-600 text-white py-2 rounded transition">
                      Update Employee Record
                    </button>
                  </div>
                  <div className="p-5 bg-gray-900 rounded-xl border border-gray-600">
                    <h4 className="text-purple-400 font-bold mb-2">Missing & Leaves</h4>
                    <button onClick={() => handleAction('Removed attendance for holidays')} className="w-full mb-2 bg-gray-800 border border-gray-600 hover:bg-gray-700 text-gray-300 py-2 rounded transition">
                      Clear Holiday Attendance
                    </button>
                     <button onClick={() => handleAction('Fetched rejected leaves')} className="w-full bg-gray-800 border border-gray-600 hover:bg-gray-700 text-gray-300 py-2 rounded transition">
                      View Rejected Leaves
                    </button>
                  </div>
                </div>
                <div className="mt-6">
                  <label className="block text-sm text-gray-400 mb-2">Date Range Query</label>
                  <div className="flex gap-2">
                     <input type="date" className="bg-gray-700 border-none rounded p-2 text-white" />
                     <button onClick={() => handleAction('Fetched records')} className="bg-cyan-600 px-4 rounded text-white hover:bg-cyan-500">Fetch</button>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'general' && (
               <div className="space-y-6">
                  <div>
                    <h2 className="text-xl font-bold mb-4">Official Holidays</h2>
                    <div className="flex gap-3 items-end">
                      <div className="flex-1">
                        <label className="text-xs text-gray-400">Holiday Name</label>
                        <input type="text" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" placeholder="e.g. Labor Day" />
                      </div>
                      <div className="flex-1">
                          <label className="text-xs text-gray-400">Date</label>
                          <input type="date" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" />
                      </div>
                      <button onClick={() => handleAction('Holiday Added')} className="bg-green-600 hover:bg-green-500 text-white px-6 py-2 rounded h-10">Add</button>
                    </div>
                  </div>

                  <div className="border-t border-gray-600 pt-6">
                    <h2 className="text-xl font-bold mb-4">Performance Reviews</h2>
                    <button onClick={() => handleAction('Fetched performance details')} className="p-3 bg-gray-700 hover:bg-gray-600 rounded-lg w-full text-left flex justify-between items-center">
                      <span>Fetch All Winter Semesters Performance</span>
                      <span className="material-symbols-outlined text-sm">arrow_forward</span>
                    </button>
                  </div>
               </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};