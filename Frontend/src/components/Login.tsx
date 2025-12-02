import React, { useState } from 'react';
import type { UserRole } from '../types';

interface LoginProps {
  onLogin: (role: UserRole) => void;
}

export const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [role, setRole] = useState<UserRole>('Admin');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  
  // the options to hoose from
  const roles: UserRole[] = ['Admin', 'Academic', 'HR'];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if(username && password && role) {
      onLogin(role);
    } else {
      alert("Please enter credentials (any works)");
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
            <label className="block text-sm font-medium text-gray-300 mb-2">enter any shit, it will hopefully work</label>
            <div className="flex gap-2 p-1 bg-gray-900 rounded-xl border border-gray-700">
              {roles.map((r) => (
                <button
                  key={r}
                  type="button"
                  onClick={() => setRole(r)}
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
        </form>
      </div>
    </div>
  );
};