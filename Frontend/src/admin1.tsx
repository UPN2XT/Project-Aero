import { useState } from 'react';
import type { FormEvent, ChangeEvent } from 'react';

function Admin1() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleUsernameChange = (event: ChangeEvent<HTMLInputElement>) => {
    setUsername(event.target.value);
  };

  const handlePasswordChange = (event: ChangeEvent<HTMLInputElement>) => {
    setPassword(event.target.value);
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault(); 
    
    alert(`Logging in as ${username}...`); 
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 via-black to-gray-950 p-4">
      <div className="bg-gray-800/90 backdrop-blur-sm p-12 rounded-2xl shadow-3xl w-full max-w-md border border-cyan-700/50 transform transition duration-500 hover:shadow-cyan-500/30">
        
        <h2 className="text-3xl font-extrabold mb-10 text-center text-white tracking-tight drop-shadow-lg">
          <span className="text-cyan-400">Admin</span> Panel
        </h2>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          
          {/* Username Input */}
          <div>
            <label htmlFor="username" className="block text-sm font-medium text-gray-300 mb-2">Username</label>
            <input
              id="username"
              type="text"
              placeholder="Enter your admin id"
              className="w-full px-5 py-3 bg-gray-900 border border-gray-700 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:ring-4 focus:ring-cyan-600 focus:border-cyan-400 transition duration-300"
              value={username}
              onChange={handleUsernameChange}
              required
            />
          </div>
          
          {/* Password Input */}
          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-300 mb-2">Password</label>
            <input
              id="password"
              type="password"
              placeholder="Enter your admin password"
              className="w-full px-5 py-3 bg-gray-900 border border-gray-700 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:ring-4 focus:ring-cyan-600 focus:border-cyan-400 transition duration-300"
              value={password}
              onChange={handlePasswordChange}
              required
            />
          </div>
          
          {/* Submit Button */}
          <button
            type="submit"
            className="w-full bg-gradient-to-r from-cyan-600 to-cyan-800 text-white py-3 rounded-xl hover:from-cyan-500 hover:to-cyan-700 transition duration-300 ease-in-out font-bold text-lg shadow-xl hover:shadow-cyan-500/40 transform hover:-translate-y-0.5"
          >
            Authenticate
          </button>
        </form>
        
        {/* Forgot Password Link */}
        <div className="text-center mt-8 text-sm">
            <a href="#" className="text-cyan-400 hover:text-cyan-200 font-medium transition duration-150">
              Forgot Admin Password?
            </a>
        </div>
      </div>
    </div>
  );
}

export default Admin1;