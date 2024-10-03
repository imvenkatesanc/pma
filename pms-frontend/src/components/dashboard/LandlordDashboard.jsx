import React from 'react';
import { Link } from 'react-router-dom';
import Navigation from '../Navigation';

const LandlordDashboard = () => {
    return (
        <div className="landlord-dashboard">
            {/* Navigation Bar */}
            <Navigation/>

            {/* Main Content */}
            <div className="dashboard-content">
                <section>
                    <h3>Welcome, [Landlord Name]!</h3>
                    <p>Here you can manage your properties, tenant requests, and agreements.</p>
                </section>

                <section className="dashboard-overview">
                    <h3>Your Overview</h3>
                    <div className="dashboard-cards">
                        <div className="card">
                            <h4>Properties</h4>
                            <p>You have X properties listed.</p>
                            <Link to="/landlord/properties">Manage Properties</Link>
                        </div>
                        <div className="card">
                            <h4>Tenant Requests</h4>
                            <p>You have Y pending requests.</p>
                            <Link to="/landlord/requests">View Requests</Link>
                        </div>
                        <div className="card">
                            <h4>Agreements</h4>
                            <p>You have Z active agreements.</p>
                            <Link to="/landlord/agreements">View Agreements</Link>
                        </div>
                        <div className="card">
                            <h4>Transactions</h4>
                            <p>View recent transactions for your properties.</p>
                            <Link to="/landlord/transactions">View Transactions</Link>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    );
};

export default LandlordDashboard;
