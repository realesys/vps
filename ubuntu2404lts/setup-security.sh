#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## For Ubuntu 24.04 LTS             ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt upgrade -y

# ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## unzip utility                    ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo apt install -y unzip

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
# ## ufw                              ##
# ## ## ## ## ## ## ## ## ## ## ## ## ##

sudo ufw allow ssh
sudo ufw allow 'Nginx Full'  # Adding --force to avoid prompts
sudo ufw --force enable
