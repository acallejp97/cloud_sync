#!/bin/bash

source ./common/functions.sh

create_directory "$BISYNC_STATE_DIR" "$SYNC_LOG_FILE"
create_directory "$LOG_DIR" "$SYNC_LOG_FILE"

for cloud in $(get_clouds); do
    cloud_path=$(format_cloud "${cloud}:${SYNC_PATH}")
    execute_bisync "$cloud_path"
done

if [ $? -eq 0 ]; then
    logger "Bidirectional syncronization completed successfully." "$SYNC_LOG_FILE"
    exit 0
else
    logger "Error during bidirectional syncronization" "$SYNC_LOG_FILE"
    cat "$SYNC_LOG_FILE"
    exit 1
fi
