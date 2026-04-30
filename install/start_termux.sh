#!/data/data/com.termux/files/usr/bin/bash

# Project N.O.M.A.D. — Native Termux Start Script
# Starts MariaDB, Redis, and the Command Center as background processes.
#
# Usage:
#   bash install/start_termux.sh

set -e

RESET='\033[0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'

NOMAD_HOME="${HOME}/nomad"
NOMAD_DATA="${NOMAD_HOME}/data"
NOMAD_RUN="${NOMAD_HOME}/run"
NOMAD_LOGS="${NOMAD_DATA}/logs"
NOMAD_ENV="${HOME}/.nomad_env"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ADMIN_DIR="${REPO_DIR}/admin"
BUILD_DIR="${ADMIN_DIR}/build"

info()  { echo -e "${GREEN}[N.O.M.A.D]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
error() { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }

# ── Sanity checks ────────────────────────────────────────────────────────────

[[ -f "${NOMAD_ENV}" ]] || error "Environment file not found at ${NOMAD_ENV}. Run setup_termux.sh first."
[[ -f "${BUILD_DIR}/bin/server.js" ]] || error "Build output not found at ${BUILD_DIR}. Run setup_termux.sh first."

source "${NOMAD_ENV}"

mkdir -p "${NOMAD_LOGS}" "${NOMAD_RUN}"

# ── Helper: is_running ────────────────────────────────────────────────────────

is_running() {
    local pidfile="$1"
    if [[ -f "${pidfile}" ]]; then
        local pid
        pid=$(<"${pidfile}")
        if kill -0 "${pid}" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# ── Start MariaDB ────────────────────────────────────────────────────────────

if is_running "${NOMAD_RUN}/mariadb.pid"; then
    info "MariaDB is already running (PID $(<"${NOMAD_RUN}/mariadb.pid"))."
else
    info "Starting MariaDB..."
    mariadbd \
        --datadir="${NOMAD_HOME}/mysql" \
        --socket="${NOMAD_RUN}/mysql.sock" \
        --pid-file="${NOMAD_RUN}/mariadb.pid" \
        --port=3306 \
        --bind-address=127.0.0.1 \
        --log-error="${NOMAD_LOGS}/mariadb.log" \
        --skip-networking=OFF \
        --daemonize

    for i in $(seq 1 30); do
        if mysqladmin ping --socket="${NOMAD_RUN}/mysql.sock" --silent 2>/dev/null; then
            break
        fi
        sleep 1
        if [[ $i -eq 30 ]]; then
            error "MariaDB did not start. Check ${NOMAD_LOGS}/mariadb.log"
        fi
    done
    info "MariaDB started."
fi

# ── Start Redis ───────────────────────────────────────────────────────────────

if is_running "${NOMAD_RUN}/redis.pid"; then
    info "Redis is already running (PID $(<"${NOMAD_RUN}/redis.pid"))."
else
    info "Starting Redis..."
    redis-server \
        --daemonize yes \
        --port "${REDIS_PORT}" \
        --bind 127.0.0.1 \
        --dir "${NOMAD_HOME}/redis" \
        --logfile "${NOMAD_LOGS}/redis.log" \
        --pidfile "${NOMAD_RUN}/redis.pid"

    for i in $(seq 1 15); do
        if redis-cli ping 2>/dev/null | grep -q PONG; then
            break
        fi
        sleep 1
        if [[ $i -eq 15 ]]; then
            error "Redis did not start. Check ${NOMAD_LOGS}/redis.log"
        fi
    done
    info "Redis started."
fi

# ── Start background workers ──────────────────────────────────────────────────

if is_running "${NOMAD_RUN}/nomad_worker.pid"; then
    info "Queue workers already running (PID $(<"${NOMAD_RUN}/nomad_worker.pid"))."
else
    info "Starting background queue workers..."
    nohup node "${BUILD_DIR}/ace.js" queue:work --all \
        >> "${NOMAD_LOGS}/nomad.log" \
        2>> "${NOMAD_LOGS}/nomad_err.log" &
    echo $! > "${NOMAD_RUN}/nomad_worker.pid"
fi

# ── Start the Command Center ──────────────────────────────────────────────────

if is_running "${NOMAD_RUN}/nomad.pid"; then
    info "Command Center already running (PID $(<"${NOMAD_RUN}/nomad.pid"))."
else
    info "Starting N.O.M.A.D. Command Center..."
    nohup node "${BUILD_DIR}/bin/server.js" \
        >> "${NOMAD_LOGS}/nomad.log" \
        2>> "${NOMAD_LOGS}/nomad_err.log" &
    echo $! > "${NOMAD_RUN}/nomad.pid"
    info "Command Center started (PID $(<"${NOMAD_RUN}/nomad.pid"))."
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}N.O.M.A.D. is running → http://127.0.0.1:${PORT}${RESET}"
echo -e "Logs: tail -f ${NOMAD_LOGS}/nomad.log"
echo ""
