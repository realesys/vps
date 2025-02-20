#!/bin/bash

# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# ## Parse Arguments for setup-MinIO-S3-v1.sh  ##
# ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

MNT_DIR=""
OWNER_USER=""

# Function to display usage
usage() {
    echo "Usage: $0 -d <mnt-dir> -u <owner-user>"
    exit 1
}

# Parse options
while getopts "d:u:h" opt; do
    case $opt in
        d) MNT_DIR="$OPTARG" ;;   # Mount directory argument
        u) OWNER_USER="$OPTARG" ;; # Owner user argument
        h) usage ;;               # Help flag
        *) usage ;;               # Default case for invalid arguments
    esac
done

# Check for mandatory arguments
if [ -z "$MNT_DIR" ] || [ -z "$OWNER_USER" ]; then
    usage
fi

# Validate OWNER_USER exists
if ! id "$OWNER_USER" &>/dev/null; then
    echo "User '$OWNER_USER' does not exist. Please provide a valid user."
    exit 1
fi

# Install MinIO binary
echo "Downloading and installing MinIO..."
sudo wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20250218162555.0.0_amd64.deb -O minio.deb
sudo dpkg -i minio.deb

# Create the mount directory if it doesn't exist
echo "Creating mount directory $MNT_DIR..."
sudo mkdir -p "$MNT_DIR"
sudo chown -R "$OWNER_USER:$OWNER_USER" "$MNT_DIR"

# Start MinIO server
echo "Starting MinIO server with $MNT_DIR..."
# Start MinIO as a background process
nohup minio server "$MNT_DIR" > /dev/null 2>&1 &

echo "MinIO server is running. Access it at http://localhost:9000"
