#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## MySQL Setup                      ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "Error: MySQL is not installed. Please install MySQL and try again."
    exit 1
fi

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Parse Arguments                  ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

DB_NAME=""
USER_NAME=""

# Function to display usage
usage() {
    echo "Usage: $0 -d <db-name> -u <db-username>"
    exit 1
}

# Parse options
while getopts "d:u:w:h" opt; do
    case $opt in
        d) DB_NAME="$OPTARG" ;;  # Database name
        u) USER_NAME="$OPTARG" ;;  # Database username
        h) usage ;;  # Help flag
        *) usage ;;  # Default case for invalid arguments
    esac
done

# Check if arguments are provided
if [ -z "$DB_NAME" ] || [ -z "$USER_NAME" ]; then
    echo "Error: Database name, username, and password are required."
    usage
fi

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

# Prompt for MySQL user password
USER_PASSWORD=$(prompt_password "MySQL user")

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## MySQL Setup                      ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Log into MySQL with the root password and create the database and user
sudo mysql -u root -p"$ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$USER_NAME'@'localhost' IDENTIFIED BY '$USER_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$USER_NAME'@'localhost';
FLUSH PRIVILEGES;
EOF

# Check if the MySQL commands succeeded
if [ $? -eq 0 ]; then
    echo "Database '$DB_NAME' and user '$USER_NAME' created successfully with granted privileges."
else
    echo "Error: Failed to create database and user."
    exit 1
fi

echo "Setup complete for database '$DB_NAME' and user '$USER_NAME'."

