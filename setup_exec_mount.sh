#!/usr/bin/env bash
# setup_exec_mount.sh — run this *inside* a session started by sshrc

set -euo pipefail

cleanup_exec_mount() {
    if [[ -n "${BINDMNT:-}" && -d "$BINDMNT" && -n "${MOUNTED:-}" ]]; then
        umount "$BINDMNT" 2>/dev/null || true
        rmdir "$BINDMNT" 2>/dev/null || true
        echo "🧹 Cleaned up exec-safe bind mount at $BINDMNT"
    fi
}
trap cleanup_exec_mount EXIT

if [[ -z "${SSHHOME:-}" || ! -d "$SSHHOME" ]]; then
    echo "❌ SSHHOME is not set. Are you inside a real sshrc session?"
    exit 1
fi

if mount | grep "on $(dirname "$SSHHOME")" | grep -q noexec; then
    echo "⚠️  SSHHOME is on a noexec mount. Rebinding with exec..."

    BINDMNT="/dev/shm/sshrc_exec_$(basename "$SSHHOME")"
    mkdir -p "$BINDMNT"
    mount --bind "$SSHHOME" "$BINDMNT"
    mount -o remount,exec "$BINDMNT"
    export MOUNTED=1

    export SSHHOME="$BINDMNT"
    export PATH="$BINDMNT/.sshrc.d/bin:$BINDMNT:$PATH"
    echo "✅ Remounted SSHHOME at $BINDMNT with exec. Scripts now runnable."
else
    echo "✅ SSHHOME is already exec-capable. No changes needed."
fi

echo
echo "🎯 Scripts available at: $SSHHOME/.sshrc.d/bin"

