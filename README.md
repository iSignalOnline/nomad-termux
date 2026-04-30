<div align="center">
<img src="admin/public/project_nomad_logo.webp" width="200" height="200"/>

# Project N.O.M.A.D. — Native Termux Fork
### Node for Offline Media, Archives, and Data

**Lightweight · No Root · Native Performance**

[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2)](https://discord.com/invite/crosstalksolutions)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue)](LICENSE)

</div>

---

> **This is the Native Termux fork of Project N.O.M.A.D.**
> This fork has been **de-containerized**. All services that previously ran in Docker now run as **native background processes within the Termux environment**. No root access, no custom kernels, and no Docker containers are required.

Project N.O.M.A.D. (Native Termux Fork) is a self-contained, offline-first knowledge and education server that runs **directly on Android** via [Termux](https://termux.dev/). It brings critical tools, knowledge, and AI to your pocket — anytime, anywhere, without modifying your device.

---

## Table of Contents

1. [How It Works](#how-it-works)
2. [What's Included](#whats-included)
3. [Device Requirements](#device-requirements)
4. [Installation & Quickstart](#installation--quickstart)
   - [Core Prerequisites](#core-prerequisites)
   - [Setup Script](#setup-script)
5. [Configuration](#configuration)
6. [Usage — Starting & Stopping N.O.M.A.D.](#usage--starting--stopping-nomad)
7. [Viewing Logs](#viewing-logs)
8. [Helper Scripts](#helper-scripts)
9. [About Docker Migration](#about-docker-migration)
10. [About Internet Usage & Privacy](#about-internet-usage--privacy)
11. [About Security](#about-security)
12. [Contributing](#contributing)
13. [Community & Resources](#community--resources)
14. [License](#license)

---

## How It Works

N.O.M.A.D. is a management UI ("Command Center") and API that orchestrates a collection of tools and resources running as **native Termux processes**. It handles installation, configuration, and data management — so you don't have to.

**Built-in capabilities include:**

- **AI Chat with Knowledge Base** — local AI chat powered by [Ollama](https://ollama.com/) (or any OpenAI-compatible API such as LM Studio / llama.cpp), with document upload and semantic search (RAG via [Qdrant](https://qdrant.tech/))
- **Information Library** — offline Wikipedia, medical references, ebooks, and more via [Kiwix](https://kiwix.org/)
- **Education Platform** — Khan Academy courses with progress tracking via [Kolibri](https://learningequality.org/kolibri/)
- **Offline Maps** — downloadable regional maps via [ProtoMaps](https://protomaps.com)
- **Data Tools** — encryption, encoding, and analysis via [CyberChef](https://gchq.github.io/CyberChef/)
- **Notes** — local note-taking via [FlatNotes](https://github.com/dullage/flatnotes)
- **Easy Setup Wizard** — guided first-time configuration with curated content collections

N.O.M.A.D. also includes built-in tools like a Wikipedia content selector, ZIM library manager, and content explorer.

---

## What's Included

| Capability | Powered By | What You Get |
|---|---|---|
| Information Library | Kiwix | Offline Wikipedia, medical references, survival guides, ebooks |
| AI Assistant | Ollama + Qdrant | Built-in chat with document upload and semantic search |
| Education Platform | Kolibri | Khan Academy courses, progress tracking, multi-user support |
| Offline Maps | ProtoMaps | Downloadable regional maps with search and navigation |
| Data Tools | CyberChef | Encryption, encoding, hashing, and data analysis |
| Notes | FlatNotes | Local note-taking with markdown support |

---

## Device Requirements

This Termux fork is intentionally lightweight and designed to run on everyday Android hardware.

*Note: This fork is not sponsored by any hardware manufacturer. Hardware listed below is for reference only.*

#### Minimum Specs (Command Center only)

| Component | Requirement |
|---|---|
| Android version | 7.0 (Nougat) or later |
| Architecture | arm64-v8a (64-bit ARM) |
| RAM | 2 GB |
| Free Storage | 2 GB |
| Internet | Required during install only |

#### Recommended Specs (with AI tools)

| Component | Recommendation |
|---|---|
| Android version | 11 or later |
| RAM | 6 GB or more |
| Free Storage | 16 GB or more (for ZIM files, models, maps) |
| CPU | Snapdragon 778G / Dimensity 900 class or better |
| Internet | Required during install only |

> AI model performance is limited by device RAM on Android. Large models (7B+) may be slow or unavailable. llama.cpp-based backends running on CPU are the practical option here.

---

## Installation & Quickstart

### Core Prerequisites

Open Termux and run the following commands to update your environment and install all required native dependencies:

```bash
pkg update && pkg upgrade -y
pkg install -y git nodejs redis curl wget
```

> **Dependency notes:**
> - `nodejs` — runs the AdonisJS Command Center backend
> - `redis` — in-memory store used for caching, background jobs, and queues
> - `git` — required to clone this repository
> - `curl` / `wget` — used by helper scripts

### Setup Script

Clone this repository and run the native setup script. This replaces the old `docker-compose up` workflow entirely:

```bash
# Clone the repository
git clone https://github.com/iSignalOnline/nomad-termux.git
cd nomad-termux

# Run the native Termux setup script
bash install/setup_termux.sh
```

The setup script will:

1. Start the Redis server
2. Install Node.js dependencies (`npm ci --omit=dev`)
3. Run database migrations and seed initial data (SQLite database file is created automatically)
4. Write a `~/.nomad_env` environment file with all required variables
5. Start the Command Center as a background process
6. Print the local access URL

Once complete, open a browser (e.g. [Firefox for Android](https://www.mozilla.org/en-US/firefox/browsers/mobile/android/)) and navigate to:

```
http://127.0.0.1:8080
```

---

## Configuration

All environment variables are stored in `~/.nomad_env` after setup. You can edit this file at any time and then restart N.O.M.A.D. for changes to take effect.

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | Port the Command Center listens on |
| `HOST` | `0.0.0.0` | Listen address (use `127.0.0.1` to restrict to localhost) |
| `APP_KEY` | *(generated)* | Secret key — must be at least 16 characters |
| `NODE_ENV` | `production` | Node environment |
| `LOG_LEVEL` | `info` | Log verbosity (`debug`, `info`, `warn`, `error`) |
| `DB_FILENAME` | `~/nomad/data/nomad.db` | Path to the SQLite database file |
| `REDIS_HOST` | `127.0.0.1` | Redis host (always localhost in Termux) |
| `REDIS_PORT` | `6379` | Redis port |
| `NOMAD_STORAGE_PATH` | `~/nomad/data` | Storage path for ZIM files, maps, uploads, etc. |

To apply changes manually (without using the helper scripts):

```bash
# Source the env file and restart
source ~/.nomad_env
bash ~/nomad-termux/install/start_termux.sh
```

---

## Usage — Starting & Stopping N.O.M.A.D.

#### Start all services

```bash
bash ~/nomad-termux/install/start_termux.sh
```

This starts Redis and the Command Center as background processes. PIDs are written to `~/nomad/run/` for tracking.

#### Stop all services

```bash
bash ~/nomad-termux/install/stop_termux.sh
```

This gracefully stops the Command Center, Redis, and the queue workers in order.

#### Check running status

```bash
# Check if the Command Center is running
cat ~/nomad/run/nomad.pid | xargs ps -p
```

---

## Viewing Logs

Since `docker logs` is no longer applicable, logs are written to plain text files in the storage directory.

| Service | Log Location |
|---|---|
| Command Center (stdout) | `~/nomad/data/logs/nomad.log` |
| Command Center (stderr) | `~/nomad/data/logs/nomad_err.log` |
| Queue Workers (stdout) | `~/nomad/data/logs/nomad.log` (shared with Command Center) |
| Queue Workers (stderr) | `~/nomad/data/logs/nomad_err.log` (shared with Command Center) |
| Redis | `~/nomad/data/logs/redis.log` |

#### Tail the live Command Center log

```bash
tail -f ~/nomad/data/logs/nomad.log
```

#### View the last 100 lines of all logs at once

```bash
tail -n 100 ~/nomad/data/logs/nomad.log \
             ~/nomad/data/logs/nomad_err.log \
             ~/nomad/data/logs/redis.log
```

---

## Helper Scripts

All helper scripts are located in `~/nomad-termux/install/`.

| Script | Purpose |
|---|---|
| `setup_termux.sh` | First-time setup — installs dependencies, configures SQLite DB, starts all services |
| `start_termux.sh` | Start Redis and the Command Center |
| `stop_termux.sh` | Gracefully stop all N.O.M.A.D. services |

```bash
# First-time setup
bash ~/nomad-termux/install/setup_termux.sh

# Start
bash ~/nomad-termux/install/start_termux.sh

# Stop
bash ~/nomad-termux/install/stop_termux.sh
```

---

## About Docker Migration

This fork has been **de-containerized**. All services that previously ran in Docker now run as **native background processes within the Termux environment**.

The table below summarises how Docker concepts map to native Termux equivalents in this fork:

| Docker Concept | Native Termux Equivalent |
|---|---|
| `FROM node:22-slim` | `pkg install nodejs` |
| `FROM mysql:8.0` | SQLite file at `~/nomad/data/nomad.db` (no daemon) |
| `FROM redis:7-alpine` | `pkg install redis` |
| `docker-compose up -d` | `bash install/setup_termux.sh` |
| `docker logs nomad_admin` | `tail -f ~/nomad/data/logs/nomad.log` |
| `http://db:5432` (container link) | Not applicable — SQLite is file-based |
| `/opt/project-nomad/storage` (bind-mount) | `~/nomad/data` (Termux home directory) |
| `.env` passed to container | `~/.nomad_env` sourced in shell / `start_termux.sh` |
| `ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]` | `install/start_termux.sh` |
| `/var/run/docker.sock` (DooD) | Not applicable — no Docker daemon required |

No root access, no kernel modifications, and no container runtime are needed.

---

## About Internet Usage & Privacy

Project N.O.M.A.D. is designed for offline usage. An internet connection is only required during the initial installation (to download Termux packages and clone this repository) and if you choose to download additional tools or content at a later time. Otherwise, N.O.M.A.D. does not require an internet connection and has **zero built-in telemetry**.

To test internet connectivity, N.O.M.A.D. attempts to make a request to Cloudflare's utility endpoint, `https://1.1.1.1/cdn-cgi/trace`, and checks for a successful response.

---

## About Security

By design, Project N.O.M.A.D. is intended to be open and accessible without hurdles — it includes no authentication. If you connect your Android device to a local network after install (e.g. to allow other devices to access its resources), be aware that any device on that network may be able to reach the Command Center on port `8080`.

To restrict access to localhost only, set `HOST=127.0.0.1` in `~/.nomad_env` and restart N.O.M.A.D.

N.O.M.A.D. is **not** designed to be exposed directly to the internet, and we strongly advise against doing so.

---

## Contributing

Contributions are welcome and appreciated! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

---

## Community & Resources

- **Discord:** [Join the Community](https://discord.com/invite/crosstalksolutions) — Get help, share your builds, and connect with other N.O.M.A.D. users
- **FAQ:** [FAQ.md](FAQ.md) — Answers to frequently asked questions
- **Original Project:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) — The upstream Docker-based release

---

## License

Project N.O.M.A.D. is licensed under the [Apache License 2.0](LICENSE).
