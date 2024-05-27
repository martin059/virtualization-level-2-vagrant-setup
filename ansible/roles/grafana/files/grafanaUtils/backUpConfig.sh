#!/bin/bash

# Define the default backup directory
BACKUP_DIR="/home/vagrant/"

# Check if a backup directory parameter is provided and is a valid path
if [ $# -ge 1 ] && [ -d "$1" ]; then
    BACKUP_DIR="$1"
fi

# Define the container name and data container path and file name
CONTAINER_NAME="grafana"
DATA_PATH="/var/lib/grafana/"
DATA_FILE="grafana.db"

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

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup the Grafana data
docker cp "$CONTAINER_NAME:$DATA_PATH$DATA_FILE" "$BACKUP_DIR"

# Print a success message
echo "Grafana configuration backup completed successfully."