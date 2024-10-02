import React from 'react';
import { Link } from 'react-router-dom';

const ClientDashboard = () => {
    const handleLogout = () => {
        // Add your logout logic here
        console.log("User logged out");
    };

    return (
        <div className="client-dashboard">
            {/* Navigation Bar */}
            <nav className="navbar">
                <h2>Client Dashboard</h2>
                <ul>
                    <li><Link to="/client/properties">My Properties</Link></li>
                    <li><Link to="/client/requests">Requests</Link></li>
                    <li><Link to="/client/agreements">Agreements</Link></li>
                    <li><Link to="/client/profile">Profile</Link></li>
                    <li><button className="logout-btn" onClick={handleLogout}>Logout</button></li>
                </ul>
            </nav>

            {/* Main Content */}
            <div className="dashboard-content">
                <section>
                    <h3>Welcome, [Client Name]!</h3>
                    <p>Here you can manage your properties, requests, and more.</p>
                </section>

                <section className="dashboard-overview">
                    <h3>Your Overview</h3>
                    <div className="dashboard-cards">
                        <div className="card">
                            <h4>Properties</h4>
                            <p>You have X active properties.</p>
                            <Link to="/client/properties">View Properties</Link>
                        </div>
                        <div className="card">
                            <h4>Requests</h4>
                            <p>You have Y open requests.</p>
                            <Link to="/client/requests">View Requests</Link>
                        </div>
                        <div className="card">
                            <h4>Agreements</h4>
                            <p>You have Z active agreements.</p>
                            <Link to="/client/agreements">View Agreements</Link>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    );
};

export default ClientDashboard;
