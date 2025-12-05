// src/types.ts

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

export interface EmployeeProfile {
  employee_ID: number;
  first_name: string;
  last_name: string;
  gender: string;
  email: string;
  address: string;
  years_of_experience: number;
  official_day_off: string;
  type_of_contract: string;
  employment_status: string;
  annual_balance: number;
  accidental_balance: number;
}

export interface AttendanceRecord {
  attendance_ID: number;
  date: string;
  check_in_time: string;
  check_out_time: string;
  total_duration: number;
  status: 'Present' | 'Absent' | 'Leave';
  emp_ID: number;
}

export interface PerformanceRecord {
  performance_ID: number;
  rating: number;
  comments: string;
  semester: string;
  emp_ID: number;
}

export interface RejectedLeave {
  request_ID: number;
  date_of_request: string;
  start_date: string;
  end_date: string;
  type: string;
  insurance_status: boolean;
  disability_details: string;
  final_approval_status: 'Rejected';
  emp_ID: number;
}

export const mapMockEmployeesToProfiles = (mockData: Employee[]): EmployeeProfile[] => {
    return mockData.map(emp => ({
        employee_ID: emp.id,
        first_name: emp.name.split(' ')[0] || 'Unknown',
        last_name: emp.name.split(' ')[1] || 'User',
        employment_status: emp.status,
        gender: 'Unknown',
        email: `${emp.name.toLowerCase().replace(' ', '.')}@example.com`,
        address: 'N/A',
        years_of_experience: 5,
        official_day_off: 'Friday',
        type_of_contract: 'Full-time',
        annual_balance: 21,
        accidental_balance: 5,
    }));
};


export const MOCK_EMPLOYEES: Employee[] = [
  { id: 1, name: "Ali Hassan", role: "Professor", dept: "CS", status: "Active" },
  { id: 2, name: "Mona Ahmed", role: "Lecturer", dept: "Physics", status: "On Leave" },
  { id: 3, name: "Khaled Youssef", role: "TA", dept: "CS", status: "Resigned" },
];

export const MOCK_LEAVES: LeaveRequest[] = [
  { id: 101, emp: "Mona Ahmed", type: "Annual", status: "Pending" },
  { id: 102, emp: "Sarah Nabil", type: "Medical", status: "Approved" },
];