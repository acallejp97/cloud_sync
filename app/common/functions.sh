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
    
    local slave_cloud="$1"
    local cloud_path=$(format_cloud "${slave_cloud}:${SYNC_PATH}")
    local bisync_state_file="${BISYNC_STATE_DIR}/bisync_${MAIN_CLOUD}_${slave_cloud}.json"
    local resync_flag_file="${BISYNC_STATE_DIR}/.resync_done_${MAIN_CLOUD}_${slave_cloud}"

    RCLONE_COMMAND="rclone bisync \"$MAIN_PATH\" \"$slave_cloud_path\" \
        --bisync-state \"$bisync_state_file\" \
        --track-renames \
        --checkers 10 \
        --transfers 10 \
        --verbose \
        --retries 3 \
        --log-file \"$SYNC_LOG_FILE\" \
        --create-empty-src-dirs \
        --remove-empty-dirs"

    logger "Starting bidirectional synchronization for ${MAIN_PATH} and ${slave_cloud_path}..." "$SYNC_LOG_FILE"

    if [ -f "$resync_flag_file" ]; then
        logger "Resync flag exists for $slave_cloud. Executing bisync without --resync." "$SYNC_LOG_FILE"
        eval "$RCLONE_COMMAND"
    else
        logger "Resync flag does NOT exist for $slave_cloud. Executing bisync WITH --resync for the first time." "$SYNC_LOG_FILE"
        eval "$RCLONE_COMMAND --resync"

        if [ $? -eq 0 ]; then
            logger "First execution with --resync for $slave_cloud completed successfully. Creating flag file." "$SYNC_LOG_FILE"
            touch "$resync_flag_file"
        else
            logger "Error during first execution with --resync for $slave_cloud! Flag file is not going to be created." "$SYNC_LOG_FILE"
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