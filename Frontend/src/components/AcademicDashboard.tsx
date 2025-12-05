// AcademicDashboard.tsx
import React, { useState, useEffect } from "react";
import { authenticatedFetch } from "../api/apiService";
import { MOCK_LEAVES } from "../types";

type AcademicView = "leaves" | "info" | "dean";

interface AcademicDashboardProps {
  onLogout: () => void;
}

const USER_ID = Number(localStorage.getItem("userId")) || 1;
const CURRENT_SEMESTER = "W26";

export const AcademicDashboard: React.FC<AcademicDashboardProps> = ({ onLogout }) => {
  // === UI View State ===
  const [view, setView] = useState<AcademicView>("leaves");
  const [loading, setLoading] = useState(false);

  // === Form State ===
  const [selectedLeaveType, setSelectedLeaveType] = useState("Annual Leave");
  const [replacementIdInput, setReplacementIdInput] = useState("");
  
  // File Upload State
  const [uploadedFile, setUploadedFile] = useState<string | null>(null);
  const [uploadedFileName, setUploadedFileName] = useState("");

  // === Data State ===
  const [leaveStatus, setLeaveStatus] = useState<any[]>([]);
  const [performance, setPerformance] = useState<any>({});
  const [attendance, setAttendance] = useState<any[]>([]);
  const [deductions, setDeductions] = useState<any[]>([]);

  // === API Helper ===
  const handleFetch = async (endpoint: string, payload?: any) => {
    try {
      setLoading(true);
      const response = await authenticatedFetch(endpoint, {
        method: "POST",
        body: payload ? JSON.stringify(payload) : undefined,
      });

      setLoading(false);

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        alert(
          `Error (${response.status}): ${errorData.message || "Request failed"}`
        );
        return null;
      }

      const contentType = response.headers.get("content-type");
      if (!contentType || !contentType.includes("application/json")) return { success: true };

      return await response.json();
    } catch (error) {
      setLoading(false);
      alert(`Network error for ${endpoint}.`);
      return null;
    }
  };

  // === File Upload Handler ===
  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadedFileName(file.name);

    const reader = new FileReader();
    reader.onload = () => {
      setUploadedFile(reader.result as string); // Store Base64 string
    };
    reader.readAsDataURL(file);
  };

  // === Form Submission Handler ===
  const handleApply = async (e: React.FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget as HTMLFormElement);
    
    // Extract common fields
    const startDate = formData.get("startDate") as string;
    const endDate = formData.get("endDate") as string;
    
    let endpoint = "";
    let payload: any = {};

    // --- Logic based on Leave Type ---
    switch (selectedLeaveType) {
      case "Annual Leave":
        if (!replacementIdInput) return alert("Replacement ID is required.");
        endpoint = "/employee/submit/annual";
        payload = { 
          start: startDate, 
          end: endDate, 
          replacementID: Number(replacementIdInput) 
        };
        break;

      case "Accidental Leave":
        endpoint = "/employee/submit/accidental";
        payload = { 
          start: startDate, 
          end: endDate, 
          empId: USER_ID 
        };
        break;

      case "Medical Leave":
        if (!uploadedFile) return alert("Medical document is required.");
        endpoint = "/employee/submit/medical";
        payload = {
          start: startDate,
          end: endDate,
          type: "sick",
          insurancestatus: Number(formData.get("insurancestatus") || 0),
          disability: formData.get("disability") || "",
          document: uploadedFile, // Base64
          fileName: uploadedFileName
        };
        break;

      case "Unpaid Leave":
        if (!uploadedFile) return alert("Reason document is required.");
        endpoint = "/employee/submit/unpaid";
        payload = {
          start: startDate,
          end: endDate,
          document: uploadedFile, // Base64
          filename: uploadedFileName
        };
        break;

      case "Compensation Leave":
        if (!replacementIdInput) return alert("Replacement ID is required.");
        endpoint = "/employee/submit/compensation";
        payload = {
          compdate: formData.get("compdate"),
          orgianlday: formData.get("orgianlday"),
          reason: formData.get("reason"),
          replacementId: Number(replacementIdInput)
        };
        break;

      default:
        return;
    }

    // --- Submit ---
    if (endpoint) {
      const result = await handleFetch(endpoint, payload);
      if (result) {
        alert(`${selectedLeaveType} submitted successfully.`);
        // Reset form states
        setReplacementIdInput("");
        setUploadedFile(null);
        setUploadedFileName("");
        // Refresh list
        fetchLeavesStatus();
      }
    }
  };

  // === Data Fetching Functions ===
  const fetchLeavesStatus = async () => {
    const data = await handleFetch("/employee/status-leaves", { employee_ID: USER_ID });
    if (data) setLeaveStatus(data);
  };

  const fetchPendingApprovals = async () => {
    setLeaveStatus(MOCK_LEAVES.filter((l) => l.status === "Pending"));
  };

  const fetchInfoData = async () => {
    const perfData = await handleFetch("/employee/my-performance", { sem: CURRENT_SEMESTER });
    if (perfData && perfData.length > 0) setPerformance(perfData[0]);

    const dedData = await handleFetch("/employee/deduction-attendance", { month: new Date().getMonth() + 1 });
    if (dedData) setDeductions(dedData);

    const attendanceData = await handleFetch("/employee/my-attendance", {});
    if (attendanceData) setAttendance(attendanceData);
  };

  const handleDeanApproval = async (requestID: number, leaveType: string, action: "Approve" | "Reject") => {
    let endpoint = "";
    if (leaveType.includes("Annual")) endpoint = "/employee/upperboard/approve/annual";
    else if (leaveType.includes("Unpaid")) endpoint = "/employee/upperboard/approve/unpaid";
    else return alert(`Approval unsupported for ${leaveType}.`);

    if (action === "Approve") {
      const result = await handleFetch(endpoint, { requestId: requestID, replacmentId: 0 });
      if (result) {
        alert(`Approved Request ${requestID}.`);
        fetchPendingApprovals();
      }
    } else {
      alert(`Rejected Request ${requestID}.`);
    }
  };

  // === Effects ===
  useEffect(() => {
    if (view === "leaves") fetchLeavesStatus();
    else if (view === "info") fetchInfoData();
    else if (view === "dean") fetchPendingApprovals();
  }, [view]);

  // === Render Helpers ===
  const performanceScore = performance?.rating ? (performance.rating >= 4 ? "A-" : "B+") : "N/A";
  const totalDeductionAmount = deductions.reduce((sum: number, d: any) => sum + (d.amount || 0), 0);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-8 bg-gray-800/50 p-4 rounded-2xl border border-gray-700 backdrop-blur-md">
          <h1 className="text-2xl font-bold text-white">
            <span className="text-cyan-400">Academic</span> Portal
          </h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-400">Welcome, Dr. Youssef</span>
            <button
              onClick={onLogout}
              className="text-sm bg-red-500/20 text-red-400 px-4 py-2 rounded-lg hover:bg-red-500/30 transition"
            >
              Logout
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-4 mb-6 border-b border-gray-700 pb-2">
          {['leaves', 'info', 'dean'].map((tab) => (
            <button
              key={tab}
              onClick={() => setView(tab as AcademicView)}
              className={`pb-2 px-1 capitalize ${
                view === tab 
                ? "text-cyan-400 border-b-2 border-cyan-400" 
                : "text-gray-400 hover:text-white"
              }`}
            >
              {tab === 'leaves' ? 'Leaves & Requests' : tab === 'info' ? 'My Performance' : 'Dean Controls'}
            </button>
          ))}
        </div>

        {/* Content Area */}
        <div className="bg-gray-800/80 p-8 rounded-2xl border border-gray-700">
          {loading && <div className="mb-4 text-sm text-cyan-400 animate-pulse">Processing Request...</div>}

          {/* ===== VIEW: LEAVES ===== */}
          {view === "leaves" && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {/* Left Column: Form */}
              <div>
                <h3 className="text-xl font-bold mb-4 text-white">Apply for Leave</h3>
                <form onSubmit={handleApply} className="space-y-4">
                  
                  {/* Leave Type Selector */}
                  <div>
                    <label className="text-sm text-gray-400">Type</label>
                    <select
                      value={selectedLeaveType}
                      onChange={(e) => {
                        setSelectedLeaveType(e.target.value);
                        setUploadedFile(null); // Reset file on type change
                        setUploadedFileName("");
                      }}
                      className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1 focus:border-cyan-500 outline-none"
                    >
                      <option>Annual Leave</option>
                      <option>Accidental Leave</option>
                      <option>Medical Leave</option>
                      <option>Unpaid Leave</option>
                      <option>Compensation Leave</option>
                    </select>
                  </div>

                  {/* ===== Annual Leave ===== */}
                  {selectedLeaveType === "Annual Leave" && (
                    <>
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
                      <div>
                        <label className="text-sm text-gray-400">Replacement Employee ID</label>
                        <input
                          type="number"
                          value={replacementIdInput}
                          onChange={(e) => setReplacementIdInput(e.target.value)}
                          className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1"
                          placeholder="e.g., 101"
                          required
                        />
                      </div>
                    </>
                  )}

                  {/* ===== Accidental Leave ===== */}
                  {selectedLeaveType === "Accidental Leave" && (
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
                  )}

                  {/* ===== Medical Leave ===== */}
                  {selectedLeaveType === "Medical Leave" && (
                    <>
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
                      <div>
                        <label className="text-sm text-gray-400">Insurance Status</label>
                        <select name="insurancestatus" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1">
                          <option value="1">Covered</option>
                          <option value="0">Not Covered</option>
                        </select>
                      </div>
                      <div>
                        <label className="text-sm text-gray-400">Disability Description</label>
                        <textarea name="disability" placeholder="Describe your condition..." className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1 h-20" />
                      </div>
                      <div>
                        <label className="text-sm text-gray-400">Upload Medical Document</label>
                        <input type="file" accept=".pdf,.jpg,.png" onChange={handleFileUpload} className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                        {uploadedFileName && <p className="text-xs text-green-400 mt-1">Ready: {uploadedFileName}</p>}
                      </div>
                    </>
                  )}

                  {/* ===== Unpaid Leave ===== */}
                  {selectedLeaveType === "Unpaid Leave" && (
                    <>
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
                      <div>
                        <label className="text-sm text-gray-400">Upload Reason Document</label>
                        <input type="file" accept=".pdf,.jpg,.png" onChange={handleFileUpload} className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                        {uploadedFileName && <p className="text-xs text-green-400 mt-1">Ready: {uploadedFileName}</p>}
                      </div>
                    </>
                  )}

                  {/* ===== Compensation Leave ===== */}
                  {selectedLeaveType === "Compensation Leave" && (
                    <>
                      <div className="grid grid-cols-2 gap-2">
                        <div>
                          <label className="text-sm text-gray-400">Compensation Date</label>
                          <input type="date" name="compdate" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                        </div>
                        <div>
                          <label className="text-sm text-gray-400">Original Day</label>
                          <input type="date" name="orgianlday" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" required />
                        </div>
                      </div>
                      <div>
                        <label className="text-sm text-gray-400">Reason</label>
                        <textarea name="reason" className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1 h-20" placeholder="Explain why..." required />
                      </div>
                      <div>
                        <label className="text-sm text-gray-400">Replacement Employee ID</label>
                        <input type="number" value={replacementIdInput} onChange={(e) => setReplacementIdInput(e.target.value)} className="w-full bg-gray-900 border border-gray-600 rounded p-2 text-white mt-1" placeholder="e.g., 101" required />
                      </div>
                    </>
                  )}

                  <button type="submit" className="w-full bg-cyan-700 hover:bg-cyan-600 text-white py-2 rounded font-semibold shadow-lg transition-colors">
                    Submit Request
                  </button>
                </form>
              </div>

              {/* Right Column: List */}
              <div>
                <h3 className="text-xl font-bold mb-4 text-white">My Requests Status</h3>
                <div className="space-y-3 max-h-[600px] overflow-y-auto pr-2 custom-scrollbar">
                  {leaveStatus.length === 0 ? (
                    <p className="text-gray-500 italic">No requests found.</p>
                  ) : (
                    leaveStatus.map((l: any, idx: number) => {
                      const status = l.finalApprovalStatus || l.status || "Pending";
                      const statusClass = status === "Approved" ? "bg-green-500/20 text-green-300" : status === "Rejected" ? "bg-red-500/20 text-red-300" : "bg-yellow-500/20 text-yellow-300";
                      
                      return (
                        <div key={idx} className="bg-gray-900/50 p-3 rounded-lg border border-gray-700 flex justify-between items-center hover:bg-gray-900 transition">
                          <div>
                            <p className="text-sm font-bold text-gray-200">{l.type || "Request"} <span className="text-gray-500 font-normal">#{l.requestId || l.id}</span></p>
                            <p className="text-xs text-gray-500">{l.dateOfRequest || "Recent"}</p>
                          </div>
                          <span className={`text-xs px-2 py-1 rounded font-medium ${statusClass}`}>{status}</span>
                        </div>
                      );
                    })
                  )}
                </div>
              </div>
            </div>
          )}

          {/* ===== VIEW: INFO ===== */}
          {view === "info" && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                  <p className="text-gray-400 text-sm">Last Month Deductions</p>
                  <p className="text-2xl font-bold text-white mt-1">{totalDeductionAmount} EGP</p>
                </div>
                <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                  <p className="text-gray-400 text-sm">Deduction Events</p>
                  <p className="text-2xl font-bold text-red-400 mt-1">{deductions.length}</p>
                </div>
                <div className="bg-gray-900 p-4 rounded-xl border border-gray-600 text-center">
                  <p className="text-gray-400 text-sm">Performance Rating</p>
                  <p className="text-2xl font-bold text-cyan-400 mt-1">{performanceScore}</p>
                </div>
              </div>

              <div>
                <h4 className="font-bold mb-2 text-gray-300">Attendance Log</h4>
                <div className="h-64 bg-gray-900 rounded-lg border border-gray-700 text-gray-300 p-4 overflow-y-auto">
                  {attendance.length > 0 ? attendance.map((a: any, i: number) => (
                    <div key={i} className="flex justify-between border-b border-gray-800 py-2 text-sm last:border-0">
                      <span>{a.date}</span>
                      <span className="text-gray-500">In: {a.checkInTime || "--"} / Out: {a.checkOutTime || "--"}</span>
                    </div>
                  )) : <p className="text-center text-gray-500 mt-10">No records available.</p>}
                </div>
              </div>
            </div>
          )}

          {/* ===== VIEW: DEAN ===== */}
          {view === "dean" && (
            <div>
              <div className="mb-4 p-4 bg-yellow-900/20 border border-yellow-700/50 rounded-lg flex items-center gap-3">
                 <div className="w-2 h-2 bg-yellow-500 rounded-full animate-pulse"></div>
                 <p className="text-yellow-200 text-sm">Restricted Area: Dean Authorization Required</p>
              </div>
              
              <div className="space-y-4">
                <h3 className="font-bold text-lg text-white">Pending Approvals Queue</h3>
                {leaveStatus.filter(l => (l.finalApprovalStatus || l.status) === "Pending").length === 0 ? (
                  <p className="text-gray-500 italic">No pending items.</p>
                ) : (
                  leaveStatus.filter(l => (l.finalApprovalStatus || l.status) === "Pending").map((l: any) => (
                    <div key={l.requestId || l.id} className="flex justify-between items-center bg-gray-900 p-4 rounded-lg border border-gray-600">
                      <div>
                        <p className="font-bold text-gray-200">{l.emp || `Employee ${l.employeeID}`}</p>
                        <p className="text-xs text-gray-400">{l.type || "Annual Leave"}</p>
                      </div>
                      <div className="flex gap-2">
                        <button onClick={() => handleDeanApproval(l.requestId, l.type, 'Approve')} className="text-xs bg-green-600 hover:bg-green-500 text-white px-3 py-1.5 rounded transition">Approve</button>
                        <button onClick={() => handleDeanApproval(l.requestId, l.type, 'Reject')} className="text-xs bg-red-600 hover:bg-red-500 text-white px-3 py-1.5 rounded transition">Reject</button>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
};

export default AcademicDashboard;