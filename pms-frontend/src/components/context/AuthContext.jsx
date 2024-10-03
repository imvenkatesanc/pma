// import React, { createContext, useContext, useState } from 'react';
// import axios from 'axios';

// const AuthContext = createContext();

// export const AuthProvider = ({ children }) => {
//     const [user, setUser] = useState(null);
//     const [token, setToken] = useState(null);

//     const login = async (email, password) => {
//         try {
//             const response = await axios.post('http://localhost:8080/auth/login', { email, password });
            
//             // Store token and user from the response
//             setToken(response.data.token);
//             setUser(response.data.user);

//             // Save token and user in localStorage
//             localStorage.setItem('authToken', response.data.token);
//             localStorage.setItem('user', JSON.stringify(response.data.user));

//         } catch (error) {
//             console.error('Login failed:', error);
//         }
//     };

//     const register = async (userData) => {
//         try {
//             await axios.post('http://localhost:8080/auth/register', userData);
//         } catch (error) {
//             console.error('Registration failed:', error);
//         }
//     };

//     const logout = () => {
//         setUser(null);
//         setToken(null);
//         localStorage.removeItem('authToken');
//         localStorage.removeItem('user');
//     };

//     return (
//         <AuthContext.Provider value={{ user, token, login, register, logout }}>
//             {children}
//         </AuthContext.Provider>
//     );
// };

// // Hook to use the Auth context
// export const useAuth = () => useContext(AuthContext);

import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(JSON.parse(localStorage.getItem('user')));
    const [token, setToken] = useState(localStorage.getItem('authToken'));

    useEffect(() => {
        if (token) {
            axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        } else {
            delete axios.defaults.headers.common['Authorization'];
        }
    }, [token]);

    const login = async (email, password) => {
        try {
            const response = await axios.post('http://localhost:8080/auth/login', { email, password });
            
            // Store token and user from the response
            setToken(response.data.token);
            setUser(response.data.user);

            // Save token and user in localStorage
            localStorage.setItem('authToken', response.data.token);
            localStorage.setItem('user', JSON.stringify(response.data.user));

            // Set default authorization header
            axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.token}`;

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
        localStorage.removeItem('authToken');
        localStorage.removeItem('user');
        delete axios.defaults.headers.common['Authorization'];
    };

    return (
        <AuthContext.Provider value={{ user, token, login, register, logout }}>
            {children}
        </AuthContext.Provider>
    );
};

// Hook to use the Auth context
export const useAuth = () => useContext(AuthContext);
