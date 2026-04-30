#!/data/data/com.termux/files/usr/bin/bash

# Project N.O.M.A.D. — Native Termux Stop Script
# Gracefully stops the Command Center, Redis, and queue workers.
#
# Usage:
#   bash install/stop_termux.sh

set -e

RESET='\033[0m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'

NOMAD_HOME="${HOME}/nomad"
NOMAD_RUN="${NOMAD_HOME}/run"

info()  { echo -e "${GREEN}[N.O.M.A.D]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }

# ── Helper: stop_pid ─────────────────────────────────────────────────────────

stop_pid() {
    local label="$1"
    local pidfile="$2"
    local signal="${3:-TERM}"

    if [[ ! -f "${pidfile}" ]]; then
        warn "${label}: PID file not found (${pidfile}). Already stopped?"
        return
    fi

    local pid
    pid=$(<"${pidfile}")

    if ! kill -0 "${pid}" 2>/dev/null; then
        warn "${label}: Process ${pid} is not running. Removing stale PID file."
        rm -f "${pidfile}"
        return
    fi

    info "Stopping ${label} (PID ${pid})..."
    kill -"${signal}" "${pid}" 2>/dev/null || true

    # Wait up to 15 seconds for the process to exit
    for i in $(seq 1 15); do
        if ! kill -0 "${pid}" 2>/dev/null; then
            info "${label} stopped."
            rm -f "${pidfile}"
            return
        fi
        sleep 1
    done

    # Force kill if it didn't stop gracefully
    warn "${label} did not stop gracefully. Sending SIGKILL..."
    kill -9 "${pid}" 2>/dev/null || true
    rm -f "${pidfile}"
    info "${label} force-killed."
}

# ── Stop services in reverse startup order ────────────────────────────────────

info "Stopping N.O.M.A.D. services..."

stop_pid "Command Center"  "${NOMAD_RUN}/nomad.pid"
stop_pid "Queue Workers"   "${NOMAD_RUN}/nomad_worker.pid"
stop_pid "Redis"           "${NOMAD_RUN}/redis.pid"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
info "All N.O.M.A.D. services stopped."
echo ""
