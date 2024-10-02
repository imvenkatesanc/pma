import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate, Link } from 'react-router-dom';
import pmsLogo from '../../assets/pms_logo.png';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSignInAlt,faUser } from '@fortawesome/free-solid-svg-icons';

const Register = () => {
    const { register } = useAuth();
    const navigate = useNavigate();
    const [userData, setUserData] = useState({
        name: '',
        email: '',
        password: '',
        phoneNumber: '',
        roleIDs: []
    });
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(false);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setUserData((prevData) => ({
            ...prevData,
            [name]: name === 'roleIDs' ? [parseInt(value)] : value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            await register(userData);
            setSuccess(true);
            setTimeout(() => navigate('/login'), 2000); // Redirect after 2 seconds
        } catch (err) {
            setError('Registration failed. Please try again.');
        }
    };

    return (
        <div className="auth-container">
            <div className="auth-card">
                <img src={pmsLogo} alt="Logo" className="auth-logo" />
                <h2 className='auth-title'>Welcome to PMS</h2>
                <h3 className="auth-title">
                    <FontAwesomeIcon className='fa-user' icon={faUser} />
                </h3>
                <form onSubmit={handleSubmit}>
                    <input
                        type="text"
                        name="name"
                        onChange={handleChange}
                        placeholder="Name"
                        required
                        className="auth-input"
                    />
                    <input
                        type="email"
                        name="email"
                        onChange={handleChange}
                        placeholder="Email"
                        required
                        className="auth-input"
                    />
                    <input
                        type="password"
                        name="password"
                        onChange={handleChange}
                        placeholder="Password"
                        required
                        className="auth-input"
                    />
                    <input
                        type="text"
                        name="phoneNumber"
                        onChange={handleChange}
                        placeholder="Phone Number"
                        required
                        className="auth-input"
                    />
                    <select name="roleIDs" onChange={handleChange} required className="auth-input">
                        <option value="">Select Role</option>
                        <option value="1">Landlord</option>
                        <option value="2">Client</option>
                    </select>
                    {error && <p className="error-message">{error}</p>}
                    {success && <p className="success-message">Registration successful! Redirecting to login...</p>}
                    <button type="submit" className="auth-button">
                        <FontAwesomeIcon className="fa-sign" icon={faSignInAlt} />Register
                    </button>
                </form>
                <p className="auth-link">
                    Already have an account? <Link to="/login">Login</Link>
                </p>
            </div>
        </div>
    );
};

export default Register;
