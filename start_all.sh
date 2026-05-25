#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVOY_IMAGE="envoyproxy/envoy:v1.33-latest"

# ── Clean up any previously running instances ────────────────────────────────
echo "Cleaning up existing instances..."
pkill -f "python3 .*server\.py" 2>/dev/null || true
# Wait until port 8080 is released (up to 5 seconds)
for i in $(seq 1 10); do
  lsof -iTCP:8080 -sTCP:LISTEN -t 2>/dev/null | xargs kill -9 2>/dev/null || true
  lsof -iTCP:8080 -sTCP:LISTEN &>/dev/null || break
  sleep 0.5
done
docker rm -f envoy_base envoy_client_credentials envoy_authcode envoy_refresh envoy2 2>/dev/null || true

# ── Echo server ────────────────────────────────────────────────────────────────
echo "Starting echo server on port 8080..."
python3 "$SCRIPT_DIR/server.py" &
ECHO_PID=$!
echo "  echo server PID: $ECHO_PID"

# ── Envoy containers ───────────────────────────────────────────────────────────
start_envoy() {
  local name=$1
  local config=$2
  local proxy_port=$3
  local admin_port=$4

  # Remove existing container if present
  docker rm -f "$name" 2>/dev/null || true

  echo "Starting $name (proxy :$proxy_port, admin :$admin_port)..."
  docker run -d --name "$name" \
    -p "${proxy_port}:8000" \
    -p "${admin_port}:9901" \
    --add-host host.docker.internal:host-gateway \
    -v "$SCRIPT_DIR/$config:/etc/envoy/envoy.yaml:ro" \
    "$ENVOY_IMAGE" > /dev/null
  echo "  $name started"
}

start_envoy envoy_base                envoy.yaml                              8000 9901
start_envoy envoy_client_credentials  envoy_oauth_client_credentials.yaml     8001 9902
start_envoy envoy_authcode            envoy_authorization_code_flow.yaml      8002 9903
start_envoy envoy_refresh             envoy_refresh_token.yaml                8003 9904

echo ""
echo "All services running:"
echo "  Echo server          http://localhost:8080  (PID $ECHO_PID)"
echo "  envoy_base           http://localhost:8000  (admin: 9901)"
echo "  envoy_client_creds   http://localhost:8001  (admin: 9902)"
echo "  envoy_authcode       http://localhost:8002  (admin: 9903)"
echo "  envoy_refresh        http://localhost:8003  (admin: 9904)"
echo ""
echo "Run ./stop_all.sh to stop everything."
