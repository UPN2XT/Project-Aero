import toast from 'react-hot-toast';

/**
 * Themed toast notifications matching the dark cyan aesthetic
 */

const toastStyles = {
    success: {
        style: {
            background: '#1f2937',
            color: '#10b981',
            border: '1px solid #10b98150',
            boxShadow: '0 0 20px rgba(16, 185, 129, 0.3)',
        },
        iconTheme: {
            primary: '#10b981',
            secondary: '#1f2937',
        },
    },
    error: {
        style: {
            background: '#1f2937',
            color: '#ef4444',
            border: '1px solid #ef444450',
            boxShadow: '0 0 20px rgba(239, 68, 68, 0.3)',
        },
        iconTheme: {
            primary: '#ef4444',
            secondary: '#1f2937',
        },
    },
    info: {
        style: {
            background: '#1f2937',
            color: '#06b6d4',
            border: '1px solid #06b6d450',
            boxShadow: '0 0 20px rgba(6, 182, 212, 0.3)',
        },
        iconTheme: {
            primary: '#06b6d4',
            secondary: '#1f2937',
        },
    },
};

export const showSuccess = (message: string) => {
    toast.success(message, {
        duration: 4000,
        ...toastStyles.success,
    });
};

export const showError = (message: string) => {
    toast.error(message, {
        duration: 5000,
        ...toastStyles.error,
    });
};

export const showInfo = (message: string) => {
    toast(message, {
        duration: 4000,
        icon: 'ℹ️',
        ...toastStyles.info,
    });
};

// For backward compatibility - maps to showInfo
export const showMessage = (message: string, isError = false) => {
    if (isError) {
        showError(message);
    } else {
        showSuccess(message);
    }
};
