FROM rclone/rclone:latest

RUN apk add --no-cache cron

WORKDIR /app

COPY data/config/rclone.conf /config/rclone/rclone.conf

COPY app/sync.sh .
COPY app/backup.sh .
RUN chmod +x sync.sh
RUN chmod +x backup.sh

COPY sync.cron /etc/cron.d/rclone-sync
RUN chmod 0644 /etc/cron.d/rclone-sync
RUN crontab /etc/cron.d/rclone-sync

RUN mkdir -p /app/bisync_state

CMD ["crond", "-f"]