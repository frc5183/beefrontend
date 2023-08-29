local math2 = require "lib.math2"
local state = require "lib.state"
local wait = require "lib.wait"
local json = require "lib.external.json"
local flux = require "lib.external.flux"
local gui = require "lib.gui"
local menu
local settings={}
---@type Container
local container
local function load()
  local list_builder = gui.List(0, 40, 120, 660, 1140, gui.Color(0, 1, 0, 1), 0)
  -- Local Shared Variables and Load Functions
  ---@type love.File
  ---@diagnostic disable-next-line: undefined-field
  local f = love.filesystem.openFile("settings.json", "r")
  ---@type string
  local c
  -- Load Settings File
  if f then
    c = f:read()
  end
  local tbl
  pcall(function()
    tbl = json.decode(c)
  end)
  if tbl == nil then
    tbl = { username = "", password = "", url = "", secret = "", id = "", zerotrust = "false" }
  end
  local zerotrust = tbl.zerotrust
  local zero_text
  if (zerotrust == "true") then
    zero_text = "Enabled"
  else
    zero_text = "Disabled"
  end
  local _settings = {
    name       = "settings",
    ---@type TextButton
    back       = gui.TextButton(40, 20, 640, 50, gui.Color(0, 1, 0, 1), "Back", 18, "center"),
    ---@type TextButton
    save       = gui.TextButton(40, 70, 640, 50, gui.Color(0, 1, 0, 1), "Save", 18, "center"),

    user       = list_builder.TextRectangle(640, 50, gui.Color(0, 1, 0, 1), "Username", 18, "center"),
    userText   = list_builder.TextInput(640, 50, gui.Color(0, 1, 0, 1), tbl.username, 18, "left", "normal"),
    pass       = list_builder.TextRectangle(640, 50, gui.Color(0, 1, 0, 1), "Password", 18, "center"),
    passText   = list_builder.TextInput(640, 50, gui.Color(0, 1, 0, 0), tbl.password, 18, "left", "password"),
    url        = list_builder.TextRectangle(640, 50, gui.Color(0, 1, 0, 1), "Server URL", 18, "center"),
    urlText    = list_builder.TextInput(640, 50, gui.Color(0, 1, 0, 1), tbl.url, 18, "left", "normal"),
    zerotrust  = list_builder.TextButton(640, 50, gui.Color(0, 1, 0, 1), "Zerotrust " .. zero_text, 18, "center"),
    id         = list_builder.TextRectangle(640, 50, gui.Color(0, 1, 0, 1), "ID", 18, "center"),
    idText     = list_builder.TextInput(640, 50, gui.Color(0, 1, 0, 1), tbl.id, 18, "left", "normal"),
    secret     = list_builder.TextRectangle(640, 50, gui.Color(0, 1, 0, 1), "Secret", 18, "center"),
    secretText = list_builder.TextInput(640, 50, gui.Color(0, 1, 0, 1), tbl.secret, 18, "left", "password"),
    tbl        = tbl
  }
  for k, v in pairs(_settings) do
    settings[k]=v
  end
  if (zerotrust == "true") then
    settings._zerotrust = true
  else
    settings._zerotrust = false
  end
  container = gui.Container(0, 0, 720, 1280, gui.Color(0, 1, 0, 1), 720, 1280)
  container:add(list_builder.construct())
  container:add(settings.back)
  container:add(settings.save)

  -- Button Callbacks
  settings.zerotrust:onClick(function(pt, button, presses)
    if (settings.zerotrust:contains(pt) and button == 1) then
      settings._zerotrust = not settings._zerotrust
      local ztext
      if (settings._zerotrust) then ztext = "Enabled" else ztext = "Disabled" end
      settings.zerotrust:changeText("Zerotrust " .. ztext)
    end
  end)
  settings.save:onClick(function(pt, button, presses)
    if (settings.save:contains(pt) and button == 1) then
      local zerotrust
      local str = json.encode { secret = settings.secrettext:getText(), zerotrust = settings._zerotrust, id = settings
          .idText:getText(), password = settings.passText:getText(), username = settings.userText:getText(), url =
          settings
          .urlText:getText() }
      love.filesystem.remove("settings.json")
      local f = love.filesystem.openFile("settings.json", "a")
      f:write(str)
      f:flush()
      f:close()
      settings.tbl = json.decode(str)
    end
  end)
  settings.back:onClick(function(pt, button, presses)
    if (settings.back:contains(pt) and button == 1) then
      wait(0.05, function() menu.load() state.switch(menu) end)
    end
  end)
  -- State Switch Functions
  settings.switchto = function()
    settings.userText:enable()
    settings.passText:enable()
    settings.urlText:enable()
    settings.idText:enable()
    settings.secretText:enable()
  end
  settings.switchaway = function()
    settings.userText:disable()
    settings.passText:disable()
    settings.urlText:disable()
    settings.idText:disable()
    settings.secretText:disable()
  end

  -- State Love2D Functions
  function settings.draw()
    gui.Sizer.begin()
    container:draw()
    gui.Sizer.finish()
  end

  function settings.update(dt)
    wait.update()
    local x, y = love.mouse.getPosition()
    local x, y = gui.Sizer.translate(x, y)
    local pt = math2.Point2D(x, y)
    flux.update(dt)
    container:update(dt, pt)
  end

  function settings.mousemoved(x, y, dx, dy, istouch)
    local x, y = gui.Sizer.translate(x, y)
    local dx, dy = gui.Sizer.scale(dx, dy)
    container:mousemoved(x, y, dx, dy, istouch)
  end

  function settings.keypressed(key, scancode, isRepeat)
    container:keypressed(key, scancode, isRepeat)
  end

  function settings.textinput(text)
    container:textinput(text)
  end

  function settings.wheelmoved(dx, dy, x, y)
    local x, y = gui.Sizer.translate(x, y)
    container:wheelmoved(dx, dy, x, y)
  end

  function settings.mousepressed(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:press(math2.Point2D(x, y), button, presses)
  end

  function settings.mousereleased(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:click(math2.Point2D(x, y), button, presses)
  end

  -- State Data-Chain Functions
  settings.setMenu = function(m)
    menu = m
  end
  settings.load=load
end

load()
return settings
