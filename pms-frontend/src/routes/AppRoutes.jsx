import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Home from '../components/Home'; // Landing Page
import Login from '../components/auth/Login'; // Login Component
import Register from '../components/auth/Register'; // Register Component
import LandlordDashboard from '../components/dashboard/LandlordDashboard'; // Landlord Dashboard
import ClientDashboard from '../components/dashboard/ClientDashboard'; // Client Dashboard
import Unauthorized from '../components/Unauthorized'; // Unauthorized access page
import ProtectedRoute from './ProtectedRoute'; // HOC for protecting routes

const AppRoutes = () => {
  return (
    <Routes>
      {/* Public Routes */}
      <Route path="/" element={<Home />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      
      {/* Protected Routes */}
      <Route
        path="/landlord-dashboard"
        element={
          <ProtectedRoute roles={['landlord']}>
            <LandlordDashboard />
          </ProtectedRoute>
        }
      />
      <Route
        path="/client-dashboard"
        element={
          <ProtectedRoute roles={['client']}>
            <ClientDashboard />
          </ProtectedRoute>
        }
      />
      
      {/* Catch-all Unauthorized Route */}
      <Route path="/unauthorized" element={<Unauthorized />} />
    </Routes>
  );
};

export default AppRoutes;
