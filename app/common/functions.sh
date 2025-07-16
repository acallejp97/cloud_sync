#!/bin/bash

source ./common/constants.sh

logger() {
    local message="$1"
    local log_file="$2"
    echo "$message" >> "$log_file" 2>&1
    echo "$message"
}

format_cloud() {
    local remote="$1"
    if [[ "$remote" == *"icloud"* ]] || [[ "$remote" == *"iCloud"* ]]; then
        echo "${remote/:/:/}" | sed 's/:/:\//'
    else
        echo "$remote"
    fi
}

get_clouds() {
    local clouds_found=()
    local i=1
    while true; do
        local var_name="CLOUD${i}"
        local var_value="${!var_name}"
        if [[ -n "$var_value" ]]; then
            clouds_found+=("$var_value")
            i=$((i + 1))
        else
            break
        fi
    done
    echo "${clouds_found[@]}"
}

create_directory() {
    local dir_path="$1"
    local log_file="$2"
    mkdir -p "$dir_path" >> "$log_file" 2>&1
    if [ $? -ne 0 ]; then
        logger "Failed to create directory: $dir_path" "$log_file"
        exit 1
    fi
}

execute_bisync() {
    local slave_cloud_path="$1"
    RCLONE_COMMAND="rclone bisync \"$MAIN_PATH\" \"$slave_cloud_path\" \
        --bisync-state \"$BISYNC_STATE_DIR\" \
        --track-renames \
        --checkers 10 \
        --transfers 10 \
        --verbose \
        --retries 3 \
        --log-file \"$SYNC_LOG_FILE\" \
        --create-empty-src-dirs \
        --remove-empty-dirs"

    logger "Starting with bidirectional syncronization for ${MAIN_PATH} and ${slave_cloud_path}..." "$SYNC_LOG_FILE"

    if [ -f "$RESYNC_FLAG_FILE" ]; then
        logger "resync file does exist. Executing bisync without --resync." "$SYNC_LOG_FILE"
        eval "$RCLONE_COMMAND"
    else
        logger "resync file does NOT exist. Executing bisync WITH --resync for the first time." "$SYNC_LOG_FILE"
        eval "$RCLONE_COMMAND --resync"

        if [ $? -eq 0 ]; then
            logger "First execution with --resync completed successfully. Creating flag file." "$SYNC_LOG_FILE"
            touch "$RESYNC_FLAG_FILE"
        else
            logger "Error during first execution with --resync! Flag file is notgoing to be created." "$SYNC_LOG_FILE"
            cat "$SYNC_LOG_FILE"
            exit 1
        fi
    fi
}

do_backup() {
    local source="$1"
    local dest="$2"
    local log_file="$3"
    logger "Copying from ${source} to ${dest}..."
    rclone copy "$source" "$dest" \
        --verbose \
        --retries 3 \
        --log-file "$log_file"

    if [ $? -eq 0 ]; then
        logger "Backup from ${source} to ${dest} completed successfully."
    else
        logger "Error during backup from ${source} to ${dest}!"
        cat "$log_file"
    fi
}