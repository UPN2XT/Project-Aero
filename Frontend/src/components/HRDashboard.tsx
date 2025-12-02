import React from 'react';

interface HRDashboardProps {
  onLogout: () => void;
}

export const HRDashboard: React.FC<HRDashboardProps> = ({ onLogout }) => {
  const handlePayroll = () => {
    // TODO how tf will we generate a payroll? excel file? pdf?
    alert("Monthly payroll generated successfully.");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8 bg-gray-800/50 p-4 rounded-2xl border border-gray-700 backdrop-blur-md">
          <h1 className="text-2xl font-bold text-white"><span className="text-cyan-400">HR</span> Management</h1>
          <button onClick={onLogout} className="text-sm bg-red-500/20 text-red-400 px-4 py-2 rounded-lg hover:bg-red-500/30 transition">Logout</button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-6">
            <div className="bg-gray-800/80 p-6 rounded-2xl border border-gray-700">
              <h3 className="text-xl font-bold mb-4 flex items-center gap-2">
                {/* TODO */}
                <span className="material-symbols-outlined text-cyan-400">7ot icon 3dla hena</span> 
                Leave Requests
              </h3>
              <div className="overflow-hidden rounded-xl border border-gray-700">
                <table className="w-full text-left bg-gray-900">
                  <thead className="bg-gray-800 text-gray-400 text-xs uppercase">
                    <tr>
                      <th className="p-3">Employee</th>
                      <th className="p-3">Type</th>
                      <th className="p-3">Status</th>
                      <th className="p-3 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="text-sm">
                    <tr className="border-b border-gray-700">
                      <td className="p-3">Omar Ali</td>
                      <td className="p-3">Annual</td>
                      <td className="p-3 text-yellow-400">Pending</td>
                      <td className="p-3 text-right space-x-2">
                        <button onClick={() => alert('Approved')} className="text-green-400 hover:text-green-300 font-bold">✓</button>
                        <button onClick={() => alert('Rejected')} className="text-red-400 hover:text-red-300 font-bold">✕</button>
                      </td>
                    </tr>
                    <tr className="border-b border-gray-700">
                      <td className="p-3">Youssef Tamer</td>
                      <td className="p-3">Compensation</td>
                      <td className="p-3 text-yellow-400">Pending</td>
                      <td className="p-3 text-right space-x-2">
                        <button onClick={() => alert('Approved')} className="text-green-400 hover:text-green-300 font-bold">✓</button>
                        <button onClick={() => alert('Rejected')} className="text-red-400 hover:text-red-300 font-bold">✕</button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <div className="bg-gray-800/80 p-6 rounded-2xl border border-gray-700">
              <h3 className="text-xl font-bold mb-4 text-red-400 flex items-center gap-2">
                {/* TODO */}
                <span className="material-symbols-outlined">(7ot icon 3dla hena)</span> 
                Deductions
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-gray-900 p-4 rounded-xl border border-gray-600">
                  <p className="text-sm text-gray-400 mb-2">Missing Hours</p>
                  <input type="text" placeholder="Emp ID" className="w-full bg-gray-800 border border-gray-700 rounded p-1 mb-2 text-sm" />
                  <button onClick={() => alert('Deduction Added')} className="w-full bg-red-900/40 text-red-300 border border-red-900 hover:bg-red-900/60 text-xs py-2 rounded">Apply</button>
                </div>
                <div className="bg-gray-900 p-4 rounded-xl border border-gray-600">
                  <p className="text-sm text-gray-400 mb-2">Missing Days</p>
                  <input type="text" placeholder="Emp ID" className="w-full bg-gray-800 border border-gray-700 rounded p-1 mb-2 text-sm" />
                  <button onClick={() => alert('Deduction Added')} className="w-full bg-red-900/40 text-red-300 border border-red-900 hover:bg-red-900/60 text-xs py-2 rounded">Apply</button>
                </div>
                <div className="bg-gray-900 p-4 rounded-xl border border-gray-600">
                  <p className="text-sm text-gray-400 mb-2">Unpaid Leave</p>
                  <input type="text" placeholder="Emp ID" className="w-full bg-gray-800 border border-gray-700 rounded p-1 mb-2 text-sm" />
                  <button onClick={() => alert('Deduction Added')} className="w-full bg-red-900/40 text-red-300 border border-red-900 hover:bg-red-900/60 text-xs py-2 rounded">Apply</button>
                </div>
              </div>
            </div>
          </div>

          <div className="lg:col-span-1">
            <div className="bg-gradient-to-b from-cyan-900 to-gray-900 p-6 rounded-2xl border border-cyan-700 shadow-lg text-center h-full flex flex-col justify-center">
              <span className="material-symbols-outlined text-6xl text-cyan-400 mb-4">payments</span>
              <h3 className="text-2xl font-bold text-white mb-2">Payroll System</h3>
              <p className="text-gray-300 mb-8 text-sm">Generate monthly payrolls for all employees. m4 3arf ezay lesa</p>
              <button onClick={handlePayroll} className="w-full bg-cyan-500 hover:bg-cyan-400 text-black font-bold py-3 rounded-xl shadow-cyan-500/50 shadow-lg transition transform hover:-translate-y-1">
                Generate Payroll
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};