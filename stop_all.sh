#!/usr/bin/env bash
set -euo pipefail

echo "Stopping Envoy containers..."
docker rm -f envoy_base envoy_client_credentials envoy_authcode envoy_refresh envoy2 2>/dev/null || true

echo "Stopping echo server..."
pkill -f "python3 .*server\.py" 2>/dev/null || true

echo "All services stopped."
