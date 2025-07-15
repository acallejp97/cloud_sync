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

logger "Iniciando la sincronización bidireccional de ${SOURCE_PATH} y ${DEST_PATH}..."

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
    logger "El archivo de resync existe. Ejecutando bisync SIN --resync."
    eval "$RCLONE_BISYNC_CMD"
else
    logger "El archivo de resync NO existe. Ejecutando bisync CON --resync por primera vez."
    eval "$RCLONE_BISYNC_CMD --resync"

    if [ $? -eq 0 ]; then
        logger "Primera ejecución con --resync completada exitosamente. Creando archivo de bandera."
        touch "$RESYNC_FLAG_FILE"
    else
        logger "¡Error en la primera ejecución con --resync! No se creará el archivo de bandera."
        cat "$LOG_FILE"
        exit 1
    fi
fi

if [ $? -eq 0 ]; then
    logger "Sincronización bidireccional completada exitosamente."
    exit 0
else
    logger "¡Error durante la sincronización bidireccional!"
    cat "$LOG_FILE"
    exit 1
fi