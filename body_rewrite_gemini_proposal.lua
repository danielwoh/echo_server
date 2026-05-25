function envoy_on_request(request_handle)
  -- 1. Check if the path matches the old OAuth pattern
  local path = request_handle:headers():get(":path")
  local token_group = path:match("^/REST/v1/OAuth/GetAccessToken/([^%?]+)")

  if token_group then
    -- Rewrite the upstream headers for the new destination
    request_handle:headers():replace(":path", "/realms/HINCredmapper/protocol/openid-connect/token")
    -- Ensure your Envoy route configuration redirects this to the broker.pre.hintest.ch cluster
    
    -- 2. Buffer the request body so we can read and modify it
    local body_size = request_handle:body():length()
    local body_bytes = request_handle:body():getBytes(0, body_size)
    
    -- 3. Parse the x-www-form-urlencoded body parameters
    local params = {}
    for k, v in string.gmatch(body_bytes, "([^&=]+)=([^&=]+)") do
      -- Basic URL decoding for safety (handles simple cases like %3D, %26)
      k = string.gsub(k, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
      v = string.gsub(v, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
      params[k] = v
    end

    local client_id = params["client_id"] or ""
    local client_secret = params["client_secret"] or ""

    -- 4. Reconstruct the new body with URL encoding
    -- Helper function to URL encode values going back out
    local function urlencode(str)
      if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
          return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
      end
      return str
    end

    local new_body = string.format(
      "grant_type=credmapper_client_credentials&client_id=credmapper&cm_client_id=%s&cm_client_secret=%s&cm_application_name=%s",
      urlencode(client_id),
      urlencode(client_secret),
      urlencode(token_group)
    )

    -- 5. Set the new body and update Content-Length header
    request_handle:body():setBytes(new_body)
    request_handle:headers():replace("content-length", tostring(#new_body))
  end
end
