local https = require"https"
local settings = require"state.settings"
local json = require"lib.external.json"
local requester = {}
local token
local cookie
function requester.setToken(new) 
  token=new end
function requester.setCookie(new)
  cookie=new
  end
function requester.complete(method, endpoint, headers, content, addToken)
  local out = {}
  if (headers==nil) then headers={} end
  if (addToken) then headers.Authorization=token end
  if content==nil then content={} end
  

  --headers["content-length"]=string.len(json.encode(content))
  headers["Content-Type"] = "application/json"
  if (settings.tbl.zerotrust) then
    headers["CF-Access-Client-Id"]=settings.tbl.id
    headers["CF-Access-Client-Secret"]=settings.tbl.secret
    if cookie then 
      headers["CF_Authorization"]=cookie
    end
  end
  local c, out, h = https.request(settings.urlText:getText() .. endpoint, {data=json.encode(content), method=method, headers=headers})
  local r = c
  return r, c, h, out
end
return requester