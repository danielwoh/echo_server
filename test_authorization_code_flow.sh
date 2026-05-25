#!/usr/bin/env bash
# Test the authorization code flow Lua rewrite in envoy_authorization_code_flow.yaml
# Envoy listens on port 8002; echo server must be running on port 8080.
#
# Mapping:
#   FROM: POST /REST/v1/OAuth/GetAccessToken
#         grant_type=authorization_code&code=...&client_id=...&client_secret=...&redirect_uri=...
#   TO:   POST /realms/HINCredmapper/protocol/openid-connect/token
#         grant_type=credmapper_authorization_code&code=...&client_id=credmapper
#         &cm_client_id=...&cm_client_secret=...&cm_redirect_uri=...

curl -s -X POST http://localhost:8002/REST/v1/OAuth/GetAccessToken \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code&code=AUTH123&client_id=my-client&client_secret=super-secret&redirect_uri=https://myapp.example.com/callback" \
  | python3 -m json.tool
