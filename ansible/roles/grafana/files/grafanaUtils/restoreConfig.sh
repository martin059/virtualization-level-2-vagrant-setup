#!/bin/bash

# Define the default backup directory
BACKUP_DIR="/home/vagrant/"

# Check if a backup directory parameter is provided and is a valid path
if [ $# -ge 1 ] && [ -d "$1" ]; then
    BACKUP_DIR="$1"
fi

# Check if a password parameter is provided
if [ $# -ge 2 ]; then
    PASSWORD="$2"
fi

# Define the container name and data container path and file name
CONTAINER_NAME="grafana"
DATA_PATH="/var/lib/grafana/"
DATA_FILE="grafana.db"
ENCRYPTED_FILE="grafana.db.zip"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Check if the "grafana" container exists
if ! docker ps -a --format '{{.Names}}' | ack "^grafana$"; then
    echo "The 'grafana' container does not exist. Please make sure the container is running before running this script."
    exit 1
fi

# Check if the backup file exists
if [ ! -f "$BACKUP_DIR$ENCRYPTED_FILE" ]; then
    if [ ! -f "$BACKUP_DIR$DATA_FILE" ]; then
        echo "No backup file '$BACKUP_DIR$DATA_FILE' or $BACKUP_DIR$ENCRYPTED_FILE was found. Please make sure the file is available before running this script."
        exit 1
    else
        BU_ENCRYPTED=false
    fi
else
    BU_ENCRYPTED=true
fi

# Unzip the file if it is encrypted
if [ "$BU_ENCRYPTED" = true ]; then
    unzip -P "$PASSWORD" "$BACKUP_DIR$ENCRYPTED_FILE" -d "$BACKUP_DIR"
fi

# Load backup the Grafana data
docker cp "$BACKUP_DIR$DATA_FILE" "$CONTAINER_NAME:$DATA_PATH"

# Fix ownership
docker exec -u root $CONTAINER_NAME chown grafana:root $DATA_PATH$DATA_FILE

echo "Restarting Grafana..."

# Restart the Grafana container
docker restart "$CONTAINER_NAME"

# Print a success message
echo "Grafana configuration backup loaded successfully."