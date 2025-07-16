#!/bin/bash

MAIN_PATH=$(format_cloud "${MAIN_CLOUD}:${SYNC_PATH}")

LOG_DIR="/var/log"
BACKUP_LOG_FILE="${LOG_DIR}/rclone_backup.log"
SYNC_LOG_FILE="${LOG_DIR}/rclone_sync.log"

FILENAME=$(basename "${SYNC_PATH}")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

LOCAL_HOST_BACKUP_DIR="/mnt/rclone_backups"
LOCAL_BACKUP_FILE="${LOCAL_HOST_BACKUP_DIR}/${FILENAME}_backup_${TIMESTAMP}"

BISYNC_STATE_DIR="/app/bisync_state"
RESYNC_FLAG_FILE="${BISYNC_STATE_DIR}/.resync_done"