#!/usr/bin/env bash
# Test the OAuth client-credentials Lua rewrite in envoy_oauth_client_credentials.yaml
# Envoy listens on port 8001; echo server must be running on port 8080.

curl -s -X POST http://localhost:8001/REST/v1/OAuth/GetAccessToken/MyApp \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=my-client&client_secret=super-secret" | python3 -m json.tool
