import React, { useState, useCallback } from 'react';
import type { UserRole } from '../types';

interface LoginProps {
  onLogin: (role: UserRole) => void;
}

export const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [role, setRole] = useState<UserRole>('Admin'); 
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  
  const roles: UserRole[] = ['Admin', 'Academic', 'HR'];

  const handleAdminEnter = useCallback(() => {
    const dummyToken = 'abc123';
    localStorage.setItem('jwtToken', dummyToken);
    localStorage.setItem('userRole', 'Admin');
    localStorage.setItem('userId', '999'); 

    onLogin('Admin');
  }, [onLogin]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (role === 'Admin') {
      handleAdminEnter();
      return;
    }
    
    if (!username || !password || !role) {
      alert("Please enter credentials (any works)");
      return;
    }

    let endpoint = '';
    
    if (role === 'HR') {
        endpoint = '/api/auth/login/hr';
    } else {
        endpoint = '/api/auth/login/employee';
    }

    try {
        const response = await fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                id: Number(username), 
                password,
            }),
        });

        if (response.ok) {
            const token = await response.text(); 

            if (token && token.length > 10) {
                localStorage.setItem('jwtToken', token);
                localStorage.setItem('userRole', role as string);
                localStorage.setItem('userId', username); 
                
                onLogin(role);
            } else {
                alert("Login succeeded, but no authorization token received.");
            }
        } else {
            let message = 'Invalid credentials';
            try {
                const errorData = await response.json();
                message = errorData.message || message;
            } catch (e) {
                message = `Authentication failed (Status ${response.status})`;
            }
            alert(`Login failed: ${message}`);
        }
    } catch (error) {
        alert('A network error occurred. Please check the API server.');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 via-black to-gray-950 p-4">
      <div className="bg-gray-800/90 backdrop-blur-sm p-8 md:p-12 rounded-2xl shadow-2xl w-full max-w-md border border-cyan-700/50 hover:shadow-cyan-500/20 transition duration-500">
        <h2 className="text-3xl font-extrabold mb-8 text-center text-white tracking-tight">
          <span className="text-cyan-400">Project</span> Portal
        </h2>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">Select Role</label>
            <div className="flex gap-2 p-1 bg-gray-900 rounded-xl border border-gray-700">
              {roles.map((r) => (
                <button
                  key={r}
                  type="button"
                  onClick={() => {
                    setRole(r);
                    setUsername('');
                    setPassword('');
                  }}
                  className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
                    role === r 
                      ? 'bg-cyan-700 text-white shadow-lg' 
                      : 'text-gray-400 hover:text-white'
                  }`}
                >
                  {r}
                </button>
              ))}
            </div>
          </div>

          {role === 'Admin' ? (
            <button
              type="submit" 
              className="w-full bg-gradient-to-r from-green-600 to-green-800 text-white py-3 rounded-xl hover:from-green-500 hover:to-green-700 transition font-bold text-lg shadow-lg mt-8"
            >
              Enter Admin Dashboard
            </button>
          ) : (
            <>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">ID / Username</label>
                <input
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className="w-full px-5 py-3 bg-gray-900 border border-gray-700 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-cyan-500 transition"
                  placeholder={`Enter ${role} ID`}
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">Password</label>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-5 py-3 bg-gray-900 border border-gray-700 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-cyan-500 transition"
                  placeholder="********"
                  required
                />
              </div>
              
              <button
                type="submit"
                className="w-full bg-gradient-to-r from-cyan-600 to-cyan-800 text-white py-3 rounded-xl hover:from-cyan-500 hover:to-cyan-700 transition font-bold text-lg shadow-lg"
              >
                Login
              </button>
            </>
          )}

          {role !== 'Admin' && (
            <p className="text-center text-sm text-gray-400 mt-4">
              <span className="font-medium text-red-400">Note:</span> You can enter any credentials for testing, but they'll attempt to hit the API endpoint.
            </p>
          )}

        </form>
      </div>
    </div>
  );
};