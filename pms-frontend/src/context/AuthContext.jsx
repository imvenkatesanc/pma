// AuthContext.jsx
import React, { createContext, useContext, useState } from 'react';
import axios from 'axios';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [token, setToken] = useState(null);

    const login = async (email, password) => {
        try {
            const response = await axios.post('http://localhost:8080/auth/login', { email, password });
            setToken(response.data);
            setUser(email); // Or fetch user details
            localStorage.setItem('authToken', response.data); // Store token in localStorage
        } catch (error) {
            console.error('Login failed:', error);
        }
    };

    const register = async (userData) => {
        try {
            await axios.post('http://localhost:8080/auth/register', userData);
        } catch (error) {
            console.error('Registration failed:', error);
        }
    };

    const logout = () => {
        setUser(null);
        setToken(null);
        localStorage.removeItem('authToken'); // Remove token from localStorage
    };

    return (
        <AuthContext.Provider value={{ user, token, login, register, logout }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
