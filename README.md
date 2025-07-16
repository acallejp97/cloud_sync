# Cloud Sync: Bidirectional File Synchronization Across Multiple Clouds

## Overview

**Cloud Sync** is a Dockerized solution for bidirectional synchronization of a specific file (such as a KeePass database) across multiple cloud storage providers (e.g., Google Drive, iCloud, Nextcloud) using [rclone bisync](https://rclone.org/bisync/). The project leverages Docker, Docker Compose, and cron for scheduled, automated, and persistent synchronization and backup, with robust logging and state management.

---

## Features

- **Bidirectional Synchronization:** Keeps a file in sync between a main cloud and multiple secondary clouds.
- **Automated Scheduling:** Uses cron inside the container for periodic sync and backup.
- **First-run Resync:** Automatically performs a full resync on first run to ensure consistency.
- **Persistent State and Logs:** Sync state and logs are stored on host volumes for durability and troubleshooting.
- **Extensible:** Easily add more clouds by setting environment variables.
- **Backup Support:** Periodic backups to local storage and cloud backup folders.
- **Dockerized:** Easy deployment and isolation from host system.

---

## Project Structure

```
cloud_sync/
├── app/
│   ├── backup.sh                # Backup script
│   ├── sync.sh                  # Main sync script
│   └── common/
│       ├── constants.sh         # Environment constants
│       └── functions.sh         # Shared functions
├── data/
│   ├── bisync_state/            # rclone bisync state and .resync_done flag
│   ├── logs/                    # Log files
│   └── config/
│       └── rclone.conf          # rclone configuration (mounted)
├── docker-compose.yml           # Docker Compose configuration
├── Dockerfile                   # Docker image definition
├── sync.cron                    # Cron schedule for sync/backup
├── README.md                    # Quick start and setup
└── LICENSE                      # Apache 2.0 License
```

---

## How It Works

- **Main Cloud as Hub:** All secondary clouds sync with the main cloud (e.g., Google Drive). Changes in any secondary cloud are propagated to the main cloud, and then to the others.
- **Bidirectional Sync:** Uses `rclone bisync` for two-way synchronization between the main cloud and each secondary cloud.
- **Stateful Sync:** The first run uses `--resync` to establish a clean state; subsequent runs use incremental sync for efficiency.
- **Automated Backups:** Periodic backups are made both locally and to cloud backup folders.
- **Logging:** All operations are logged for audit and troubleshooting.

---

## Setup

### 1. Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed.
- [rclone](https://rclone.org/install/) installed locally to generate your `rclone.conf`.

### 2. Configure rclone

1. Run `rclone config` locally and set up remotes for each cloud (e.g., `gdrive`, `icloud`, `nextcloud`).
2. Copy the generated `rclone.conf` to `data/config/rclone.conf` in your project directory.

### 3. Environment Variables

Edit `docker-compose.yml` to set your clouds and file to sync:
```yaml
environment:
  - MAIN_CLOUD=gdrive
  - CLOUD1=icloud
  - CLOUD2=nextcloud
  - SYNC_PATH=Documents/file.kdbx
  - SYNC_CRON=*/2 * * * *
  - BACKUP_CRON=0 0 * */2 *
```
- `MAIN_CLOUD`: The central cloud (e.g., `gdrive`)
- `CLOUD1`, `CLOUD2`, ...: Additional clouds to sync with the main cloud
- `SYNC_PATH`: Path to the file to synchronize (relative to each cloud root)
- `SYNC_CRON`: Cron schedule for sync (default: every 2 minutes)
- `BACKUP_CRON`: Cron schedule for backup

### 4. Volumes

The following volumes are mounted for persistence:
- `./data/bisync_state:/app/bisync_state` — rclone bisync state
- `./data/logs:/var/log` — logs
- `./data/config/rclone.conf:/config/rclone/rclone.conf:ro` — rclone config (read-only)
- `/mnt/rclone_backups:/mnt/rclone_backups` — local backup storage

---

## Usage

### Build and Run

1. **Build the Docker image:**
   ```bash
   docker build -t cloud_sync:latest .
   ```
2. **Start the service:**
   ```bash
   docker-compose up -d
   ```

### Logs

- Sync logs: `data/logs/rclone_sync.log`
- Backup logs: `data/logs/rclone_backup.log`

### Adding More Clouds

Add more `CLOUDn` variables in `docker-compose.yml` (e.g., `CLOUD3=onedrive`).

---

## How Synchronization Works

- On first run, the script performs a full `--resync` between the main cloud and each secondary cloud.
- On subsequent runs, only changes are synchronized, using the bisync state.
- If you modify the file in one cloud (e.g., Nextcloud), the change is synced to the main cloud (e.g., Google Drive) on the next scheduled run, and then to the other clouds on their next sync cycle.
- **Note:** If two clouds are modified simultaneously, rclone bisync will attempt to resolve conflicts, but it's best to avoid concurrent edits.

---

## Customization

- **Sync Interval:** Adjust `SYNC_CRON` in `docker-compose.yml` for more/less frequent syncs.
- **Backup Interval:** Adjust `BACKUP_CRON` for backup frequency.
- **File to Sync:** Change `SYNC_PATH` to point to your desired file (e.g., your KeePass database).

---

## Troubleshooting

- **Check logs** in `data/logs/` for errors or sync issues.
- **First-run issues:** If you need to force a full resync, delete the `.resync_done` file in `data/bisync_state/`.
- **Permissions:** Ensure Docker has access to all mounted volumes and files.

---

## License

This project is licensed under the [Apache License 2.0](LICENSE).

---

## Credits

Developed by Asier Calejo, 2025.

---

## References

- [rclone bisync documentation](https://rclone.org/bisync/)
- [Docker documentation](https://docs.docker.com/)
- [KeePass](https://keepass.info/)