import React, { useState } from 'react';
import { MOCK_LEAVES } from '../types';

type AcademicView = 'leaves' | 'info' | 'dean';

interface AcademicDashboardProps {
  onLogout: () => void;
}

export const AcademicDashboard: React.FC<AcademicDashboardProps> = ({ onLogout }) => {
  const [view, setView] = useState<AcademicView>('leaves');

  const handleApply = (e: React.FormEvent) => {
    e.preventDefault();
    alert("Leave application submitted for approval.");
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6">
      <div className="max-w-5xl mx-auto">
        <div className="flex justify-between items-center mb-8 bg-gray-800/50 p-4 rounded-2xl border border-gray-700 backdrop-blur-md">
          <h1 className="text-2xl font-bold text-white"><span className="text-cyan-400">Academic</span> Portal</h1>
           <div className="flex items-center gap-4">
             <span className="text-sm text-gray-400">Welcome, Dr. Youssef el gamd</span>
             <button onClick={onLogout} className="text-sm bg-red-500/20 text-red-400 px-4 py-2 rounded-lg hover:bg-red-500/30 transition">Logout</button>
           </div>
        </div>

        {/* here we r doing the menu categories lol */}
        <div className="flex gap-4 mb-6 border-b border-gray-700 pb-2">
           <button onClick={() => setView('leaves')} className={`pb-2 px-1 ${view === 'leaves' ? 'text-cyan-400 border-b-2 border-cyan-400' : 'text-gray-400 hover:text-white'}`}>Leaves & Requests</button>
           <button onClick={() => setView('info')} className={`pb-2 px-1 ${view === 'info' ? 'text-cyan-400 border-b-2 border-cyan-400' : 'text-gray-400 hover:text-white'}`}>My Performance & Data</button>
           <button onClick={() => setView('dean')} className={`pb-2 px-1 ${view === 'dean' ? 'text-cyan-400 border-b-2 border-cyan-400' : 'text-gray-400 hover:text-white'}`}>Dean Controls</button>
        </div>

        <div className="bg-gray-800/80 p-8 rounded-2xl border border-gray-700">
           {view === 'leaves' && (
             <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
               <div>
                 <h3 className="text-xl font-bold mb-4 text-white">Apply for Leve</h3>
                 <form onSubmit={handleApply} className="space-y-4">
                   <div>
                     <label className="text-sm text-gray-400">Type</label>
                     <select className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1">
                       <option>Annual Leave</option>
                       <option>Accidental Leave</option>
                       <option>Medical Leave</option>
                       <option>Unpaid Leave</option>
                       <option>Compensation Leave</option>
                     </select>
                   </div>
                   <div className="grid grid-cols-2 gap-2">
                      <div>
                          <label className="text-sm text-gray-400">Start Date</label>
                          <input type="date" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                      </div>
                      <div>
                          <label className="text-sm text-gray-400">End Date</label>
                          <input type="date" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                      </div>
                   </div>
                   <button className="w-full bg-cyan-700 hover:bg-cyan-600 text-white py-2 rounded font-semibold shadow-lg">Submit Request</button>
                 </form>
               </div>

               <div>
                {/* TODO Will be fetched from the sql later dont worry abt it */}
                   <h3 className="text-xl font-bold mb-4 text-white">My Requests Status</h3>
                   <div className="space-y-3">
                      <div className="bg-gray-900/50 p-3 rounded-lg border border-gray-700 flex justify-between items-center">
                          <div>
                              <p className="text-sm font-bold text-gray-200">Annual Leave</p>
                              <p className="text-xs text-gray-500">Oct 12 - Oct 15</p>
                          </div>
                          <span className="text-xs bg-yellow-500/20 text-yellow-300 px-2 py-1 rounded">Pending</span>
                      </div>
                      <div className="bg-gray-900/50 p-3 rounded-lg border border-gray-700 flex justify-between items-center">
                          <div>
                              <p className="text-sm font-bold text-gray-200">Medical Leave</p>
                              <p className="text-xs text-gray-500">Sep 01 - Sep 05</p>
                          </div>
                          <span className="text-xs bg-green-500/20 text-green-300 px-2 py-1 rounded">Approved</span>
                      </div>
                   </div>
               </div>
             </div>
           )}

           {view === 'info' && (
             <div className="space-y-6">
                 <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                     <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                      {/* TODO maybe will open another page later */}
                        <p className="text-gray-400 text-sm">Current Month Payroll</p>
                        <p className="text-2xl font-bold text-white mt-1">Details &rarr;</p>
                     </div>
                     <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                        <p className="text-gray-400 text-sm">Attendance Issues</p>
                        <p className="text-2xl font-bold text-red-400 mt-1">2 Missing</p>
                     </div>
                     <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                      {/* TODO will remove later, m4 m7tgenha f el milestone */}
                        <p className="text-gray-400 text-sm">Performance Score</p>
                        <p className="text-2xl font-bold text-cyan-400 mt-1">A-</p>
                     </div>
                   </div>
                   
                   <div>
                    {/* TODO fetch api */}
                       <h4 className="font-bold mb-2 text-gray-300">Detailed Attendance (Current Month)</h4>
                       <div className="h-32 bg-gray-900 rounded-lg flex items-center justify-center border border-gray-700 text-gray-500 italic">
                          Table of dates and check-in times...
                       </div>
                   </div>
             </div>
           )}

           {view === 'dean' && (
            // TODO lock this for the dean only somehow
             <div>
               <div className="mb-4 p-4 bg-yellow-900/20 border border-yellow-700/50 rounded-lg">
                 <p className="text-yellow-200 text-sm flex items-center gap-2"><span className="material-symbols-outlined text-sm">lock</span> Authorized Access Only (Dean/President)</p>
               </div>
               <div className="space-y-4">
                 <h3 className="font-bold text-lg">Pending Approvals</h3>
                 {MOCK_LEAVES.map(l => (
                   <div key={l.id} className="flex justify-between items-center bg-gray-900 p-4 rounded-lg border border-gray-600">
                     <div>
                       <p className="font-bold">{l.emp}</p>
                       <p className="text-xs text-gray-400">{l.type}</p>
                     </div>
                     <div className="flex gap-2">
                       <button onClick={() => alert('Approved')} className="text-xs bg-green-600 hover:bg-green-500 text-white px-3 py-1 rounded">Approve</button>
                       <button onClick={() => alert('Rejected')} className="text-xs bg-red-600 hover:bg-red-500 text-white px-3 py-1 rounded">Reject</button>
                     </div>
                   </div>
                 ))}
               </div>
             </div>
           )}
        </div>
      </div>
    </div>
  );
};