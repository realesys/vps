#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## For Ubuntu 24.04 LTS             ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt upgrade -y

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## NGINX                            ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo apt install -y nginx
sudo systemctl enable nginx

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## ufw                              ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo ufw allow ssh --force
sudo ufw allow 'Nginx Full' --force  # Adding --force to avoid prompts
sudo ufw enable --force

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## certbot                          ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo apt install -y certbot python3-certbot-nginx
sudo certbot renew --dry-run --non-interactive --agree-tos

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## unzip utility                    ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo apt install -y unzip

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## NODE and PM2                     ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install Node.js and npm
sudo apt install -y nodejs npm

# Install PM2 globally
sudo npm install -g pm2

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## PHP and PHP-FPM                  ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo apt install -y php-fpm php-mysql

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## ProFTPD                          ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install ProFTPD
sudo apt install -y proftpd

# Backup ProFTPD configuration
sudo cp /etc/proftpd/proftpd.conf /etc/proftpd/proftpd.conf.bak

# Configure ProFTPD for maximum security
sudo bash -c 'cat <<EOF > /etc/proftpd/proftpd.conf
# Global settings
ServerName "ProFTPD Server"
ServerType inetd
DefaultServer on

# Security settings
RequireValidShell on
RootLogin off
MaxClients 10
MaxClientsPerHost 3
ServerIdent on "ProFTPD Server v1.3.7"
UseIPv6 off
IdentLookups off
TraceLog /var/log/proftpd/traces.log

# Restrict users to their home directories
DefaultRoot ~
AllowOverwrite off

# User and Group settings
User nobody
Group nogroup
Umask 022

# Log settings
TransferLog /var/log/proftpd/xferlog
SystemLog /var/log/proftpd/proftpd.log
LogFormat default "%h %l %u %t \"%r\" %s %b"

# FTP access restrictions
<Limit LOGIN>
  DenyAll
</Limit>

<Limit ALL>
  AllowUser *  # Allow all users to connect, but restrict access further
</Limit>

# Secure FTP settings
<IfModule mod_tls.c>
  TLSEngine on
  TLSRequired on
  TLSLog /var/log/proftpd/tls.log
  TLSVerifyClient off
  TLSRSACertificateFile /etc/ssl/certs/proftpd.cert
  TLSRSACertificateKeyFile /etc/ssl/private/proftpd.key
  TLSCipherSuite ALL:!ADH:!DES:!RC4:!3DES
  TLSOptions NoCertRequest
  TLSRenegotiate ctrl 3600
</IfModule>

# Customizations for individual users
<Directory /home/*>
  <Limit WRITE>
    DenyAll
  </Limit>
</Directory>

EOF'

# Set permissions for directories and files
sudo chmod 600 /etc/proftpd/proftpd.conf
sudo chown root:root /etc/proftpd/proftpd.conf

# Create a self-signed SSL certificate for ProFTPD
sudo mkdir -p /etc/ssl/certs
sudo mkdir -p /etc/ssl/private
sudo openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.cert -days 365 -nodes -subj "/C=UK/ST=State/L=City/O=ORDE/OU=IT/CN=ftp.orde.uk"

# Set proper permissions for the SSL certificate
sudo chmod 600 /etc/ssl/private/proftpd.key
sudo chmod 644 /etc/ssl/certs/proftpd.cert

# Create necessary log directories
sudo mkdir -p /var/log/proftpd
sudo touch /var/log/proftpd/proftpd.log
sudo touch /var/log/proftpd/xferlog
sudo touch /var/log/proftpd/tls.log

# Restart ProFTPD service to apply changes
sudo systemctl restart proftpd

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## fail2ban                         ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install Fail2Ban
sudo apt install -y fail2ban

# Backup default configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure Fail2Ban
sudo bash -c 'cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
# Ban hosts for 10 minutes
bantime = 10m
# Number of retry attempts
maxretry = 5
# Findtime: Time window for detecting maxretry attempts
findtime = 10m
# Enable logging
logtarget = /var/log/fail2ban.log

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF'

# Start and enable Fail2Ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Git                              ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo apt install -y git

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Auditd                           ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install Auditd
sudo apt install -y auditd

# Enable Auditd to start on boot
sudo systemctl enable auditd
sudo systemctl start auditd

# Backup default configuration
sudo cp /etc/audit/auditd.conf /etc/audit/auditd.conf.bak

# Configure Auditd
sudo bash -c 'cat <<EOF > /etc/audit/auditd.conf
log_file = /var/log/audit/audit.log
log_format = RAW
priority_boost = 4
flush = INCREMENTAL
freq = 20
max_log_file = 50
max_log_file_action = ROTATE
space_left = 75
space_left_action = SYSLOG
action_mail_acct = root
admin_space_left = 50
admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND
EOF'

# Restart Auditd
sudo systemctl restart auditd

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## ClamAV                           ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install ClamAV and ClamAV Daemon
sudo apt install -y clamav clamav-daemon

# Update virus database
sudo freshclam

# Configure ClamAV Daemon for On-Demand Scanning
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon

# Configure Scheduled Scans (Optional)
sudo bash -c 'echo "0 3 * * * root clamscan -r /home" > /etc/cron.d/clamav-scan'

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Rootkit Detection                ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install Rkhunter
sudo apt install -y rkhunter # TODO: Fix, still Interactive

# Update Rootkit Definitions
sudo rkhunter --update

# Run a Manual Scan
sudo rkhunter --check --sk

# Schedule Daily Scans (Optional)
sudo bash -c 'echo "0 2 * * * root rkhunter --check --sk" > /etc/cron.d/rkhunter-scan'

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Install and Configure iptables   ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

# Install iptables if not already installed
sudo apt-get install -y iptables

# Set default policies to DROP all incoming and outgoing traffic
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

# Allow incoming SSH, HTTP, and HTTPS traffic
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT   # Allow SSH
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # Allow HTTP
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # Allow HTTPS

# Allow incoming traffic from the loopback interface (important for local services)
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow outgoing traffic (unless restricted by specific rules)
sudo iptables -A OUTPUT -j ACCEPT

# Save the iptables configuration so it persists across reboots
# sudo sh -c 'iptables-save > /etc/iptables/rules.v4' # BROKEN