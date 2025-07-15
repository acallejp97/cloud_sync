FROM rclone/rclone:latest

RUN apk add --no-cache dcron

WORKDIR /app

COPY app/sync.sh .
COPY app/backup.sh .
RUN chmod +x sync.sh
RUN chmod +x backup.sh

COPY sync.cron /etc/crontabs/root
RUN chmod 0600 /etc/crontabs/root

RUN mkdir -p /app/bisync_state

CMD ["crond", "-f"]