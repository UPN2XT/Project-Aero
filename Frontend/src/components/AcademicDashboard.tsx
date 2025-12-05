import React, { useState, useEffect } from 'react';
import { MOCK_LEAVES } from '../types';
import { authenticatedFetch } from '../api/apiService'; 

type AcademicView = 'leaves' | 'info' | 'dean';

interface AcademicDashboardProps {
  onLogout: () => void;
}

const USER_ID = Number(localStorage.getItem('userId')) || 1; 
const CURRENT_SEMESTER = 'W26';

export const AcademicDashboard: React.FC<AcademicDashboardProps> = ({ onLogout }) => {
  const [view, setView] = useState<AcademicView>('leaves');
  const [replacementIdInput, setReplacementIdInput] = useState('');
  const [selectedLeaveType, setSelectedLeaveType] = useState('Annual Leave');
  
  const [leaveStatus, setLeaveStatus] = useState<any[]>([]);
  const [performance, setPerformance] = useState<any>({});
  const [attendance, setAttendance] = useState<any[]>([]);
  const [deductions, setDeductions] = useState<any[]>([]);
  
  const handleFetch = async (endpoint: string, payload?: any) => {
    try {
      const response = await authenticatedFetch(endpoint, {
        method: 'POST',
        body: payload ? JSON.stringify(payload) : undefined,
      });

      if (!response.ok) {
        const errorData = await response.json();
        alert(`Request to ${endpoint} failed with status: ${response.status}. Message: ${errorData.message || 'Server Validation Failed'}`);
        return null;
      }
      
      const contentType = response.headers.get('content-type');
      if (response.status === 200 && (!contentType || !contentType.includes('application/json'))) {
          return { success: true }; 
      }
      
      const data = await response.json();
      return data;
      
    } catch (error) {
      alert(`Network error for ${endpoint}.`);
      return null;
    }
  };


  const handleApply = async (e: React.FormEvent) => {
    e.preventDefault();
    const form = e.currentTarget;
    const leaveType = selectedLeaveType;
    const startDate = (form.querySelector('input[name="startDate"]') as HTMLInputElement)?.value;
    const endDate = (form.querySelector('input[name="endDate"]') as HTMLInputElement)?.value;
    const replacementId = replacementIdInput;

    let endpoint = '';
    const payload: any = { start: startDate, end: endDate };

    const requiresReplacement = leaveType.includes('Annual') || leaveType.includes('Compensation');
    if (requiresReplacement && (!replacementId || Number(replacementId) <= 0)) {
        alert(`${leaveType} requires a valid Replacement Employee ID (positive integer).`);
        return;
    }

    if (leaveType.includes('Annual')) {
        endpoint = '/employee/submit/annual';
        payload.replacementID = Number(replacementId);
    } else if (leaveType.includes('Accidental')) {
        endpoint = '/employee/submit/accidental';
        payload.empId = USER_ID;
    } else if (leaveType.includes('Medical')) {
        endpoint = '/employee/submit/medical';
        payload.type = 'sick';
        payload.insurancestatus = 1;
        payload.document = 'base64_placeholder';
        payload.fileName = 'medical_doc.pdf';
    } else if (leaveType.includes('Unpaid')) {
        endpoint = '/employee/submit/unpaid';
        payload.document = 'base64_placeholder';
        payload.filename = 'unpaid_reason.pdf';
    } else if (leaveType.includes('Compensation')) {
        endpoint = '/employee/submit/compensation';
        payload.compdate = startDate;
        payload.reason = 'Extra hours worked';
        payload.orgianlday = endDate;
        payload.replacementId = Number(replacementId);
        delete payload.start;
        delete payload.end;
    }
    
    if (endpoint) {
        const result = await handleFetch(endpoint, payload);
        if (result) {
             alert(`${leaveType} application submitted for approval.`);
             
             // FIX: Add delay to allow database to synchronize submission
             await new Promise(resolve => setTimeout(resolve, 500)); 
             
             fetchLeavesStatus();
             setReplacementIdInput('');
        }
    }
  };

  const fetchLeavesStatus = async () => {
    const data = await handleFetch('/employee/status-leaves', { employee_ID: USER_ID });
    if (data) setLeaveStatus(data);
  };

  const fetchPendingApprovals = async () => {
    const managedData = await handleFetch('/employee/get-managed-employees', {});
    
    setLeaveStatus(MOCK_LEAVES.filter(l => l.status === 'Pending'));
  };

  const fetchInfoData = async () => {
    const perfData = await handleFetch('/employee/my-performance', { sem: CURRENT_SEMESTER });
    if (perfData && perfData.length > 0) setPerformance(perfData[0]);

    const dedData = await handleFetch('/employee/deduction-attendance', { month: new Date().getMonth() + 1 });
    if (dedData) setDeductions(dedData);
    
    const attendanceData = await handleFetch('/employee/my-attendance', {});
    if (attendanceData) setAttendance(attendanceData);
    
    await handleFetch('/employee/last-month-payroll', {});
  };
  
  const handleDeanApproval = async (requestID: number, leaveType: string, action: 'Approve' | 'Reject') => {
    let endpoint = '';
    if (leaveType.includes('Annual')) {
        endpoint = '/employee/upperboard/approve/annual';
    } else if (leaveType.includes('Unpaid')) {
        endpoint = '/employee/upperboard/approve/unpaid';
    } else {
        alert(`Approval for ${leaveType} is not supported by a direct Upper Board endpoint.`);
        return;
    }

    if (action === 'Approve') {
        const payload = { 
            requestId: requestID, 
            replacmentId: 0,
        };
        const result = await handleFetch(endpoint, payload);
        if(result) alert(`SUCCESS: Approved Request ID ${requestID}.`);
    } else {
        alert(`Simulating REJECT for Request ID ${requestID}.`);
    }
  };

  useEffect(() => {
    if (view === 'leaves') {
      fetchLeavesStatus();
    } else if (view === 'info') {
      fetchInfoData();
    } else if (view === 'dean') {
      fetchPendingApprovals();
    }
  }, [view]);

  const performanceScore = performance?.rating ? (performance.rating >= 4 ? 'A-' : 'B+') : 'N/A';
  const totalDeductionAmount = deductions.reduce((sum: number, d: any) => sum + d.amount, 0);


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

        <div className="flex gap-4 mb-6 border-b border-gray-700 pb-2">
           <button onClick={() => setView('leaves')} className={`pb-2 px-1 ${view === 'leaves' ? 'text-cyan-400 border-b-2 border-cyan-400' : 'text-gray-400 hover:text-white'}`}>Leaves & Requests</button>
           <button onClick={() => setView('info')} className={`pb-2 px-1 ${view === 'info' ? 'text-cyan-400 border-b-2 border-cyan-400' : 'text-gray-400 hover:text-white'}`}>My Performance & Data</button>
           <button onClick={() => setView('dean')} className={`pb-2 px-1 ${view === 'dean' ? 'text-cyan-400 border-b-2 border-cyan-400' : 'text-gray-400 hover:text-white'}`}>Dean Controls</button>
        </div>

        <div className="bg-gray-800/80 p-8 rounded-2xl border border-gray-700">
           {view === 'leaves' && (
             <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
               <div>
                 <h3 className="text-xl font-bold mb-4 text-white">Apply for Leave</h3>
                 <form onSubmit={handleApply} className="space-y-4">
                   <div>
                     <label className="text-sm text-gray-400">Type</label>
                     <select 
                        name="leaveType" 
                        value={selectedLeaveType}
                        onChange={(e) => setSelectedLeaveType(e.target.value)}
                        className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1"
                     >
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
                          <input type="date" name="startDate" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                      </div>
                      <div>
                          <label className="text-sm text-gray-400">End Date</label>
                          <input type="date" name="endDate" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                      </div>
                   </div>
                   
                   {(selectedLeaveType.includes('Annual') || selectedLeaveType.includes('Compensation')) && (
                       <div>
                           <label className="text-sm text-gray-400">Replacement Employee ID</label>
                           <input 
                              type="number" 
                              name="replacementId"
                              value={replacementIdInput}
                              onChange={(e) => setReplacementIdInput(e.target.value)}
                              placeholder="e.g., 101"
                              className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" 
                              required={selectedLeaveType.includes('Annual')}
                            />
                       </div>
                   )}
                   
                   <button type="submit" className="w-full bg-cyan-700 hover:bg-cyan-600 text-white py-2 rounded font-semibold shadow-lg">Submit Request</button>
                 </form>
               </div>

               <div>
                   <h3 className="text-xl font-bold mb-4 text-white">My Requests Status</h3>
                   <div className="space-y-3">
                      {leaveStatus.map((l: any) => {
                          const statusClass = l.status === 'Approved' ? 'bg-green-500/20 text-green-300' : l.status === 'Rejected' ? 'bg-red-500/20 text-red-300' : 'bg-yellow-500/20 text-yellow-300';
                          return (
                          <div key={l.id} className="bg-gray-900/50 p-3 rounded-lg border border-gray-700 flex justify-between items-center">
                              <div>
                                  <p className="text-sm font-bold text-gray-200">{l.type}</p>
                                  <p className="text-xs text-gray-500">{l.start_date} - {l.end_date || l.dateOfRequest}</p>
                              </div>
                              <span className={`text-xs px-2 py-1 rounded ${statusClass}`}>{l.status}</span>
                          </div>
                          );
                      })}
                   </div>
               </div>
             </div>
           )}

           {view === 'info' && (
             <div className="space-y-6">
                 <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                     <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                        <p className="text-gray-400 text-sm">Last Month Payroll</p>
                        <p className="text-2xl font-bold text-white mt-1">Deducted: {totalDeductionAmount}</p>
                     </div>
                     <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                        <p className="text-gray-400 text-sm">Deduction Issues</p>
                        <p className="text-2xl font-bold text-red-400 mt-1">{deductions.length} Total</p>
                     </div>
                     <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                        <p className="text-gray-400 text-sm">Performance Score ({CURRENT_SEMESTER})</p>
                        <p className="text-2xl font-bold text-cyan-400 mt-1">{performanceScore}</p>
                     </div>
                   </div>
                   
                   <div>
                       <h4 className="font-bold mb-2 text-gray-300">Detailed Attendance (Current Month)</h4>
                       <div className="h-32 bg-gray-900 rounded-lg flex flex-col justify-start border border-gray-700 text-gray-300 p-3 overflow-y-auto">
                            {attendance && attendance.length > 0 ? (
                                attendance.map((a: any, index: number) => (
                                    <p key={index} className="text-xs">{a.date}: Check-in at {a.checkInTime} / Check-out at {a.checkOutTime}</p>
                                ))
                            ) : (
                                <p className="text-gray-500 italic text-center w-full">No attendance records found for this month.</p>
                            )}
                       </div>
                   </div>
             </div>
           )}

           {view === 'dean' && (
             <div>
               <div className="mb-4 p-4 bg-yellow-900/20 border border-yellow-700/50 rounded-lg">
                 <p className="text-yellow-200 text-sm flex items-center gap-2"><span className="material-symbols-outlined text-sm">lock</span> Authorized Access Only (Dean/President)</p>
               </div>
               <div className="space-y-4">
                 <h3 className="font-bold text-lg">Pending Approvals</h3>
                 {leaveStatus.filter(l => l.status === 'Pending').map(l => (
                   <div key={l.id} className="flex justify-between items-center bg-gray-900 p-4 rounded-lg border border-gray-600">
                     <div>
                       <p className="font-bold">{l.emp}</p>
                       <p className="text-xs text-gray-400">{l.type}</p>
                     </div>
                     <div className="flex gap-2">
                       <button onClick={() => handleDeanApproval(l.id, l.type, 'Approve')} className="text-xs bg-green-600 hover:bg-green-500 text-white px-3 py-1 rounded">Approve</button>
                       <button onClick={() => handleDeanApproval(l.id, l.type, 'Reject')} className="text-xs bg-red-600 hover:bg-red-500 text-white px-3 py-1 rounded">Reject</button>
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