#!/bin/bash

# Ensure the script is executed with root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install NVM (Node Version Manager) and Node.js
echo "Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.nvm/nvm.sh
nvm install node

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo yum install -y postgresql postgresql-server

# Initialize DB and start PostgreSQL
echo "Initializing PostgreSQL..."
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Install PM2 globally
echo "Installing PM2..."
sudo npm install pm2 -g

# Clone project repository (Ensure you replace <YOUR_PROJECT_REPO_URL>)
echo "Cloning project repository..."
git clone <YOUR_PROJECT_REPO_URL> myapp
cd myapp

# Install project dependencies including React, Material-UI, Express
echo "Installing project dependencies..."
npm install

# If Material-UI is not already in your package.json dependencies, uncomment the following line:
# npm install @material-ui/core

# Configure Express server in your project as needed
# Example server configuration is provided below. This assumes you have an Express setup ready.
# If you're dynamically creating a server file, adjust paths and logic as per your project structure

# Example: Dynamically creating a simple Express server file to serve React build files
echo "Setting up Express server to serve React build files..."
cat > ./server.js <<EOL
const express = require('express');
const path = require('path');
const PORT = process.env.PORT || 3000;

const app = express();

// Serve static files from the React app build directory
app.use(express.static(path.join(__dirname, 'build')));

// Handles any requests that don't match the ones above
app.get('*', (req,res) =>{
    res.sendFile(path.join(__dirname+'/build/index.html'));
});

app.listen(PORT, () => {
    console.log(\`Server is running on port \${PORT}\`);
});
EOL

# Build your React application (if this step is part of your workflow)
echo "Building React application..."
npm run build

# Start the application using PM2
echo "Starting application with PM2..."
pm2 start server.js
pm2 startup systemd
pm2 save

echo "Express server setup and application deployment completed successfully!"
