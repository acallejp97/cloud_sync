# Rclone Bidirectional Sync: Google Drive ↔ iCloud (Dockerized) ☁️↔️☁️

This project enables you to bidirectionally synchronize a specific file between **Google Drive** and **iCloud** using **Rclone** within a **Docker container** orchestrated with **Docker Compose**. The synchronization runs automatically at defined intervals using `cron` inside the container, and the initial `resync` process is automated via a persistent flag file.

---

## 🚀 Features

* **Bidirectional Synchronization:** Uses `rclone bisync` to keep your file updated on both cloud services.
* **Docker Containerization:** Isolates the application and its dependencies, ensuring a consistent environment.
* **Docker Compose Orchestration:** Simplifies deployment, volume management, and service startup.
* **Automated Scheduling with Cron:** The `cron` daemon runs within the container to execute the synchronization periodically.
* **Automatic `resync` Handling:** The script detects if it's the first run and applies `--resync` only when necessary, requiring no manual intervention.
* **Persistent Data & Logs:** Sync states and logs are stored in local folders on your server for easy debugging and tracking.

---

## 📦 Project Structure
.
├── data/
│   ├── bisync_state/  # Stores rclone bisync state and the .resync_done flag file
│   └── logs/          # Stores synchronization logs (rclone_bisync.log)
├── docker-compose.yml
├── Dockerfile
├── rclone.conf        # Rclone configuration with your cloud credentials
├── rclone-sync.cron   # Cron configuration file for the scheduled task
└── sync.sh            # Main synchronization script

---

## 🛠️ Prerequisites

* **Docker** and **Docker Compose** installed on your server.
* **Rclone** installed temporarily on your local machine (or any environment with a web browser) to generate the `rclone.conf` file.

---

## ⚙️ Setup

### 1. Generate `rclone.conf`

This is the most critical step for authenticating with your cloud services.

1.  **Install Rclone** on your local machine if you haven't already. Follow the [official Rclone installation guide](https://rclone.org/install/).
2.  Run `rclone config` in your terminal and follow the steps to add two new remotes:
    * One for **Google Drive** (e.g., `gdrive`). It will guide you through the OAuth2 authentication process in your browser.
    * One for **iCloud** (e.g., `icloud`). It will ask for your Apple ID and an **app-specific password** if you have two-factor authentication (2FA) enabled (highly recommended). You can generate this password from your [Apple ID account management page](https://appleid.apple.com/). 
3.  Once both remotes are configured, Rclone will create an `rclone.conf` file. It's usually found at `~/.config/rclone/rclone.conf` on Linux/macOS systems.
4.  **Copy this `rclone.conf` file** to the root directory of your project where `docker-compose.yml` and `Dockerfile` are located.

