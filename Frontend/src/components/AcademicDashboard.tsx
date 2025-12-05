// AcademicDashboard.tsx
import React, { useState, useEffect, useCallback } from "react";
import { authenticatedFetch } from "../api/apiService";
import { showError, showSuccess } from "../utils/toast";

type AcademicView = "leaves" | "info" | "dean";

interface AcademicDashboardProps {
  onLogout: () => void;
}

// Types for Dean approval queue (matches backend Leave DTO from HR)
interface PendingLeaveApproval {
  requestId: number;
  empId: number;
  type: string;
  dateOfRequest: string;
  status: string;
}

const USER_ID = Number(localStorage.getItem("userId")) || 1;
const CURRENT_SEMESTER = "W25";

// Auth headers helper
const getAuthHeaders = (): HeadersInit => {
  const token = localStorage.getItem('jwtToken');
  return {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
  };
};

export const AcademicDashboard: React.FC<AcademicDashboardProps> = ({ onLogout }) => {
  // === UI View State ===
  const [view, setView] = useState<AcademicView>("leaves");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // === User Profile State ===
  const [userName, setUserName] = useState<string>("User");
  const [userRole, setUserRole] = useState<string>("");

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

  // === Dean Tab State ===
  const [pendingApprovals, setPendingApprovals] = useState<PendingLeaveApproval[]>([]);
  const [deanReplacementId, setDeanReplacementId] = useState<string>("");

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
        showError(
          `Error (${response.status}): ${errorData.message || "Request failed"}`
        );
        return null;
      }

      const contentType = response.headers.get("content-type");
      if (!contentType || !contentType.includes("application/json")) return { success: true };

      return await response.json();
    } catch (error) {
      setLoading(false);
      showError(`Network error for ${endpoint}.`);
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
        if (!replacementIdInput) return showError("Replacement ID is required.");
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
        if (!uploadedFile) return showError("Medical document is required.");
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
        if (!uploadedFile) return showError("Reason document is required.");
        endpoint = "/employee/submit/unpaid";
        payload = {
          start: startDate,
          end: endDate,
          document: uploadedFile, // Base64
          filename: uploadedFileName
        };
        break;

      case "Compensation Leave":
        if (!replacementIdInput) return showError("Replacement ID is required.");
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
        showSuccess(`${selectedLeaveType} submitted successfully.`);
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

  // Fetch pending approvals from HR API (Dean/Upper Board uses same endpoint)
  const fetchPendingApprovals = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('/api/hr/approvals/get-all', {
        method: 'POST',
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        const data: PendingLeaveApproval[] = await response.json();
        // Filter only Annual and Unpaid leaves (Dean can only approve these)
        const deanApprovals = data.filter(
          (leave) =>
            leave.type?.toLowerCase().includes('annual') ||
            leave.type?.toLowerCase().includes('unpaid')
        );
        setPendingApprovals(deanApprovals);
      } else if (response.status === 401) {
        setError('Session expired. Please log in again.');
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        setError(`Failed to fetch approvals: ${errorData.message || response.statusText}`);
      }
    } catch (err) {
      console.error('Network error fetching approvals:', err);
      setError('Network error. Please check your connection.');
    } finally {
      setLoading(false);
    }
  }, [onLogout]);

  const fetchInfoData = async () => {
    const perfData = await handleFetch("/employee/my-performance", { sem: CURRENT_SEMESTER });
    if (perfData && perfData.length > 0) setPerformance(perfData[0]);

    const dedData = await handleFetch("/employee/deduction-attendance", { month: new Date().getMonth() + 1 });
    if (dedData) setDeductions(dedData);

    const attendanceData = await handleFetch("/employee/my-attendance", {});
    if (attendanceData) setAttendance(attendanceData);
  };

  // Dean approval handler - uses Employee API for upperboard approval
  const handleDeanApproval = async (requestID: number, leaveType: string, replacementId?: number) => {
    setLoading(true);
    setError(null);

    // Determine endpoint based on leave type
    let endpoint = "";
    if (leaveType.toLowerCase().includes("annual")) {
      endpoint = "/api/employee/upperboard/approve/annual";
    } else if (leaveType.toLowerCase().includes("unpaid")) {
      endpoint = "/api/employee/upperboard/approve/unpaid";
    } else {
      setError(`Dean approval not supported for ${leaveType}. Only Annual and Unpaid leaves can be processed.`);
      setLoading(false);
      return;
    }

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({
          requestId: requestID,
          replacmentId: replacementId || null
        }),
      });

      if (response.ok) {
        showSuccess(`Leave request #${requestID} approved successfully!`);
        fetchPendingApprovals(); // Refresh the list
      } else if (response.status === 401) {
        setError('Session expired. Please log in again.');
        onLogout();
      } else {
        const errorData = await response.json().catch(() => ({}));
        setError(`Failed to approve request: ${errorData.message || response.statusText}`);
      }
    } catch (err) {
      console.error('Network error processing approval:', err);
      setError('Network error. Please check your connection.');
    } finally {
      setLoading(false);
    }
  };

  // Fetch user profile
  const fetchUserProfile = useCallback(async () => {
    try {
      const response = await fetch('/api/employee/me', {
        method: 'POST',
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        const data = await response.json();
        setUserName(data.name || "User");
        setUserRole(data.role || "");
      } else if (response.status === 401) {
        console.error('Unauthorized: Session expired');
        onLogout();
      } else if (response.status === 403) {
        console.error('Forbidden: Access denied to /api/employee/me');
        const errorData = await response.json().catch(() => ({}));
        console.error('Error details:', errorData);
      } else {
        console.error(`Error fetching profile: ${response.status}`);
      }
    } catch (err) {
      console.error('Error fetching user profile:', err);
    }
  }, [onLogout]);

  // === Effects ===
  useEffect(() => {
    fetchUserProfile();
  }, [fetchUserProfile]);

  useEffect(() => {
    if (view === "leaves") fetchLeavesStatus();
    else if (view === "info") fetchInfoData();
    else if (view === "dean") fetchPendingApprovals();
  }, [view, fetchPendingApprovals]);

  // === Render Helpers ===
  const performanceScore = performance?.rating ? (performance.rating >= 4 ? "A-" : "B+") : "N/A";
  const totalDeductionAmount = deductions.reduce((sum: number, d: any) => sum + (d.amount || 0), 0);

  // Check if user has dean/upper board authorization
  const isDeanAuthorized = userRole && (
    userRole.toLowerCase().includes('dean') ||
    userRole.toLowerCase().includes('pres') ||
    userRole.toLowerCase().includes('vice')
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-black to-gray-950 p-6">
      <div className="max-w-5xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-8 bg-gray-800/50 p-4 rounded-2xl border border-gray-700 backdrop-blur-md">
          <h1 className="text-2xl font-bold text-white">
            <span className="text-cyan-400">Academic</span> Portal
          </h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-400">Welcome, Dr. {userName}</span>
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
          {['leaves', 'info', ...(isDeanAuthorized ? ['dean'] : [])].map((tab) => (
            <button
              key={tab}
              onClick={() => setView(tab as AcademicView)}
              className={`pb-2 px-1 capitalize ${view === tab
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
              {/* Error Display */}
              {error && (
                <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-lg text-red-300 text-sm">
                  {error}
                </div>
              )}

              {/* Pending Approvals Section */}
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <h3 className="font-bold text-lg text-white">Pending Leave Approvals</h3>
                  <button
                    onClick={fetchPendingApprovals}
                    className="text-xs bg-cyan-600/20 text-cyan-400 px-3 py-1.5 rounded hover:bg-cyan-600/30 transition"
                  >
                    Refresh List
                  </button>
                </div>

                {/* Stats Summary */}
                <div className="grid grid-cols-2 gap-4 mb-4">
                  <div className="bg-gray-900/50 p-4 rounded-lg border border-gray-700 text-center">
                    <p className="text-gray-400 text-xs">Pending Annual</p>
                    <p className="text-xl font-bold text-cyan-400 mt-1">
                      {pendingApprovals.filter(a => a.type?.toLowerCase().includes('annual')).length}
                    </p>
                  </div>
                  <div className="bg-gray-900/50 p-4 rounded-lg border border-gray-700 text-center">
                    <p className="text-gray-400 text-xs">Pending Unpaid</p>
                    <p className="text-xl font-bold text-orange-400 mt-1">
                      {pendingApprovals.filter(a => a.type?.toLowerCase().includes('unpaid')).length}
                    </p>
                  </div>
                </div>

                {/* Approvals List */}
                {pendingApprovals.length === 0 ? (
                  <div className="text-center py-12 bg-gray-900/30 rounded-lg border border-gray-700">
                    <div className="text-4xl mb-3">✓</div>
                    <p className="text-gray-400">No pending approvals</p>
                    <p className="text-gray-500 text-sm mt-1">All leave requests have been processed</p>
                  </div>
                ) : (
                  <div className="space-y-3 max-h-[500px] overflow-y-auto pr-2">
                    {pendingApprovals.map((leave) => {
                      const isAnnual = leave.type?.toLowerCase().includes('annual');
                      const typeBadgeClass = isAnnual
                        ? 'bg-cyan-500/20 text-cyan-400'
                        : 'bg-orange-500/20 text-orange-400';

                      return (
                        <div
                          key={leave.requestId}
                          className="bg-gray-900/50 p-4 rounded-lg border border-gray-700 hover:border-gray-600 transition"
                        >
                          <div className="flex justify-between items-start mb-3">
                            <div>
                              <div className="flex items-center gap-2">
                                <span className={`text-xs px-2 py-0.5 rounded ${typeBadgeClass}`}>
                                  {leave.type || 'Leave'}
                                </span>
                                <span className="text-gray-500 text-xs">#{leave.requestId}</span>
                              </div>
                              <p className="text-white font-medium mt-1">Employee ID: {leave.empId}</p>
                              <p className="text-gray-400 text-xs mt-1">
                                Requested: {leave.dateOfRequest || 'N/A'}
                              </p>
                            </div>
                            <span className="text-xs px-2 py-1 rounded bg-yellow-500/20 text-yellow-300">
                              {leave.status || 'Pending'}
                            </span>
                          </div>

                          {/* Only show approval controls if status is Pending */}
                          {(leave.status?.toLowerCase() === 'pending' || !leave.status) && (
                            <>
                              {/* Replacement ID Input for Annual Leave */}
                              {isAnnual && (
                                <div className="mb-3">
                                  <label className="text-xs text-gray-400 block mb-1">
                                    Replacement Employee ID (optional)
                                  </label>
                                  <input
                                    type="number"
                                    placeholder="Enter replacement ID..."
                                    className="w-full bg-gray-800 border border-gray-600 rounded p-2 text-white text-sm focus:border-cyan-500 outline-none"
                                    onChange={(e) => setDeanReplacementId(e.target.value)}
                                  />
                                </div>
                              )}

                              {/* Action Button */}
                              <button
                                onClick={() => handleDeanApproval(
                                  leave.requestId,
                                  leave.type || '',
                                  deanReplacementId ? Number(deanReplacementId) : undefined
                                )}
                                disabled={loading}
                                className="w-full text-sm bg-green-600 hover:bg-green-500 disabled:bg-green-600/50 disabled:cursor-not-allowed text-white py-2 rounded font-medium transition flex items-center justify-center gap-2"
                              >
                                {loading ? (
                                  <>
                                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                                    Processing...
                                  </>
                                ) : (
                                  <>
                                    <span>✓</span> Approve Leave Request
                                  </>
                                )}
                              </button>
                            </>
                          )}

                          {/* Show processed status message if not pending */}
                          {leave.status && leave.status.toLowerCase() !== 'pending' && (
                            <div className={`text-center py-2 rounded text-sm ${leave.status.toLowerCase() === 'approved'
                              ? 'bg-green-500/10 text-green-400'
                              : 'bg-red-500/10 text-red-400'
                              }`}>
                              Already {leave.status}
                            </div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}

                {/* Information Note */}
                <div className="mt-6 p-4 bg-gray-900/30 rounded-lg border border-gray-700">
                  <h4 className="text-gray-300 font-medium text-sm mb-2">📋 Dean Approval Guidelines</h4>
                  <ul className="text-gray-400 text-xs space-y-1">
                    <li>• <strong className="text-cyan-400">Annual Leave:</strong> Requires HR approval first. You can optionally assign a replacement employee.</li>
                    <li>• <strong className="text-orange-400">Unpaid Leave:</strong> Employee's annual balance must be exhausted. Maximum 30 days duration.</li>
                    <li>• Approvals are final and will update the employee's leave records immediately.</li>
                  </ul>
                </div>
              </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
};

export default AcademicDashboard;
