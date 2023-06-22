local log = require"lib.log"
local state = require"lib.state"
local settings = require"state.settings"
local http = require"http"
local json = require"lib.external.json"
local list = require"state.list"
local dump = require"lib.dump"
local err = require"state.error"
local menu = {}
menu.name="menu"
settings.setMenu(menu);
list.setMenu(menu)
menu.login=gooi.newButton({
    text="Login",
    x=20,
    y=20,
    w=100,
    h=50,
    group="menu"
  }
)
menu.login:onRelease(function () 
    local content = "{\"login\":\"" .. settings.userText:getText() .. "\", \"password\":\"" .. settings.passText:getText() .. "\"}"
    
    
    
    if (settings.tbl.zerotrust=="true") then
    local r, c, h, resbody = http.complete("POST", "/users/login", {}, json.decode(content), false)
    local i, j = string.find(h["set-cookie"] or h["Set-Cookie"], "CF_Authorization=.-%;")
    
    
    http.setCookie(string.sub(h["set-cookie"] or h["Set-Cookie"], i+string.len("CF_Authorization="), j-1))
    end
    r, c, h, resbody = http.complete("POST", "/users/login", {}, json.decode(content), false)
    if c==200 then 
      http.setToken(h.authorization)
      state.switch(list)
      
    else
      err.title:setText("ERROR " .. c)
      err.err:setText(json.decode(resbody[1] or "{\"message\":\"connection refused\"}").message)
      err.setState(menu)
      state.switch(err)
    end
    end)
menu.settings=gooi.newButton({
    text="Settings",
    x=20,
    y=70,
    w=100,
    h=50,
    group="menu"
  }
)
menu.exit=gooi.newButton({
    text="Exit",
    x=20,
    y=120,
    w=100,
    h=50,
    group="menu"
  }
)
menu.switchaway = function ()
  gooi.setGroupEnabled("menu", false)
end
menu.switchto = function ()
  gooi.setGroupEnabled("menu", true)
end
menu.settings:onRelease(function () state.switch(settings) end)
menu.exit:onRelease(function() love.event.quit() end)
gooi.setGroupEnabled("menu", false)
return menu