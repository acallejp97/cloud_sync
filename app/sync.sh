#!/bin/bash

SOURCE_PATH="${CLOUD_ONE}:${SYNC_PATH}"
DEST_PATH="${CLOUD_TWO}:/${SYNC_PATH}"

BISYNC_STATE_DIR="/app/bisync_state"
RESYNC_FLAG_FILE="${BISYNC_STATE_DIR}/.resync_done"

LOG_DIR="/var/log"
LOG_FILE="${LOG_DIR}/rclone_sync.log"

mkdir -p "$BISYNC_STATE_DIR"
mkdir -p "$LOG_DIR"

logger() {
    local message="$1"
    echo "$message" >> "$LOG_FILE" 2>&1
    echo "$message"
}

logger "Starting with bidirectional syncronization for ${SOURCE_PATH} and ${DEST_PATH}..."

RCLONE_BISYNC_CMD="rclone bisync \"$SOURCE_PATH\" \"$DEST_PATH\" \
    --bisync-state \"$BISYNC_STATE_DIR\" \
    --track-renames \
    --checkers 10 \
    --transfers 10 \
    --verbose \
    --retries 3 \
    --log-file \"$LOG_FILE\" \
    --create-empty-src-dirs \
    --remove-empty-dirs"

if [ -f "$RESYNC_FLAG_FILE" ]; then
    logger "resync file does exist. Executing bisync without --resync."
    eval "$RCLONE_BISYNC_CMD"
else
    logger "resync file does NOT exist. Executing bisync WITH --resync for the first time."
    eval "$RCLONE_BISYNC_CMD --resync"

    if [ $? -eq 0 ]; then
        logger "First execution with --resync completed successfully. Creating flag file."
        touch "$RESYNC_FLAG_FILE"
    else
        logger "Error during first execution with --resync! Flag file is notgoing to be created."
        cat "$LOG_FILE"
        exit 1
    fi
fi

if [ $? -eq 0 ]; then
    logger "Bidirectional syncronization completed successfully."
    exit 0
else
    logger "Error during bidirectional syncronization"
    cat "$LOG_FILE"
    exit 1
fi