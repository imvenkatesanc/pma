import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../components/context/AuthContext';

const ProtectedRoute = ({ children, roles }) => {
    const { user, token } = useAuth();

    if (!token || !user) {
        return <Navigate to="/login" />; // Redirect to login if not authenticated
    }

    // Role-based access check
    if (roles && roles.length > 0 && !roles.includes(user.roles[0]?.name)) {
        return <Navigate to="/unauthorized" />; // Redirect if role not allowed
    }

    return children; // Allow access if authenticated and role is valid
};

export default ProtectedRoute;
