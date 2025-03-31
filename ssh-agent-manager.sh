#!/bin/bash
# ssh-agent-manager.sh
# A generic, shareable SSH agent helper script using DRY principles and full CLI control.

set -euo pipefail

# === Defaults ===
AGENT_FILE="$HOME/.ssh/ssh-agent.env"
DEFAULT_KEY="$HOME/.ssh/id_rsa"
REF_SUFFIX=".ref"
DO_CHECK=false
DO_LOAD=true   # Default behavior: check and load
DO_UNLOAD=false
DO_FORCE=false
DO_STATUS=false
DO_PRINT_FP=false
DEBUG=false
SSH_KEY="$DEFAULT_KEY"

# === Utilities ===

log()   { echo "[INFO] $*"; }
warn()  { echo "[WARN] $*" >&2; }
err()   { echo "[ERROR] $*" >&2; exit 1; }
debug() { $DEBUG && echo "[DEBUG] $*" >&2 || true; }

# === Usage ===
usage() {
cat <<EOF
Usage: $0 [options]

Default behavior: Check and load the SSH key if not already loaded.

Options:
  --check               Only check if the SSH key is loaded (no load)
  --load                Load SSH key if not already loaded (default)
  --unload              Remove the SSH key from ssh-agent
  --force               Restart ssh-agent even if running
  --key <path>          Path to SSH private key (default: $DEFAULT_KEY)
  --status              Show ssh-agent status and loaded keys
  --print-fingerprint   Print the fingerprint of the key (useful to create .ref)
  --debug               Enable debug output
  --help                Show this help message
EOF
exit 1
}

# === CLI Parse ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check) DO_CHECK=true; DO_LOAD=false ;;
        --load) DO_LOAD=true ;;
        --unload) DO_UNLOAD=true; DO_LOAD=false; DO_CHECK=false ;;
        --force) DO_FORCE=true ;;
        --key) SSH_KEY="$2"; shift ;;
        --status) DO_STATUS=true; DO_LOAD=false; DO_CHECK=false ;;
        --print-fingerprint) DO_PRINT_FP=true; DO_LOAD=false; DO_CHECK=false ;;
        --debug) DEBUG=true ;;
        --help) usage ;;
        *) err "Unknown argument: $1";;
    esac
    shift
done

# === Agent Management ===

start_agent() {
    log "Starting a new ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "$AGENT_FILE"
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> "$AGENT_FILE"
}

agent_is_alive() {
    [[ -S "${SSH_AUTH_SOCK:-}" ]] && ps -p "${SSH_AGENT_PID:-}" > /dev/null 2>&1
}

load_agent_env() {
    if [[ -f "$AGENT_FILE" ]]; then
        debug "Loading agent environment from $AGENT_FILE"
        source "$AGENT_FILE" > /dev/null
        if ! agent_is_alive; then
            warn "Stale agent detected (invalid socket or PID)."
            return 1
        fi
        return 0
    fi
    return 1
}

check_agent() {
    ssh-add -l > /dev/null 2>&1
}

get_fingerprint() {
    local key="$1"
    ssh-keygen -lf "$key" | awk '{print $2}'
}

generate_ref_file() {
    local pub_key="${SSH_KEY}.pub"
    local ref_file="${SSH_KEY}${REF_SUFFIX}"

    if [[ -f "$pub_key" ]]; then
        local fp
        fp=$(get_fingerprint "$pub_key")
        echo "$fp" > "$ref_file"
        log "Generated fingerprint ref file: $ref_file"
    else
        err "Cannot generate .ref file: missing $pub_key"
    fi
}

get_expected_fingerprint() {
    local pub_key="${SSH_KEY}.pub"
    local ref_file="${SSH_KEY}${REF_SUFFIX}"

    if [[ -f "$pub_key" ]]; then
        get_fingerprint "$pub_key"
    elif [[ -f "$ref_file" ]]; then
        <"$ref_file"
    else
        warn "No fingerprint reference found. Generating..."
        generate_ref_file
        <"$ref_file"
    fi
}

fingerprint_loaded() {
    local expected_fp="$1"
    ssh-add -l 2>/dev/null | awk '{print $2}' | grep -Fxq "$expected_fp"
}

unload_key() {
    local expected_fp
    expected_fp=$(get_expected_fingerprint)

    if ! check_agent || ! agent_is_alive; then
        warn "No valid agent to unload from."
        return 1
    fi

    if ssh-add -l | grep -q "$expected_fp"; then
        log "Unloading SSH key from agent..."
        if ssh-add -d "$SSH_KEY"; then
            log "SSH key removed from agent."
        else
            warn "Failed to unload SSH key."
        fi
    else
        log "SSH key not currently loaded — nothing to unload."
    fi
}

print_status() {
    log "SSH Agent PID: ${SSH_AGENT_PID:-<unset>}"
    ssh-add -l || echo "No keys loaded."
}

print_fingerprint() {
    local pub_key="${SSH_KEY}.pub"
    if [[ -f "$pub_key" ]]; then
        get_fingerprint "$pub_key"
    else
        err "No public key found at $pub_key"
    fi
}

# === Main Logic ===

# Ensure key exists
[[ -f "$SSH_KEY" ]] || err "SSH key not found: $SSH_KEY"

if ! load_agent_env || ! check_agent || ! agent_is_alive || $DO_FORCE; then
    log "No valid ssh-agent found or force restart requested."
    start_agent
fi

# === Action Switches ===

if $DO_PRINT_FP; then
    print_fingerprint
    exit 0
fi

if $DO_STATUS; then
    print_status
    exit 0
fi

if $DO_UNLOAD; then
    unload_key
    exit 0
fi

EXPECTED_FP="$(get_expected_fingerprint)"

if $DO_CHECK; then
    if fingerprint_loaded "$EXPECTED_FP"; then
        log "SSH key is already loaded."
        exit 0
    else
        log "SSH key is NOT loaded."
        exit 1
    fi
fi

# Default: check and load if needed
if fingerprint_loaded "$EXPECTED_FP"; then
    log "SSH key already loaded. No action taken."
else
    log "SSH key not loaded. Adding key..."
    ssh-add "$SSH_KEY"
    log "SSH key loaded successfully."
fi

