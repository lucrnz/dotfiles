#!/bin/bash
DISTRO_IMG="quay.io/fedora/fedora-minimal:latest"

# Check if either podman or docker binary exists
if command -v podman &> /dev/null; then
    CONTAINER_RUNTIME="podman"
elif command -v docker &> /dev/null; then
    CONTAINER_RUNTIME="docker"
else
    echo "Error: Neither podman nor docker binary found. Please install either one."
    exit 1
fi

# Check if $HOME/docker-backup exists, if not create it
BACKUP_DIR="$HOME/docker-backup"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Validate the number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [backup|restore] <volume_name>"
    exit 1
fi

ACTION="$1"
VOLUME="$2"

# Backup action
if [ "$ACTION" == "backup" ]; then
    DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_FILE="$BACKUP_DIR/${VOLUME}_${DATETIME}.tar.gz"
    $CONTAINER_RUNTIME run --rm -v "${VOLUME}:/data" -v "${BACKUP_DIR}:/backup-dir" $DISTRO_IMG tar cvzf "$BACKUP_FILE" /data

    echo "Backup of volume '$VOLUME' completed. File saved as: $BACKUP_FILE"

# Restore action
elif [ "$ACTION" == "restore" ]; then
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR/${VOLUME}_"*.tar.gz | head -n1)
    if [ -z "$LATEST_BACKUP" ]; then
        echo "No backups found for volume '$VOLUME' in $BACKUP_DIR"
        exit 1
    fi

    echo "Restoring volume '$VOLUME' from backup file: $LATEST_BACKUP"
    $CONTAINER_RUNTIME run --rm -v "${VOLUME}:/data" -v "${BACKUP_DIR}:/backup-dir" $DISTRO_IMG bash -c "rm -rf /data/{*,.*}; cd /data && tar xvzf /backup-dir/$(basename "$LATEST_BACKUP") --strip 1"

    echo "Restore completed."

else
    echo "Invalid action. Please specify 'backup' or 'restore'."
    exit 1
fi

