const API_BASE_URL = 'http://localhost:8085/api';

export const authenticatedFetch = async (endpoint: string, options: RequestInit = {}): Promise<Response> => {
    const token = localStorage.getItem('jwtToken');
    
    if (!token) {
        throw new Error("Unauthorized");
    }

    const defaultHeaders = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`, 
    };

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers: {
            ...defaultHeaders,
            ...options.headers, 
        },
    });

    if (response.status === 401 || response.status === 403) {
        localStorage.clear();
        window.location.reload();
    }

    return response;
};
