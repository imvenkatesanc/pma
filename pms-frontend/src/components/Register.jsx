import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';

const Register = () => {
    const { register } = useAuth();
    const [userData, setUserData] = useState({
        name: '',
        email: '',
        password: '',
        phoneNumber: '',
        roleIDs: []
    });
    const [error, setError] = useState(null);

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
        } catch (err) {
            setError('Registration failed. Please try again.');
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <input type="text" name="name" onChange={handleChange} placeholder="Name" required />
            <input type="email" name="email" onChange={handleChange} placeholder="Email" required />
            <input type="password" name="password" onChange={handleChange} placeholder="Password" required />
            <input type="text" name="phoneNumber" onChange={handleChange} placeholder="Phone Number" required />
            <select name="roleIDs" onChange={handleChange} required>
                <option value="">Select Role</option>
                <option value="1">Landlord</option>
                <option value="2">Client</option>
            </select>
            {error && <p>{error}</p>}
            <button type="submit">Register</button>
        </form>
    );
};

export default Register;
