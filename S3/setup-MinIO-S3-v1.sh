#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Parse Arguments for setup-MinIO-S3-v1.sh  ##
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

MNT_DIR=""
ROOT_USER=""
ROOT_PASSWORD=""

# Function to display usage
usage() {
    echo "Usage: $0 -d <mnt-dir> -u <root-user> -p <root-password>"
    exit 1
}

# Parse options
while getopts "d:u:p:h" opt; do
    case $opt in
        d) MNT_DIR="$OPTARG" ;;   # Mount directory argument
        u) ROOT_USER="$OPTARG" ;;   # Minio root user
        p) ROOT_PASSWORD="$OPTARG" ;;   # Minio root password
        h) usage ;;               # Help flag
        *) usage ;;               # Default case for invalid arguments
    esac
done

# Check for mandatory arguments
if [ -z "$MNT_DIR" ] || [ -z "$ROOT_USER" ] || [ -z "$ROOT_PASSWORD" ]; then
    usage
fi


# Install MinIO binary
echo "Downloading and installing MinIO..."
sudo wget https://realesys.github.io/vps/S3/minio_20250218162555.0.0_amd64.deb -O minio.deb
sudo dpkg -i minio.deb

# Create the mount directory if it doesn't exist
echo "Creating mount directory $MNT_DIR..."

sudo useradd -r minio -s /sbin/nologin
sudo mkdir -p "$MNT_DIR"
sudo chown -R minio:minio "$MNT_DIR"

# Create the configuration files
sudo tee /etc/systemd/system/minio.service > /dev/null <<EOF
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local

User=minio
Group=minio
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use `After=minio.server`
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
EOF

sudo tee /etc/default/minio > /dev/null <<EOF
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment

MINIO_ROOT_USER=$ROOT_USER
MINIO_ROOT_PASSWORD=$ROOT_PASSWORD

# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.

MINIO_VOLUMES="$MNT_DIR"

# MINIO_OPTS sets any additional commandline options to pass to the MinIO server.
# For example, `--console-address :9001` sets the MinIO Console listen port
#MINIO_OPTS="--console-address :9000"
EOF

# Start MinIO server
echo "Starting MinIO server with $MNT_DIR..."
# Start MinIO as a background process
sudo systemctl daemon-reload
sudo systemctl start minio
sudo systemctl enable minio

# Allow webui and API ports
sudo ufw allow 9000/tcp

echo "MinIO server is running. Access it at http://localhost:9000"
