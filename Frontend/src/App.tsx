// src/App.tsx

import React, { useState } from 'react';
import type { UserRole } from './types';
import { Login } from './components/Login';
import { AdminDashboard } from './components/AdminDashboard';
import { AcademicDashboard } from './components/AcademicDashboard';
import { HRDashboard } from './components/HRDashboard';

export const App: React.FC = () => {
  const [userRole, setUserRole] = useState<UserRole>(null);

  const renderContent = () => {
    if (!userRole) {
      return <Login onLogin={(role: UserRole) => setUserRole(role)} />;
    }
    if (userRole === 'Admin') {
      return <AdminDashboard onLogout={() => setUserRole(null)} />;
    }
    if (userRole === 'Academic') {
      return <AcademicDashboard onLogout={() => setUserRole(null)} />;
    }
    if (userRole === 'HR') {
      return <HRDashboard onLogout={() => setUserRole(null)} />;
    }
    // Fallback in case userRole is set to something unexpected
    return <Login onLogin={(role: UserRole) => setUserRole(role)} />;
  };

  return (
    <div className="relative">
      {renderContent()}
    </div>
  );
};