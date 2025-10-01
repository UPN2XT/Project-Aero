CREATE TABLE Employee
(
    id INT PRIMARY KEY IDENTITY(1,1),
    national_id INT NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    email VARCHAR(20) NOT NULL,
    gender VARCHAR(10) NOT NULL
        CHECK (gender IN ('Male', 'Female')),
    address TEXT NOT NULL
);

CREATE TABLE Employee_Employment
(
    id INT PRIMARY KEY IDENTITY(1,1),
    employee_id INT NOT NULL,
    employment_status VARCHAR(10) NOT NULL
        CHECK (employment_status IN ('Active', 'Inactive')),
    contract_type VARCHAR(10) NOT NULL
        CHECK (employment_status IN ('Part time', 'Full time')),
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    last_working_date DATE NULL,
    years_of_experience INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(id)
);

CREATE TABLE Employee_Benefits
(
    id INT PRIMARY KEY IDENTITY(1,1),
    employee_id INT NOT NULL,
    annual_leave_balance INT NOT NULL,
    accidental_leave_balance INT NOT NULL,
    official_day_off VARCHAR(20) NOT NULL,
    emergency_contact_name VARCHAR(30) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(id)
);

CREATE TABLE Phone_Numer
(
    id INT PRIMARY KEY IDENTITY(1,1),
    employee_id INT NOT NULL,
    number VARCHAR(20) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(id)
);

CREATE TABLE Employee_Replacements
(
    employee_on_leave_id INT NOT NULL,
    replacing_employee_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (employee_on_leave_id) REFERENCES Employee(id),
    FOREIGN KEY (replacing_employee_id) REFERENCES Employee(id),
    CONSTRAINT PK_Employee_Replacements PRIMARY KEY (employee_on_leave_id, replacing_employee_id)
);