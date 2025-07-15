#!/bin/bash

SOURCE_PATH=$(format_cloud "${CLOUD_ONE}:${SYNC_PATH}")
DEST_PATH=$(format_cloud "${CLOUD_TWO}:${SYNC_PATH}")

LOG_DIR="/var/log"
LOG_FILE="${LOG_DIR}/rclone_backup.log"
mkdir -p "$LOG_DIR"

logger() {
    local message="$1"
    echo "$message" >> "$LOG_FILE" 2>&1
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

logger "Iniciando proceso de copia de seguridad..."

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME=$(basename "${SYNC_PATH}")

CLOUD_ONE_BACKUP_PATH="${CLOUD_ONE}:$(dirname "${SOURCE_PATH#*:}")/Backup/$(basename "${SOURCE_PATH#*:}")"
CLOUD_TWO_BACKUP_PATH="${CLOUD_TWO}:$(dirname "${DEST_PATH#*:}")/Backup/$(basename "${DEST_PATH#*:}")"

LOCAL_HOST_BACKUP_DIR="/mnt/rclone_backups"
LOCAL_BACKUP_FILE="${LOCAL_HOST_BACKUP_DIR}/${FILENAME}_backup_${TIMESTAMP}"

mkdir -p "$LOCAL_HOST_BACKUP_DIR" >> "$LOG_FILE" 2>&1

logger "Copiando ${SOURCE_PATH} a ${CLOUD_ONE_BACKUP_PATH} en ${CLOUD_ONE} (incremental)..."
rclone copy "$SOURCE_PATH" "$CLOUD_ONE_BACKUP_PATH" \
    --verbose \
    --retries 3 \
    --log-file "$LOG_FILE"

if [ $? -eq 0 ]; then
    logger "Copia de seguridad incremental de ${CLOUD_ONE} completada."
else
    logger "¡Error en la copia de seguridad incremental de ${CLOUD_ONE}!"
    cat "$LOG_FILE"
fi

logger "Copiando ${DEST_PATH} a ${CLOUD_TWO_BACKUP_PATH} en ${CLOUD_TWO} (incremental)..."
rclone copy "$DEST_PATH" "$CLOUD_TWO_BACKUP_PATH" \
    --verbose \
    --retries 3 \
    --log-file "$LOG_FILE"

if [ $? -eq 0 ]; then
    logger "Copia de seguridad incremental de ${CLOUD_TWO} completada."
else
    logger "¡Error en la copia de seguridad incremental de ${CLOUD_TWO}!"
    cat "$LOG_FILE"
fi

logger "Copiando ${SOURCE_PATH} a ${LOCAL_BACKUP_FILE} en el host (con fecha)..."
rclone copy "$SOURCE_PATH" "$LOCAL_BACKUP_FILE" \
    --verbose \
    --retries 3 \
    --log-file "$LOG_FILE"

if [ $? -eq 0 ]; then
    logger "Copia de seguridad local en el host (con fecha) completada."
else
    logger "¡Error en la copia de seguridad local en el host (con fecha)!"
    cat "$LOG_FILE"
fi

logger "Proceso de copia de seguridad finalizado."