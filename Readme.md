# Project AERO - University HR Management System

A full-stack university HR management system implementing complex database business logic through a Spring Boot RESTful API and React frontend. The project demonstrates integration of SQL Server stored procedures with modern web technologies.

## Overview

**Project AERO** is a comprehensive HR management system that wraps 50+ SQL Server stored procedures, functions, and views with Spring Boot REST endpoints, consumed by a React-based user interface. The application handles employee management, attendance tracking, leave workflows, payroll processing, and performance evaluations—all with business logic enforced at the database level through T-SQL procedures.

## Technology Stack

### Backend
- **Java 17** with **Spring Boot 3.x**
- **JDBC Template** - Direct SQL execution for stored procedures and functions
- **JWT Authentication** - Token-based security for API endpoints
- **Microsoft SQL Server 2022** - Database with T-SQL stored procedures
- **Maven** - Build automation and dependency management
- **Swagger/OpenAPI 3** - API documentation

### Frontend
- **React 18** with **TypeScript**
- **Vite** - Build tooling
- **TailwindCSS** - Styling
- **Axios** - HTTP client

### Infrastructure
- **Docker** & **Docker Compose**
- **Nginx** - Static file serving
- **SQL Server Container**

## Quick Start

### Prerequisites
- Docker 20.10+ and Docker Compose 2.0+
- Java 17+ (for local development)
- Node.js 18+ (for frontend development)

### Running with Docker

1. **Clone the repository**
   ```bash
   git clone https://github.com/UPN2XT/Project-Aero.git
   cd Project-Aero
   ```

2. **Configure environment variables**
   
   Create a `.env` file:
   ```env
   DB_NAME=University_HR_ManagementSystem
   DB_PASSWORD=YourStrong@Passw0rd
   JWT_SECRET=404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
   JWT_EXPIRATION=3600000
   ```

3. **Start the application**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - API: http://localhost:8085
   - API Documentation: http://localhost:8085/docs

## Architecture

The application uses a three-tier architecture:

**Database Layer**: Business logic implemented in T-SQL stored procedures, table-valued functions, and views. Handles leave workflows, payroll calculations, attendance tracking, and approval hierarchies.

**API Layer**: Spring Boot REST controllers use JDBC Template to execute database procedures. JWT authentication secures endpoints.

**Frontend Layer**: React SPA with TypeScript consumes REST API and provides user interface for different employee roles.

### Project Structure
```
Project-Aero/
├── Backend/                    # Spring Boot application
│   ├── src/main/java/com/upn2xt/Aero/
│   │   ├── Admin/             # Administrative operations
│   │   │   ├── Controller/
│   │   │   ├── Dtos/
│   │   │   ├── Mapper/
│   │   │   └── Repos/
│   │   ├── Auth/              # Authentication & Security
│   │   │   ├── Config/        # JWT, Security config
│   │   │   ├── Controller/
│   │   │   └── Services/
│   │   ├── Employee/          # Employee self-service
│   │   └── HR/                # HR management
│   └── src/main/resources/
│       ├── application.yml
│       └── schema.sql         # Database schema
├── Frontend/                   # React application
│   └── src/
│       ├── components/
│       └── api/
└── docker-compose.yml
```

### API Modules

| Module | Endpoint | Description |
|--------|----------|-------------|
| **Auth** | `/api/auth` | JWT authentication |
| **Admin** | `/api/admin` | System administration |
| **HR** | `/api/hr` | HR operations |
| **Employee** | `/api/employee` | Employee self-service |

## Development

### Local Development Setup

1. **Start SQL Server container**
   ```bash
   docker-compose up -d mssql
   ```

2. **Run backend**
   ```bash
   cd Backend
   ./mvnw spring-boot:run
   ```

3. **Run frontend**
   ```bash
   cd Frontend
   npm install
   npm run dev
   ```

### Building for Production

```bash
docker-compose build
docker-compose up -d
```

## Security Features

- **JWT authentication** with token generation and validation
- **Password encryption** using BCrypt
- **Parameterized SQL queries** via JDBC Template
- **CORS configuration**

## Database Design

The system implements a normalized relational database with 15+ tables including employees, departments, attendance, leave requests, payroll, and performance evaluations. Business logic is implemented through 50+ stored procedures and functions:

- **Leave Management**: Annual, accidental, unpaid, compensation, and medical leave with approval workflows
- **Payroll Processing**: Salary calculations with experience adjustments, overtime bonuses, and deductions
- **Attendance Tracking**: Daily check-in/check-out with status validation
- **Performance Reviews**: Semester-based evaluations

All database objects are defined in `schema.sql` and initialized on application startup.

## Contact

**Repository**: [github.com/UPN2XT/Project-Aero](https://github.com/UPN2XT/Project-Aero)
