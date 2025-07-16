#!/bin/bash

source ./common/functions.sh

create_directory "$LOG_DIR" "$BACKUP_LOG_FILE"
create_directory "$LOCAL_HOST_BACKUP_DIR" "$BACKUP_LOG_FILE"

logger "Starting backup..." "$BACKUP_LOG_FILE"

clouds="$MAIN_CLOUD $(get_clouds)"

for cloud in $(get_clouds); do
    cloud_path=$(format_cloud "${cloud}:${SYNC_PATH}")
    backup_path="${cloud}:$(dirname "${cloud_path#*:}")/Backup/$(basename "${cloud_path#*:}")"
    do_backup "$cloud_path" "$backup_path" "$BACKUP_LOG_FILE"
done

do_backup "$MAIN_PATH" "$LOCAL_BACKUP_FILE"

logger "Backup process finished." "$BACKUP_LOG_FILE"