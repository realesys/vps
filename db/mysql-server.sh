#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Password Prompts                 ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Function to securely prompt for a password without echoing
prompt_password() {
    local password
    local password_confirm

    # Prompt for the password
    while true; do
        read -sp "Enter password for $1: " password
        echo
        read -sp "Confirm password for $1: " password_confirm
        echo

        # Check if the passwords match
        if [ "$password" == "$password_confirm" ]; then
            echo "Password confirmed for $1."
            echo "$password"
            return 0
        else
            echo "Error: Passwords do not match. Please try again."
        fi
    done
}

# Prompt for MySQL root password
ROOT_PASSWORD=$(prompt_password "MySQL root")

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Install MySQL                    ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install MySQL server and client (also includes necessary client libraries)
sudo apt install -y mysql-server mysql-client-core-8.0

# Set MySQL root password using debconf
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOT_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOT_PASSWORD"

# Ensure the MySQL service starts after installation
sudo systemctl enable mysql
sudo systemctl start mysql

# Confirm MySQL is running
if sudo systemctl status mysql | grep -q "active (running)"; then
    echo "MySQL installation complete and running."
else
    echo "MySQL installation failed or not running."
    exit 1
fi

# Confirm MySQL client is installed and working
if command -v mysql &>/dev/null; then
    echo "MySQL client is installed and ready to use."
else
    echo "MySQL client installation failed."
    exit 1
fi

# Optionally, print MySQL version to verify installation
mysql --version