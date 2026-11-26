#!/usr/bin/env bash
# Connect a Claude Code cloud session (Ubuntu VM) to the owner's GPU PC, EVILAEGIS, and forward the studio
# ports to localhost, so the studio HTTP APIs work exactly as they do on the PC itself:
#   7860 Hunyuan Studio (3D)   7870 Video Studio   7880 Flux Studio (images)   7890 Audio Studio (music, SFX, voice)
#
# Needs three environment variables, saved by the owner in the cloud environment (never in a repo):
#   TS_AUTHKEY         Tailscale auth key: reusable, ephemeral, tagged tag:cloud
#   EVILAEGIS_SSH_KEY  base64 of the restricted private key (it can only start studios and forward these ports)
#   EVILAEGIS_SSH_USER the Windows account name on the PC
#
# Usage:  bash connect-gpu-pc.sh up        # join the tailnet, start the studios, forward the ports
#         bash connect-gpu-pc.sh status    # studio status as seen from the PC
#         bash connect-gpu-pc.sh down      # close the forwards and leave the tailnet
# Canonical copy: local-ai-studio repo remote/connect-gpu-pc.sh (copies live in the knowledge base repos).
set -euo pipefail

ACTION=${1:-up}
TS_VERSION=${TS_VERSION:-1.104.7}
DIR=${GPU_PC_DIR:-$HOME/.cache/gpu-pc}
SOCK="$DIR/tailscaled.sock"
PEER=${EVILAEGIS_HOST:-evilaegis}
PORTS=(7860 7870 7880 7890)
HOSTKEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGHIEIvqz+2iWFi/yWMK5hJ+Sy34DSgxnQYYD04y9cl'

ts() { "$DIR/tailscale" --socket="$SOCK" "$@"; }
die() { echo "connect-gpu-pc: $*" >&2; exit 1; }

install_tailscale() {
  [ -x "$DIR/tailscaled" ] && return
  mkdir -p "$DIR"
  local arch; arch=$(uname -m); [ "$arch" = x86_64 ] && arch=amd64; [ "$arch" = aarch64 ] && arch=arm64
  echo "installing tailscale $TS_VERSION ($arch) into $DIR"
  curl -fsSL "https://pkgs.tailscale.com/stable/tailscale_${TS_VERSION}_${arch}.tgz" | tar -xz -C "$DIR" --strip-components=1
}

start_tailscale() {
  if ! ts status >/dev/null 2>&1 && ! pgrep -f "tailscaled.*$SOCK" >/dev/null; then
    # Userspace networking: no TUN device or root needed. Ephemeral in-memory state, so the node vanishes
    # from the tailnet shortly after the VM goes away. Outbound traffic honours HTTPS_PROXY.
    nohup "$DIR/tailscaled" --tun=userspace-networking --state=mem: --statedir="$DIR/state" \
      --socket="$SOCK" --no-logs-no-support >"$DIR/tailscaled.log" 2>&1 &
    for _ in $(seq 1 30); do ts version >/dev/null 2>&1 && break; sleep 0.5; done
  fi
  if ! ts status >/dev/null 2>&1; then
    [ -n "${TS_AUTHKEY:-}" ] || die "TS_AUTHKEY is not set (add it to the cloud environment's variables)"
    ts up --auth-key="$TS_AUTHKEY" --hostname="cloud-$(hostname | tr -cd 'a-z0-9-' | cut -c1-20)" \
      --accept-dns=false --timeout=90s || die "tailscale up failed; see $DIR/tailscaled.log"
  fi
}

write_ssh_config() {
  [ -n "${EVILAEGIS_SSH_KEY:-}" ] || die "EVILAEGIS_SSH_KEY is not set"
  [ -n "${EVILAEGIS_SSH_USER:-}" ] || die "EVILAEGIS_SSH_USER is not set"
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  printf '%s' "$EVILAEGIS_SSH_KEY" | base64 -d > ~/.ssh/evilaegis_cloud && chmod 600 ~/.ssh/evilaegis_cloud
  echo "evilaegis $HOSTKEY" > "$DIR/known_hosts"
  cat > "$DIR/ssh_config" <<EOF
Host evilaegis
  HostName $PEER
  HostKeyAlias evilaegis
  User $EVILAEGIS_SSH_USER
  IdentityFile ~/.ssh/evilaegis_cloud
  IdentitiesOnly yes
  UserKnownHostsFile $DIR/known_hosts
  StrictHostKeyChecking yes
  ProxyCommand $DIR/tailscale --socket=$SOCK nc %h %p
  ServerAliveInterval 30
  ServerAliveCountMax 4
  LogLevel ERROR
EOF
}

case "$ACTION" in
  up)
    install_tailscale; start_tailscale; write_ssh_config
    echo "starting studios on the PC (already-running ones are left alone):"
    ssh -F "$DIR/ssh_config" evilaegis start
    pkill -f "ssh -F $DIR/ssh_config -f -N" 2>/dev/null || true
    fwd=(); for p in "${PORTS[@]}"; do fwd+=(-L "$p:127.0.0.1:$p"); done
    ssh -F "$DIR/ssh_config" -f -N -o ExitOnForwardFailure=yes "${fwd[@]}" evilaegis
    for p in "${PORTS[@]}"; do
      code=$(curl -s -o /dev/null -w '%{http_code}' --noproxy '*' -m 10 "http://127.0.0.1:$p/" || true)
      echo "localhost:$p -> HTTP $code"
    done
    ;;
  status)
    write_ssh_config; ssh -F "$DIR/ssh_config" evilaegis status ;;
  down)
    pkill -f "ssh -F $DIR/ssh_config -f -N" 2>/dev/null || true
    ts logout 2>/dev/null || true
    pkill -f "tailscaled.*$SOCK" 2>/dev/null || true
    echo "disconnected" ;;
  *) die "usage: $0 up|status|down" ;;
esac
