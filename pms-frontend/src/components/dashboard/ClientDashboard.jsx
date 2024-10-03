import React from 'react';
import { Link } from 'react-router-dom';
import Navigation from '../Navigation';

const ClientDashboard = () => {
    const handleLogout = () => {
        // Add your logout logic here
        console.log("User logged out");
    };

    return (
        <div className="client-dashboard">
            {/* Navigation Bar */}
            <Navigation/>

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
