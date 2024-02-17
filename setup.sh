#!/bin/bash

# Ensure the script is executed with root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install NVM (Node Version Manager) and Node.js
echo "Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install node

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# PostgreSQL service commands remain the same (systemctl is used across both yum and apt systems)
echo "Initializing PostgreSQL..."
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

# Optional: Install Material-UI if it's not already in your package.json
# npm install @material-ui/core

# Setting up Express server to serve React build files
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
