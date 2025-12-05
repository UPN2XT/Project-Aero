import React, { useState, useEffect, useRef } from 'react';
import { Shield, User, Lock, LogIn, Building2, GraduationCap, Users, Sparkles } from 'lucide-react';
import type { UserRole } from '../types';
import { showError } from '../utils/toast';

interface LoginProps {
  onLogin: (role: UserRole) => void;
}

export const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [role, setRole] = useState<UserRole>('Admin');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const [isLoading, setIsLoading] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [ripples, setRipples] = useState<Array<{ x: number; y: number; id: number }>>([]);
  const containerRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  const roles: UserRole[] = ['Admin', 'Academic', 'HR'];

  // Track mouse position for interactive background
  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (containerRef.current) {
        const rect = containerRef.current.getBoundingClientRect();
        setMousePosition({
          x: e.clientX - rect.left,
          y: e.clientY - rect.top,
        });
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  // Create ripple effect
  const createRipple = (e: React.MouseEvent<HTMLButtonElement>) => {
    if (!buttonRef.current) return;

    const rect = buttonRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const id = Date.now();

    setRipples(prev => [...prev, { x, y, id }]);

    setTimeout(() => {
      setRipples(prev => prev.filter(ripple => ripple.id !== id));
    }, 600);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!username || !password || !role) {
      showError("Please enter credentials");
      return;
    }

    setIsLoading(true);

    let endpoint = '';

    if (role === 'HR' || role === 'Admin') {
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

          // Show success animation
          setShowSuccess(true);
          setTimeout(() => {
            onLogin(role);
          }, 1500);
        } else {
          setIsLoading(false);
          showError("Login succeeded, but no authorization token received.");
        }
      } else {
        setIsLoading(false);
        let message = 'Invalid credentials';
        try {
          const errorData = await response.json();
          message = errorData.message || message;
        } catch (e) {
          message = `Authentication failed (Status ${response.status})`;
        }
        showError(`Login failed: ${message}`);
      }
    } catch (error) {
      setIsLoading(false);
      showError('A network error occurred. Please check the API server.');
    }
  };

  const getRoleIcon = (r: UserRole) => {
    switch (r) {
      case 'Admin':
        return <Shield className="w-4 h-4 transition-transform group-hover:rotate-12" />;
      case 'Academic':
        return <GraduationCap className="w-4 h-4 transition-transform group-hover:rotate-12" />;
      case 'HR':
        return <Users className="w-4 h-4 transition-transform group-hover:scale-110" />;
      default:
        return <User className="w-4 h-4" />;
    }
  };

  return (
    <div
      ref={containerRef}
      className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 via-black to-gray-950 p-4 relative overflow-hidden"
    >
      {/* Interactive background gradient that follows mouse */}
      <div
        className="absolute inset-0 opacity-20 transition-opacity duration-300 pointer-events-none"
        style={{
          background: `radial-gradient(800px circle at ${mousePosition.x}px ${mousePosition.y}px, rgba(6, 182, 212, 0.4), transparent 40%)`,
        }}
      />

      {/* Animated floating particles */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {[...Array(20)].map((_, i) => (
          <div
            key={i}
            className="absolute rounded-full bg-cyan-400/10"
            style={{
              width: `${Math.random() * 4 + 2}px`,
              height: `${Math.random() * 4 + 2}px`,
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animation: `float ${Math.random() * 10 + 10}s linear infinite`,
              animationDelay: `${Math.random() * 5}s`,
            }}
          />
        ))}
      </div>

      {/* Success Confetti */}
      {showSuccess && (
        <div className="absolute inset-0 pointer-events-none z-50">
          {[...Array(50)].map((_, i) => (
            <div
              key={i}
              className="absolute"
              style={{
                left: `${Math.random() * 100}%`,
                top: '-10%',
                animation: `confetti ${Math.random() * 2 + 2}s ease-out forwards`,
                animationDelay: `${Math.random() * 0.3}s`,
              }}
            >
              <Sparkles
                className="text-cyan-400"
                style={{
                  width: `${Math.random() * 20 + 10}px`,
                  height: `${Math.random() * 20 + 10}px`,
                }}
              />
            </div>
          ))}
        </div>
      )}

      {/* Login Card */}
      <div className="bg-gray-800/40 backdrop-blur-xl p-8 md:p-12 rounded-3xl shadow-2xl w-full max-w-md border border-cyan-500/20 hover:border-cyan-500/40 transition-all duration-500 relative z-10">
        {/* Header with icon */}
        <div className="text-center mb-8">
          <h2 className="text-4xl font-extrabold text-white tracking-tight">
            <span className="bg-gradient-to-r from-cyan-400 to-blue-500 bg-clip-text text-transparent">Project</span> AERO
          </h2>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Role Selection */}
          <div>
            <label className="block text-sm font-semibold text-gray-300 mb-3 flex items-center gap-2">
              <Building2 className="w-4 h-4 text-cyan-400 animate-pulse" />
              Select Your Role
            </label>
            <div className="flex gap-2 p-1.5 bg-gray-900/50 rounded-xl border border-gray-700/50 backdrop-blur-sm">
              {roles.map((r) => (
                <button
                  key={r}
                  type="button"
                  onClick={() => {
                    setRole(r);
                    setUsername('');
                    setPassword('');
                  }}
                  className={`group flex-1 py-2.5 rounded-lg text-sm font-semibold transition-all duration-300 flex items-center justify-center gap-2 ${role === r
                    ? 'bg-gradient-to-r from-cyan-600 to-blue-600 text-white shadow-lg shadow-cyan-500/30 scale-105'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800/50'
                    }`}
                >
                  {getRoleIcon(r)}
                  {r}
                </button>
              ))}
            </div>
          </div>

          {role && /Admin|Academic|HR/.test(role) && (
            <>
              {/* Username Input */}
              <div className="space-y-2">
                <label className="block text-sm font-semibold text-gray-300 flex items-center gap-2">
                  <User className="w-4 h-4 text-cyan-400 transition-transform hover:scale-125" />
                  ID / Username
                </label>
                <div className="relative group">
                  <input
                    type="text"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    className="w-full px-5 py-3.5 bg-gray-900/50 border border-gray-700/50 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:border-transparent focus:shadow-lg focus:shadow-cyan-500/20 transition-all duration-300 backdrop-blur-sm placeholder-gray-500 focus:scale-[1.01]"
                    placeholder={`Enter ${role || 'User'} ID`}
                    required
                  />
                  <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-cyan-500/0 via-cyan-500/10 to-cyan-500/0 opacity-0 group-hover:opacity-100 group-focus-within:opacity-100 transition-opacity pointer-events-none animate-shimmer" />
                </div>
              </div>

              {/* Password Input */}
              <div className="space-y-2">
                <label className="block text-sm font-semibold text-gray-300 flex items-center gap-2">
                  <Lock className="w-4 h-4 text-cyan-400 transition-transform hover:scale-125 hover:rotate-12" />
                  Password
                </label>
                <div className="relative group">
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full px-5 py-3.5 bg-gray-900/50 border border-gray-700/50 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:border-transparent focus:shadow-lg focus:shadow-cyan-500/20 transition-all duration-300 backdrop-blur-sm placeholder-gray-500 focus:scale-[1.01]"
                    placeholder="••••••••"
                    required
                  />
                  <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-cyan-500/0 via-cyan-500/10 to-cyan-500/0 opacity-0 group-hover:opacity-100 group-focus-within:opacity-100 transition-opacity pointer-events-none animate-shimmer" />
                </div>
              </div>

              {/* Login Button */}
              <button
                ref={buttonRef}
                type="submit"
                disabled={isLoading}
                onClick={createRipple}
                className="relative overflow-hidden w-full bg-gradient-to-r from-cyan-600 via-blue-600 to-cyan-600 text-white py-3.5 rounded-xl hover:shadow-lg hover:shadow-cyan-500/50 transition-all duration-300 font-bold text-lg flex items-center justify-center gap-2 group hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed bg-size-200 bg-pos-0 hover:bg-pos-100"
                style={{
                  backgroundSize: '200% 100%',
                }}
              >
                {/* Ripple effects */}
                {ripples.map(ripple => (
                  <span
                    key={ripple.id}
                    className="absolute bg-white/30 rounded-full animate-ripple"
                    style={{
                      left: ripple.x,
                      top: ripple.y,
                      width: '0px',
                      height: '0px',
                    }}
                  />
                ))}

                {isLoading ? (
                  <>
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Signing In...
                  </>
                ) : (
                  <>
                    <LogIn className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                    Sign In
                  </>
                )}
              </button>
            </>
          )}
        </form>

        {/* Footer decoration */}
        <div className="mt-8 pt-6 border-t border-gray-700/50">
          <p className="text-center text-xs text-gray-500 flex items-center justify-center gap-1">
            <Shield className="w-3 h-3" />
            Secured by Some Guc Students
          </p>
        </div>
      </div>

      {/* CSS for animations */}
      <style>{`
        @keyframes float {
          0%, 100% {
            transform: translateY(0) translateX(0);
          }
          25% {
            transform: translateY(-20px) translateX(10px);
          }
          50% {
            transform: translateY(-10px) translateX(-10px);
          }
          75% {
            transform: translateY(-30px) translateX(5px);
          }
        }
        
        @keyframes ripple {
          to {
            width: 500px;
            height: 500px;
            opacity: 0;
            transform: translate(-50%, -50%);
          }
        }
        
        @keyframes confetti {
          0% {
            transform: translateY(0) rotate(0deg);
            opacity: 1;
          }
          100% {
            transform: translateY(100vh) rotate(720deg);
            opacity: 0;
          }
        }
        
        @keyframes shimmer {
          0% {
            background-position: -200% 0;
          }
          100% {
            background-position: 200% 0;
          }
        }
        
        .animate-shimmer {
          background-size: 200% 100%;
          animation: shimmer 3s linear infinite;
        }
        
        .bg-size-200 {
          background-size: 200% 100%;
        }
        
        .bg-pos-0 {
          background-position: 0% 0%;
        }
        
        .bg-pos-100 {
          background-position: 100% 0%;
        }
        
        button:hover.bg-size-200 {
          background-position: 100% 0%;
        }
      `}</style>
    </div>
  );
};