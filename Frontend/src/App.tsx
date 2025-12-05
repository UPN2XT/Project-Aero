import React, { useState, useEffect } from 'react';
import { Toaster } from 'react-hot-toast';
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
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 4000,
          style: {
            background: '#1f2937',
            color: '#fff',
            border: '1px solid #374151',
          },
        }}
      />
      {renderContent()}
    </div>
  );
};