import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate, Link } from 'react-router-dom';
import pmsLogo from '../../assets/pms_logo.png';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSignInAlt,faUser } from '@fortawesome/free-solid-svg-icons';

const Login = () => {
    const { login, user, token } = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState(null);
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);

        try {
            await login(email, password);

            if (user && token) {
                if (user.roles && user.roles.length > 0) {
                    const userRole = user.roles[0]?.name?.toLowerCase();
                    if (userRole === 'landlord') {
                        navigate('/landlord-dashboard');
                    } else if (userRole === 'client') {
                        navigate('/client-dashboard');
                    } else {
                        setError('Invalid role.');
                    }
                } else {
                    setError('User has no assigned roles.');
                }
            } else {
                setError('Login failed. Please check your credentials.');
            }
        } catch (err) {
            setError('Login failed. Please try again.');
            console.error(err);
        }
    };

    return (
        <div className="auth-container">
            <div className="auth-card">
                <div className="auth-header">
                    <img src={pmsLogo} alt="Logo" className="auth-logo" />
                    <h2 className='auth-title'>Welcome to PMS</h2>
                    <h3 className="auth-title">
                        <FontAwesomeIcon className='fa-user' icon={faUser} />
                    </h3>
                </div>
                <form onSubmit={handleSubmit}>
                    <input
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="Email"
                        className="auth-input"
                        required
                    />
                    <input
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="Password"
                        className="auth-input"
                        required
                    />
                    <button type="submit" className="auth-button">
                        <FontAwesomeIcon className="fa-sign" icon={faSignInAlt} /> Login
                    </button>
                    {error && <p className="error-message">{error}</p>}
                </form>
                <p className="auth-link">
                    Don't have an account? <Link to="/register">Register</Link>
                </p>
            </div>
        </div>
    );    
};

export default Login;