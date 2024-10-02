import { Routes, Route} from 'react-router-dom';
import ProtectedRoute from './routes/ProtectedRoute';
import LandlordDashboard from './components/dashboard/LandlordDashboard';
import ClientDashboard from './components/dashboard/ClientDashboard';
import Login from './components/auth/Login';
import Register from './components/auth/Register';
import Home from './components/Home';
import NotFound from './components/NotFound';
import Unauthorized from './components/Unauthorized'; // Page for unauthorized access
import './index.css';

function App() {
    return (
        <Routes>
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
            
            {/* Unauthorized access route */}
            <Route path="/unauthorized" element={<Unauthorized />} />
            
            {/* Catch-all route for unmatched paths */}
            <Route path="*" element={<NotFound />} />
        </Routes>
    );
}

export default App;