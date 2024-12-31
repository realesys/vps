#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Parse Arguments                  ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

DOMAIN=""
APP_PORT=""
EMAIL=""
OWNER_USER=""
PORT=80
PORT_SSL=443

# Function to display usage
usage() {
    echo "Usage: $0 -d <domain> -p <app-port> -e <email> -u <owner-user>"
    exit 1
}

# Parse options
while getopts "d:p:e:u:h" opt; do
    case $opt in
        d) DOMAIN="$OPTARG" ;;   # Domain argument
        p) APP_PORT="$OPTARG" ;; # Application port argument
        e) EMAIL="$OPTARG" ;;    # Email argument
        u) OWNER_USER="$OPTARG" ;; # Owner user argument
        h) usage ;;              # Help flag
        *) usage ;;              # Default case for invalid arguments
    esac
done

# Check for mandatory arguments
if [ -z "$DOMAIN" ] || [ -z "$APP_PORT" ] || [ -z "$EMAIL" ] || [ -z "$OWNER_USER" ]; then
    usage
fi

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Setup                            ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Function to test and reload Nginx
test_and_reload_nginx() {
    if ! sudo nginx -t; then
        echo "Error: Nginx configuration test failed."
        exit 1
    fi
    sudo systemctl reload nginx
    echo "Nginx configuration successfully reloaded."
}

# Ensure required commands are available
if ! command -v certbot &> /dev/null || ! command -v nginx &> /dev/null; then
    echo "Error: Required command(s) certbot or nginx not found."
    exit 1
fi

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## NGINX                            ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo tee /etc/nginx/sites-available/"$DOMAIN" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        return 200 "Let's Encrypt validation in progress";
    }
}
EOF

# Enable the configuration and reload Nginx
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled

# Test Nginx configuration and reload
test_and_reload_nginx

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## certbot                          ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Create an SSL-cert group (if it doesn't exist)
if ! getent group ssl-cert > /dev/null 2>&1; then
    sudo groupadd ssl-cert
fi

sudo usermod -aG ssl-cert "$OWNER_USER"

# Obtain a Let's Encrypt SSL certificate
if ! sudo certbot certonly --nginx -d "$DOMAIN" --non-interactive --agree-tos --no-eff-email --email "$EMAIL"; then
    echo "Error: Failed to obtain SSL certificate for $DOMAIN."
    exit 1
fi

sudo chown -R "$OWNER_USER":ssl-cert /etc/letsencrypt/live/
sudo chmod 750 /etc/letsencrypt/live/
sudo chmod 750 /etc/letsencrypt/live/"$DOMAIN"/
sudo -u "$OWNER_USER" ls /etc/letsencrypt/live/"$DOMAIN"/

# Add a cron job for automatic renewal (as root)
if ! (sudo crontab -l | grep -q "certbot renew"); then
    echo "0 0 * * * certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null
fi

echo "Setup complete for domain: $DOMAIN"

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## NGINX                            ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Create an Nginx server block configuration file with SSL
sudo tee /etc/nginx/sites-available/"$DOMAIN" > /dev/null <<EOF
server {
    listen $PORT;
    server_name $DOMAIN;

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen $PORT_SSL ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Test Nginx configuration and reload
test_and_reload_nginx