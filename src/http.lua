local http = require"socket.http"
local dump = require"lib.dump"
local settings = require"state.settings"
local json = require"lib.external.json"
local ltn12 = require"ltn12"
local requester = {}
local token
function requester.setToken(new) 
  token=new end
function requester.complete(method, endpoint, headers, content, addToken)
  local out = {}
  if (headers==nil) then headers={} end
  if (addToken) then headers.authorization=token end
  if content==nil then content={} end
  

  headers["content-length"]=string.len(json.encode(content))
  headers["Content-Type"] = "application/json"
  if (settings.tbl.zerotrust) then
    headers["CF-Access-Client-Id"]=settings.tbl.id
    headers["CF-Access-Client-Secret"]=settings.tbl.secret
  end
  local r, c, h = http.request{
    method=method,
    url=settings.urlText:getText() .. endpoint,
    source=ltn12.source.string(json.encode(content)),
    headers=headers,
    sink = ltn12.sink.table(out)}
  
  return r, c, h, out
end
return requester