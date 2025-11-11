## 📄 README: University HR Management System - Milestone 2

This document summarizes the requirements and guidelines for Milestone 2 of the University HR Management System project.

---

## 📅 Project Details

* [cite_start]**Milestone:** Milestone 2 [cite: 1]
* [cite_start]**Deadline:** 24/11/2025 at 11:59 [cite: 2, 3]
* [cite_start]**Database Name:** `University_HR_ManagementSystem_Team_No` [cite: 83, 84]
* **Note:** The Milestone description is subject to minor changes announced on CMS. [cite_start]Check CMS periodically. [cite: 5, 6, 7, 8]

---

## 🛠️ General Guidelines & Schema Constraints

### 1. Data Type & Naming Conventions

* [cite_start]**Alpha-numeric attributes:** `varchar(50)` [cite: 9]
* [cite_start]**IDs (Primary/Foreign):** `identity(1,1)` [cite: 11]
* [cite_start]**Numeric values (non-ID):** `int` or `decimal` [cite: 12]
* [cite_start]**Phone numbers:** `char(11)` [cite: 13]
* [cite_start]**Semester:** `char(3)` (e.g., W25, S24) [cite: 13]
* [cite_start]**Strict Adherence:** You **must** follow the exact column order, data types, and column names as outlined in the provided schema[cite: 14]. [cite_start]Failing this, or not matching the required names for functions, stored procedures, and views, will result in a grade loss[cite: 15, 16, 17].
* [cite_start]**Output Consistency:** Follow the order of needed columns for tables returned from functions or views[cite: 18, 19].
* [cite_start]**Parameter Consistency:** Follow the exact order and data types of parameters for stored procedures and functions[cite: 20].

### 2. Schema Constraints (Valid Values)

| Attribute | Valid Values | Default Value |
| :--- | :--- | :--- |
| **Performance Rating** | 1 to 5 | [cite_start]N/A [cite: 29] |
| **Document Status** | `valid`, `expired` | [cite_start]N/A [cite: 29] |
| **Leave Status** | `approved`, `rejected`, `pending` | [cite_start]`pending` [cite: 30] |
| **Deduction Type** | `unpaid`, `missing_hours`, `missing_days` | [cite_start]N/A [cite: 31] |
| **Deduction Status** | `pending`, `finalized` | [cite_start]`pending` [cite: 32] |
| **Attendance Status** | `absent`, `attended` | [cite_start]`Absent` [cite: 33] |
| **Contract Type** | `full_time`, `part_time` | [cite_start]N/A [cite: 34] |
| **Employment Status** | `active`, `onleave`, `notice_period`, `resigned` | [cite_start]N/A [cite: 35] |
| **Medical Leave Type** | `sick`, `maternity` | [cite_start]N/A [cite: 36] |

---

## 💼 Role Ranks

This table defines the hierarchy for leaves and approvals:

| Role | Belongs to Department | Rank |
| :--- | :--- | :--- |
| President | (N/A) | [cite_start]1 [cite: 75] |
| Vice President | (N/A) | [cite_start]2 [cite: 75] |
| Dean | MET, IET, etc | [cite_start]3 [cite: 75] |
| HR Manager | HR Department | [cite_start]3 [cite: 75] |
| Vice Dean | MET, IET, etc | [cite_start]4 [cite: 75] |
| HR Representative | HR Department | [cite_start]4 [cite: 75] |
| Lecturer | MET, IET, etc | [cite_start]5 [cite: 75] |
| Teaching Assistant (TA) | MET, IET, etc | [cite_start]6 [cite: 75] |
| Medical Doctor | Medical Department | [cite_start]6 [cite: 75] |

---

## 💰 Payroll & Leave Guidelines

### Payroll Calculations

* **Employee Salary:**
    [cite_start]$$\text{Salary} = \text{base\_salary} + \left(\frac{\% \text{year\_of\_experience}}{100}\right) \times \text{years\_of\_experience} \times \text{base\_salary}$$ [cite: 38, 39, 40]
    * [cite_start]*Note:* If an employee has multiple roles, the overtime factor and base salary of the **higher rank** will be used[cite: 43].
* **Rate Per Hour:**
    [cite_start]$$\text{Rate per hour} = \frac{\text{employee\_salary}}{22 \text{ days}} \div 8 \text{ hours}$$ [cite: 53]
* **Overtime Amount (Bonus):**
    [cite_start]$$\text{Overtime amount} = \text{rate per hour} \times \left(\frac{\text{overtime factor (based on role)} \times \text{extra hours in attendance}}{100}\right)$$ [cite: 54]
    * [cite_start]Bonuses are added to the payroll in case of overtime[cite: 52].
* [cite_start]**Deduction Rate:** The deduction rate per day for unpaid leaves is equivalent to the rate applied for a missing day[cite: 222].

### Attendance

* [cite_start]**Full-Time Hours:** Total required hours per day for full-time employees is **8 hours**[cite: 45].
* [cite_start]**Finalization:** Deductions, payrolls, and attendance for the current month are finalized when requested[cite: 48, 49, 50]. [cite_start]Deductions are finalized when reflected in the payroll[cite: 51].

### Leaves

* [cite_start]**Part-Time Ineligibility:** Part-time employees are **not eligible** for annual, unpaid, and maternity leaves[cite: 56, 57].
* [cite_start]**Dean/Vice-Dean Approval:** If the Dean is on leave, the Vice-Dean approves/rejects the request[cite: 58, 59]. [cite_start]The Dean and Vice-Dean cannot be on leave simultaneously[cite: 60].
* [cite_start]**Upper Management Leaves:** Annual/unpaid leave requests by the Dean or Vice-Dean must be approved/rejected by the **President** and an **HR Representative**[cite: 61, 62].
* [cite_start]**HR Employee Unpaid Leave:** Unpaid leave requests by an HR employee must be approved/rejected by the **President** and the **HR Manager**[cite: 63, 64].
* [cite_start]**Final Approval:** The **HR employee** is the last person to approve/reject leaves and adjusts the final status[cite: 65].
* [cite_start]**Rejection Rule:** If **any** employee in the approval hierarchy rejects the leave, the final status is `rejected`[cite: 66].
* [cite_start]**Unpaid Leave Limit:** An employee can have only **one** approved unpaid leave per year, with a maximum duration of **30 days**[cite: 71].
* [cite_start]**Accidental Leave:** Duration is only **1 day** per leave[cite: 70].
* **Compensation Leaves:**
    * [cite_start]Approved by HR employees if the applicant spent at least **8 hours** during their day off[cite: 67].
    * [cite_start]Must be requested within the **same month** and have a valid reason[cite: 68, 69].

---

## ⚙️ Requirements (Stored Procedures, Functions, and Views)

### 1. Basic Structure of the Database (Admin)

| Type | Name | Input | Output | Description |
| :--- | :--- | :--- | :--- | :--- |
| SP | `createAllTables` | None | None | [cite_start]Creates all database tables [cite: 86, 87, 88, 89] |
| SP | `dropAllTables` | None | None | [cite_start]Drops all database tables [cite: 91, 92, 93, 94] |
| SP | `dropAllProceduresFunctionsViews` | None | None | [cite_start]Drops all SPs (except itself), functions, and views [cite: 97, 98, 99, 100] |
| SP | `clearAllTables` | None | None | [cite_start]Clears all records from all tables [cite: 102, 103, 104, 105] |

### 2. Basic Data Retrieval

| Type | Name | Input | Output | Description |
| :--- | :--- | :--- | :--- | :--- |
| View | `allEmployeeProfiles` | None | Table | [cite_start]Details for all employees (including ID, names, gender, email, address, YOE, official day off, contract type, status, annual/accidental balance) [cite: 108, 109, 110, 111, 112] |
| View | `NoEmployeeDept` | None | Table | [cite_start]Number of employees per department [cite: 113, 114, 115, 116] |
| View | `allPerformance` | None | Table | [cite_start]Performance details for all employees in all Winter semesters [cite: 118, 119, 120, 121] |
| View | `allRejectedMedicals` | None | Table | [cite_start]Details of all rejected medical leaves [cite: 123, 124, 125, 126] |
| View | `allEmployeeAttendance` | None | Table | [cite_start]Attendance records for all employees for yesterday [cite: 128, 129, 130, 131] |

### 3. Admin Tasks

| Type | Name | Input | Output |
| :--- | :--- | :--- | :--- |
| SP | `Update_Status_Doc` | None | [cite_start]None [cite: 134, 135, 136, 137] |
| SP | `Remove_Deductions` | None | [cite_start]None [cite: 139, 140, 141, 142] |
| SP | `Update_Employment_Status` | `Employee_ID int` | [cite_start]None [cite: 145, 146, 147, 148] |
| SP | `Create_Holiday` | None | [cite_start]None (Creates `Holiday` lookup table) [cite: 152, 153, 154, 155] |
| SP | `Add_Holiday` | `holiday_name varchar(50)`, `from_date date`, `to_date date` | [cite_start]None [cite: 157, 158, 159] |
| SP | `Intitiate_Attendance` | None | [cite_start]None [cite: 161, 162, 163, 164] |
| SP | `Update_Attendance` | `Employee_id int`, `check-in time`, `check-out time` | [cite_start]None [cite: 166, 167, 168, 169] |
| SP | `Remove_Holiday` | None | [cite_start]None [cite: 171, 172, 173, 174] |
| SP | `Remove_DayOff` | `Employee_id int` | [cite_start]None [cite: 176, 177, 178, 179] |
| SP | `Remove_Approved_Leaves` | `Employee_id int` | [cite_start]None [cite: 181, 182, 183, 184] |
| SP | `Replace_employee` | `Emp1_ID int`, `Emp2_ID int`, `from_date date`, `to_date date` | [cite_start]None [cite: 186, 187, 188, 189] |

### 4. HR Employee Tasks

| Type | Name | Input | Output |
| :--- | :--- | :--- | :--- |
| Function | `HRLoginValidation` | `employee_ID int`, `password varchar(50)` | [cite_start]`Success bit` [cite: 192, 193, 194, 195] |
| SP | `HR_approval_an_acc` | `request_ID int`, `HR_ID int` | [cite_start]None [cite: 197, 198, 199, 200] |
| SP | `HR_approval_unpaid` | `request_ID int`, `HR_ID int` | [cite_start]None [cite: 202, 203, 204, 205] |
| SP | `HR_approval_comp` | `request_ID int`, `HR_ID int` | [cite_start]None [cite: 207, 208, 209, 210] |
| SP | `Deduction_hours` | `employee_ID int` | [cite_start]None [cite: 212, 213, 214, 215] |
| SP | `Deduction_days` | `employee_ID int` | [cite_start]None [cite: 217, 218, 219, 220] |
| SP | `Deduction_unpaid` | `employee_ID int` | [cite_start]None [cite: 223, 224, 225, 226] |
| Function | `Bonus_amount` | `employee_ID int` | [cite_start]`Bonus value` [cite: 228, 229, 230, 231] |
| SP | `Add_Payroll` | `employee_ID int`, `from date`, `to date` | [cite_start]None [cite: 233, 234, 235, 236] |

### 5. Employee Tasks

| Type | Name | Input | Output |
| :--- | :--- | :--- | :--- |
| Function | `EmployeeLoginValidation` | `employee_ID int`, `password varchar(50)` | [cite_start]`Success bit` [cite: 239, 240, 241, 242] |
| TVF | `MyPerformance` | `employee_ID int`, `semester char(3)` | [cite_start]Table [cite: 244, 245, 246, 247] |
| TVF | `MyAttendance` | `employee_ID int` | [cite_start]Table [cite: 249, 250, 251, 252] |
| TVF | `Last_month_payroll` | `employee_ID int` | [cite_start]Table [cite: 254, 255, 256, 257] |
| TVF | `Deductions_Attendance` | `employee_ID int`, `month int` | [cite_start]Table [cite: 259, 260, 261, 262] |
| Function | `Is_On_Leave` | `employee_ID int`, `from date`, `to date` | [cite_start]`Success bit` [cite: 266, 267, 268, 269] |
| SP | `Submit_annual` | `employee_ID int`, `replacement_emp int`, `start_date date`, `end_date date` | [cite_start]None [cite: 271, 272, 273, 274, 275] |
| TVF | `Status_leaves` | `employee_ID int` | [cite_start]Table [cite: 277, 278, 279, 280] |
| SP | `Upperboard_approve_annual` | `request_ID int`, `Upperboard_ID int`, `replacement_ID int` | [cite_start]None [cite: 284, 285, 286, 287] |
| SP | `Submit_accidental` | `employee_ID int`, `start_date date`, `end_date date` | [cite_start]None [cite: 289, 290, 291] |
| SP | `Submit_medical` | `employee_ID int`, `start_date date`, `end_date date`, `type varchar(50)`, `insurance_status bit`, `disability_details varchar(50)`, `document_description varchar(50)`, `file_name varchar(50)` | [cite_start]None [cite: 293, 294, 295, 296] |
| SP | `Submit_unpaid` | `employee_ID int`, `start_date date`, `end_date date`, `document_description varchar(50)`, `file_name varchar(50)` | [cite_start]None [cite: 298, 299, 300, 301] |
| SP | `Upperboard_approve_unpaids` | `request_ID int`, `Upperboard_ID int` | [cite_start]None [cite: 304, 305, 306] |
| SP | `Submit_compensation` | `employee_ID int`, `compensation_date date`, `reason varchar(50)`, `date_of_original_workday date`, `replacement_emp int` | [cite_start]None [cite: 308, 309, 310, 311] |
| SP | `Dean_andHR_Evaluation` | `employee_ID int`, `rating int`, `comment varchar(50)`, `semester char(3)` | [cite_start]None [cite: 313, 314, 315, 316, 317] |