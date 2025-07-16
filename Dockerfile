FROM rclone/rclone:latest

RUN apk add --no-cache dcron tzdata

ENV TZ=Europe/Madrid

WORKDIR /app

RUN mkdir -p /app/common

COPY app/backup.sh .
COPY app/sync.sh .
COPY app/common/constants.sh ./common
COPY app/common/functions.sh ./common
RUN chmod +x backup.sh
RUN chmod +x sync.sh
RUN chmod +x ./common/constants.sh
RUN chmod +x ./common/functions.sh

COPY sync.cron /etc/crontabs/root
RUN chmod 0600 /etc/crontabs/root

CMD ["crond", "-f"]