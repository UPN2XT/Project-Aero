// src/types.ts

// --- INTERFACES ---

export interface Employee {
  id: number;
  name: string;
  role: 'Professor' | 'Lecturer' | 'TA';
  dept: string;
  status: 'Active' | 'On Leave' | 'Resigned';
}

export interface LeaveRequest {
  id: number;
  emp: string;
  type: string;
  status: 'Pending' | 'Approved' | 'Rejected';
}

export type UserRole = 'Admin' | 'Academic' | 'HR' | null;

// --- MOCK DATA ---

export const MOCK_EMPLOYEES: Employee[] = [
  { id: 1, name: "Ali Hassan", role: "Professor", dept: "CS", status: "Active" },
  { id: 2, name: "Mona Ahmed", role: "Lecturer", dept: "Physics", status: "On Leave" },
  { id: 3, name: "Khaled Youssef", role: "TA", dept: "CS", status: "Resigned" },
];

export const MOCK_LEAVES: LeaveRequest[] = [
  { id: 101, emp: "Mona Ahmed", type: "Annual", status: "Pending" },
  { id: 102, emp: "Sarah Nabil", type: "Medical", status: "Approved" },
];