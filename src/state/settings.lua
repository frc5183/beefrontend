local log = require"lib.log"
local state = require"lib.state"
local settings = {}
local json = require"lib.external.json"
local menu;
local f = love.filesystem.openFile("settings.json", "r")
local gui = require"lib.gui"
local ClickPulser = require"lib.gui.subsystem.ClickPulser"
local wait = require"lib.wait"
local c
local enabled = false
local flux = require"lib.external.flux"
if f then
  c= f:read()
end
  pcall(function ()
   settings.tbl = json.decode(c) end)
  if settings.tbl==nil then settings.tbl={username="", password="", url="", secret="", id="", zerotrust="false"} end
settings.name="settings"
settings.user     = gui.TextButton(20, 20, 200, 50, gui.Color(0, 0, 1, 1), "Username", 18, "center")
settings.userText = gui.TextInput (20, 70, 200, 50, gui.Color(0, 0, 1, 1), settings.tbl.username, 18, "left", "normal")
settings.pass     = gui.TextButton(20,120, 200, 50, gui.Color(0, 0, 1, 1), "Password", 18, "center")
settings.passText = gui.TextInput (20,170, 200, 50, gui.Color(0, 0, 1, 1), settings.tbl.password, 18, "left", "password")
settings.url      = gui.TextButton(20,220, 200, 50, gui.Color(0, 0, 1, 1), "Server URL", 18, "center")
settings.urlText  = gui.TextInput (20,270, 200, 50, gui.Color(0, 0, 1, 1), settings.tbl.url, 18, "left", "normal")
local zerotrust = settings.tbl.zerotrust
local zero_text
if (zerotrust=="true")
  then zero_text = "Enabled"
    settings._zerotrust=true
else
  zero_text = "Disabled"
  settings._zerotrust=false
end
settings.zerotrust= gui.TextButton(20,320, 200, 50, gui.Color(0, 0, 1, 1), "Zerotrust " .. zero_text, 18, "center")
settings.id       = gui.TextButton(20,370, 200, 50, gui.Color(0, 0, 1, 1), "ID", 18, "center")
settings.idText   = gui.TextInput (20,420, 200, 50, gui.Color(0, 0, 1, 1), settings.tbl.id, 18, "left", "normal")
settings.secret   = gui.TextButton(20,470, 200, 50, gui.Color(0, 0, 1, 1), "Secret", 18, "center")
settings.secrettext=gui.TextInput (20,520, 200, 50, gui.Color(0, 0, 1, 1), settings.tbl.secret, 18, "left", "password")
settings.save     = gui.TextButton(20,570, 200, 50, gui.Color(0, 0, 1, 1), "Save", 18, "center")
settings.back     = gui.TextButton(20,620, 200, 50, gui.Color(0, 0, 1, 1), "Back", 18, "center")

local check = false;
if settings.tbl.zerotrust=="true" then check=true end
settings.zerotrust:onClick(function (pt, button, presses)
  if (enabled and settings.zerotrust:contains(pt) and button==1) then
    settings._zerotrust = not settings._zerotrust
    local ztext
    if (settings._zerotrust) then ztext = "Enabled" else ztext = "Disabled" end
    settings.zerotrust:changeText("Zerotrust " .. ztext)
  end
end)
settings.save:onClick(function(pt, button, presses) 
  if (enabled and settings.save:contains(pt) and button==1) then
    local zerotrust
    local str = json.encode{secret=settings.secrettext:getText(), zerotrust=settings._zerotrust, id=settings.idText:getText(), password=settings.passText:getText(), username=settings.userText:getText(), url=settings.urlText:getText()}
    love.filesystem.remove("settings.json")
  local f = love.filesystem.openFile("settings.json", "a")
  f:write(str)
  f:flush()
  f:close()
  settings.tbl=json.decode(str)
  end
end)
settings.back:onClick(function(pt, button, presses)
  if (enabled and settings.back:contains(pt) and button==1) then
    wait(0.05, function () state.switch(menu) end)
  end
end)
settings.setMenu = function (m)
  menu=m
end
settings.draw = function ()
  settings.user:draw()
  settings.userText:draw()
  settings.pass:draw()
  settings.passText:draw()
  settings.url:draw()
  settings.urlText:draw()
  settings.zerotrust:draw()
  settings.id:draw()
  settings.idText:draw()
  settings.secret:draw()
  settings.secrettext:draw()
  settings.save:draw()
  settings.back:draw()
end
settings.switchto = function () enabled=true 
  settings.userText:enable()
  settings.passText:enable()
  settings.urlText:enable()
  settings.idText:enable()
  settings.secrettext:enable()
  end
settings.switchaway = function () enabled=false 
  settings.userText:disable()
  settings.passText:disable()
  settings.urlText:disable()
  settings.idText:disable()
  settings.secrettext:disable()
end
settings.update = function (dt) 
  wait.update()
  local pt = math.Point2D(love.mouse.getPosition())
  flux.update(dt)
  settings.userText:update(dt)
  settings.passText:update(dt)
  settings.urlText:update(dt)
  settings.idText:update(dt)
  settings.secrettext:update(dt)
  settings.zerotrust:update(dt, pt)
  settings.save:update(dt, pt)
  settings.back:update(dt, pt)
end

function settings.mousemoved(x, y, dx, dy, istouch)
  settings.userText:mousemoved(x, y)
  settings.passText:mousemoved(x, y)
  settings.urlText:mousemoved(x, y)
  settings.idText:mousemoved(x, y)
  settings.secrettext:mousemoved(x, y)
end
function settings.keypressed(key, scancode, isRepeat)
  settings.userText:keypressed(key, scancode, isRepeat)
  settings.passText:keypressed(key, scancode, isRepeat)
  settings.urlText:keypressed(key, scancode, isRepeat)
  settings.idText:keypressed(key, scancode, isRepeat)
  settings.secrettext:keypressed(key, scancode, isRepeat)
end
function settings.textinput(text)
  settings.userText:textinput(text)
  settings.passText:textinput(text)
  settings.urlText:textinput(text)
  settings.idText:textinput(text)
  settings.secrettext:textinput(text)
end
function settings.wheelmoved(dx, dy)
  settings.userText:wheelmoved(dx, dy)
  settings.passText:wheelmoved(dx, dy)
  settings.urlText:wheelmoved(dx, dy)
  settings.idText:wheelmoved(dx, dy)
  settings.secrettext:wheelmoved(dx, dy)
end

return settings