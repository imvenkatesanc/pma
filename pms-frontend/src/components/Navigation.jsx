import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from './context/AuthContext'; // Assuming the context is in context/AuthContext
import logo from '../assets/pms_logo.png'; // Update this path to your logo
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faHome } from '@fortawesome/free-solid-svg-icons';

const Navigation = () => {
    const { user, token, logout } = useAuth();

    return (
        <nav className="navbar">
            <div className="navbar__logo">
                <img src={logo} alt="Property Management System Logo" className="navbar__logo-image" />
            </div>
            <Link to="/" className="navbar__link">
            <FontAwesomeIcon className='fa-home' icon={faHome} />Home
            </Link>
            {!token ? (
                <div className="navbar__auth-links">
                    <Link to="/login" className="btn">Login</Link>
                    <Link to="/register" className="btn">Register</Link>
                </div>
            ) : (
                <div className="navbar__dashboard-links">
                    {user.roles[0].name === 'landlord' && <Link to="/landlord-dashboard" className="btn">Landlord Dashboard</Link>}
                    {user.roles[0].name === 'client' && <Link to="/client-dashboard" className="btn">Client Dashboard</Link>}
                    <button onClick={logout} className="btn logout-btn">Logout</button>
                </div>
            )}
        </nav>
    );
};

export default Navigation;
