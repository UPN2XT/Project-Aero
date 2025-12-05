import React, { useState, useEffect } from 'react';
import type { UserRole } from './types';
import { Login } from './components/Login';
import { AdminDashboard } from './components/AdminDashboard';
import { AcademicDashboard } from './components/AcademicDashboard';
import { HRDashboard } from './components/HRDashboard';

export const App: React.FC = () => {
  const [userRole, setUserRole] = useState<UserRole>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedRole = localStorage.getItem('userRole') as UserRole;
    const storedToken = localStorage.getItem('jwtToken');

    if (storedRole && storedToken) {
      if (storedToken === 'abc123') {
        localStorage.clear();
        setUserRole(null);
      } else {
        setUserRole(storedRole);
      }
    }
    setLoading(false);
  }, []);

  const handleLogout = () => {
    localStorage.clear();
    setUserRole(null);
  };

  const renderContent = () => {
    if (loading) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-950">
          <p className="text-cyan-400">Loading...</p>
        </div>
      );
    }

    if (!userRole) {
      return <Login onLogin={setUserRole} />;
    }

    if (userRole === 'Admin') {
      return <AdminDashboard onLogout={handleLogout} />;
    }
    if (userRole === 'Academic') {
      return <AcademicDashboard onLogout={handleLogout} />;
    }
    if (userRole === 'HR') {
      return <HRDashboard onLogout={handleLogout} />;
    }

    return <Login onLogin={setUserRole} />;
  };

  return (
    <div className="relative">
      {renderContent()}
    </div>
  );
};