#!/usr/bin/env bash
# Test the refresh token flow Lua rewrite in envoy_refresh_token.yaml
# Envoy listens on port 8003; echo server must be running on port 8080.
#
# Mapping:
#   FROM: POST /REST/v1/OAuth/GetAccessToken
#         grant_type=refresh_token&client_id=...&client_secret=...&refresh_token=...
#   TO:   POST /realms/HINCredmapper/protocol/openid-connect/token
#         grant_type=credmapper_refresh_token&client_id=credmapper
#         &cm_client_id=...&cm_client_secret=...&refresh_token=...

curl -s -X POST http://localhost:8003/REST/v1/OAuth/GetAccessToken \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=refresh_token&client_id=my-client&client_secret=super-secret&refresh_token=REFRESH_TOKEN_XYZ" \
  | python3 -m json.tool
