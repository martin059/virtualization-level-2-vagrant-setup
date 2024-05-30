#!/bin/bash

# Define the default backup directory
WORK_DIR="/home/vagrant/"

# Check if a backup directory parameter is provided and is a valid path
if [ $# -ge 1 ] && [ -d "$1" ]; then
    WORK_DIR="$1"
fi

# Check if a password parameter is provided and is not null or empty
if [ $# -ge 2 ] && [ -n "$2" ]; then
    PASSWORD="$2"
fi

# Define the container name and data container path and file name
CONTAINER_NAME="grafana"
DATA_PATH="/var/lib/grafana/"
DATA_FILE="grafana.db"
ENCRYPTED_FILE="grafana.db.zip"
OPEN_FILE="grafanaWithoutPasswd.db.zip"

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
if [ ! -f "$WORK_DIR$DATA_FILE" ]; then
    BU_UNZIPPED=false # BackUp file is zipped
    if [ ! -f "$WORK_DIR$ENCRYPTED_FILE" ]; then
        if [ ! -f "$WORK_DIR$OPEN_FILE" ]; then
            echo "No backup file '$WORK_DIR$DATA_FILE', '$WORK_DIR$ENCRYPTED_FILE' or   '$WORK_DIR$OPEN_FILE' was found. Please make sure at least one of those files is  available before running this script."
            exit 1
        else
            BU_ENCRYPTED=false
        fi
    else
        BU_ENCRYPTED=true
    fi
else
    BU_UNZIPPED=true
fi

# Check if back up configuration needs to be unzipped, if so unzip it
if [ "$BU_UNZIPPED" = false ]; then
    echo "Backup file will be unziped."
    # Unzip the file if it is encrypted
    if [ "$BU_ENCRYPTED" = true ] && [ -n "$PASSWORD" ]; then
        unzip -P "$PASSWORD" "$WORK_DIR$ENCRYPTED_FILE" -d "$WORK_DIR"
        if [ $? -ne 0 ]; then
            ENCRYPTED_FILE_OPENED=false
            echo "Deciphering the backup file failed."
        else
            echo "Encrypted backup file unzipped."
            ENCRYPTED_FILE_OPENED=true
        fi
    else
        ENCRYPTED_FILE_OPENED=false
    fi

    # If the file wasn't encrypted or the password was incorrect, unzip the open file
    if [ "$ENCRYPTED_FILE_OPENED" = false ]; then
        echo "Trying to open the unencrypted backup file..."
        unzip "$WORK_DIR$OPEN_FILE" -d "$WORK_DIR"
    fi
else
    echo "Backup file found already unzipped."
fi

# Load backup the Grafana data
docker cp "$WORK_DIR$DATA_FILE" "$CONTAINER_NAME:$DATA_PATH"

# Fix ownership
docker exec -u root $CONTAINER_NAME chown grafana:root $DATA_PATH$DATA_FILE

# Fix execution permissions
docker exec -u root $CONTAINER_NAME chmod +rw $DATA_PATH$DATA_FILE

echo "Restarting Grafana..."

# Restart the Grafana container
docker restart "$CONTAINER_NAME"

# Print a success message
echo "Grafana configuration backup loaded successfully."