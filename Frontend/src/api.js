import axios from 'axios';

// 1. Point to the Backend (Docker container on port 8085)
// We hardcode this for now to guarantee connection.
const API_URL = 'http://localhost:8085/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 2. Request Interceptor: Auto-attach the JWT Token
// Before every request, this function runs to check for a token.
api.interceptors.request.use(
  (config) => {
    // We look for the token in your browser's storage
    const token = localStorage.getItem('jwtToken');
    
    // If it exists, we glue it to the header like a stamp on an envelope
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 3. Response Interceptor (Optional but smart)
// If the backend says "Token Expired" (401), we can auto-logout the user.
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      console.error("Token expired or invalid. Logging out...");
      // Optional: Clear storage and redirect to login if token dies
      // localStorage.removeItem('jwtToken');
      // window.location.href = '/login'; 
    }
    return Promise.reject(error);
  }
);

export default api;
