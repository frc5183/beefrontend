-- Imports
local log = require"lib.log"
local state = require"lib.state"
local settings = require"state.settings"
local http = require"http"
local json = require"lib.external.json"
local list = require"state.list"
local gui = require"lib.gui"
local flux = require"lib.external.flux"
local dump = require"lib.dump"
local err = require"state.error"
local wait = require"lib.wait"
-- State Info and Basic Content
local menu = {
  name="menu",
  login = gui.TextButton(20, 20, 200, 50, gui.Color(0, 0, 1, 1), "Login", 18, "center"),
  settings = gui.TextButton(20, 70, 200, 50, gui.Color(0, 0, 1, 1), "Settings", 18, "center"),
  exit = gui.TextButton(20, 120, 200, 50, gui.Color(0, 0, 1, 1), "Exit", 18, "center"),
  
}
-- Local Shared Variables
local enabled = false
-- Configurations and Load Functions
settings.setMenu(menu)
list.setMenu(menu)
-- Button Callbacks
menu.login:onClick(function (pt, button)
    if (enabled and menu.login:contains(pt) and button==1) then
    local content = "{\"login\":\"" .. settings.userText:getText() .. "\", \"password\":\"" .. settings.passText:getText() .. "\"}"
    
    
    
    if (settings.tbl.zerotrust=="true") then
      local i, j, r, c, h, resbody
      pcall(function ()
    r, c, h, resbody = http.complete("POST", "/users/login", {}, json.decode(content), false)
    i, j = string.find(h["set-cookie"] or h["Set-Cookie"], "CF_Authorization=.-%;")
    end)
    if not (i and j) then 
      err.title:setText("ERROR")
      err.err:setText("Invalid Zerotrust")
      err.setState(menu)
      wait(0.05, function () state.switch(err) end)
      
    else
      http.setCookie(string.sub(h["set-cookie"] or h["Set-Cookie"], i+string.len("CF_Authorization="), j-1))
    end
  end
    r, c, h, resbody = http.complete("POST", "/users/login", {}, json.decode(content), false)
    log.info("HTTP Response Code: " .. c or "")
    if c==200 then 
      if not (h.Authorization or h.authorization) then
        err.title:setText("ERROR " .. c)
      err.err:setText("Connection Error: Check URL")
      err.setState(menu)
      wait(0.05, function () state.switch(err) end)
      end
      http.setToken(h.Authorization or h.authorization)
      
      wait(0.05, function () state.switch(list) end)
      
    else
      err.title:setText("ERROR " .. c)
      err.err:setText("Connection Error: Check URL")
      pcall(function () err.err:setText(json.decode(resbody or "{\"message\":\"connection refused\"}").message) end)
      err.setState(menu)
      wait(0.05, function () state.switch(err) end)
    end
    end
    end)

menu.settings:onClick(function (pt, button) if (enabled and menu.settings:contains(pt) and button==1) then wait(0.05, function () state.switch(settings) end) end end)
menu.exit:onClick(function(pt, button) if (enabled and menu.exit:contains(pt) and button==1) then  love.event.quit() end end)
-- State Switch Functions
menu.switchaway = function () 
  enabled=false
end
menu.switchto = function ()
  enabled=true
end
-- State Love2D Functions
function menu.mousemoved() end
function menu.textinput() end
function menu.keypressed() end
function menu.wheelmoved() end
function menu.update(dt)
  local pt = math.Point2D(love.mouse.getPosition())
  flux.update(dt)
  menu.login:update(dt, pt)
  menu.settings:update(dt, pt)
  menu.exit:update(dt, pt)
  wait.update()
end
function menu.draw()
  menu.login:draw()
  menu.settings:draw()
  menu.exit:draw()
end
return menu