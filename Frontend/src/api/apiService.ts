const API_BASE_URL = '/api';

export const authenticatedFetch = async (endpoint: string, options: RequestInit = {}): Promise<Response> => {
    const token = localStorage.getItem('jwtToken');
    
    if (!token) {
        console.error("Authentication token is missing. Redirecting to login.");
        throw new Error("Unauthorized");
    }

    const defaultHeaders = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`, 
    };

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers: {
                ...defaultHeaders,
                ...options.headers, 
            },
        });

        if (response.status === 401 || response.status === 403) {
            localStorage.clear();
            alert("Session expired. Please log in again.");
            window.location.reload(); 
        }

        return response;
    } catch (error) {
        console.error("API Call failed:", error);
        throw error;
    }
};