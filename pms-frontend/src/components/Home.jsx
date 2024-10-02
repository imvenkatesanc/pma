import React from 'react';
import Navigation from './Navigation'; // Import the Navigation component

const Home = () => {
    return (
        <header>
            <Navigation /> {/* Include the Navigation bar */}
            <main className="home__content">
                <h2>Welcome to the Property Management System</h2>
                <p>Manage your properties easily with our platform.</p>
            </main>
        </header>
    );
};

export default Home;
