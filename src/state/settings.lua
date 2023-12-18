local math2 = require "lib.math2"
local state = require "lib.state"
local wait = require "lib.wait"
local json = require "lib.external.json"
local flux = require "lib.external.flux"
local gui = require "lib.gui"
local constant = require "constant"
local menu
if (love.filesystem.openFile == nil) then
  love.filesystem.openFile = love.filesystem.newFile
end
local settings = {}
---@type Container
local container
local function load()
  local f
  if (love.filesystem.getInfo("settings.json") ~= nil) then
    f = love.filesystem.openFile("settings.json", "r")
  end
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
    tbl = { username = "", password = "", url = "", secret = "", id = "", zerotrust = "false", darkmode = true }
  end
  local zerotrust = tbl.zerotrust
  local darkmode = tbl.darkmode
  if (darkmode == nil) then
    darkmode = true
  end
  constant.setDarkMode(darkmode)
  local zero_text
  if (zerotrust == "true") then
    zero_text = "Enabled"
  else
    zero_text = "Disabled"
  end


  local list_builder = gui.List(0, 40, 20, 660, 1140, constant.buttonForegroundColor, 10)
  -- Local Shared Variables and Load Functions
  ---@type love.File
  ---@diagnostic disable-next-line: undefined-field
  local _settings = {
    name          = "settings",
    ---@type TextButton
    back          = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Back", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    ---@type TextButton
    save          = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Save", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),

    user          = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Username", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    userText      = list_builder.TextInput(640, 50, constant.buttonForegroundColor, tbl.username, 18, "left", "normal",
      constant.textColor, constant.buttonBackgroundColor),
    pass          = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Password", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    passText      = list_builder.TextInput(640, 50, constant.buttonForegroundColor, tbl.password, 18, "left", "password",
      constant.textColor, constant.buttonBackgroundColor),
    url           = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Server URL", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    urlText       = list_builder.TextInput(640, 50, constant.buttonForegroundColor, tbl.url, 18, "left", "normal",
      constant.textColor, constant.buttonBackgroundColor),
    zerotrust     = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Zerotrust " .. zero_text, 18,
      "center", constant.textColor, constant.buttonBackgroundColor),
    id            = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "ID", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    idText        = list_builder.TextInput(640, 50, constant.buttonForegroundColor, tbl.id, 18, "left", "normal",
      constant.textColor, constant.buttonBackgroundColor),
    secret        = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Secret", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    secretText    = list_builder.TextInput(640, 50, constant.buttonForegroundColor, tbl.secret, 18, "left", "password",
      constant.textColor, constant.buttonBackgroundColor),
    darkContainer = list_builder.Container(640, 50, constant.buttonForegroundColor, 640, 50),
    tbl           = tbl
  }
  _settings.darkmodelabel = gui.TextRectangle(0, 0, 590, 50, constant.buttonForegroundColor, "Dark Mode", 18, "center",
    constant.textColor, constant.buttonBackgroundColor)
  _settings.darkmode = gui.Checkbox(590, 0, 50, 50, constant.buttonForegroundColor, constant.buttonBackgroundColor,
    constant.selectedColor)
  _settings.darkmode:select(darkmode)
  _settings.darkContainer:add(_settings.darkmodelabel)
  _settings.darkContainer:add(_settings.darkmode)
  for k, v in pairs(_settings) do
    settings[k] = v
  end
  if (zerotrust == "true") then
    settings._zerotrust = true
  else
    settings._zerotrust = false
  end
  container = gui.Container(0, 0, 720, 1280, constant.buttonForegroundColor, 720, 1280)
  container:add(list_builder.construct())
  --container:add(settings.back)
  --container:add(settings.save)

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
      constant.setDarkMode(settings.darkmode:isSelected())
      local str = json.encode { secret = settings.secretText:getText(), zerotrust = settings._zerotrust, id = settings
          .idText:getText(), password = settings.passText:getText(), username = settings.userText:getText(), url =
          settings
          .urlText:getText(), darkmode = settings.darkmode:isSelected() }
      love.filesystem.remove("settings.json")
      ---@diagnostic disable-next-line: undefined-field
      local f = love.filesystem.openFile("settings.json", "a")
      f:write(str)
      f:flush()
      f:close()
      settings.tbl = json.decode(str)
    end
  end)
  settings.back:onClick(function(pt, button, presses)
    if (settings.back:contains(pt) and button == 1) then
      wait(0.05, function()
        menu.load()
        state.switch(menu)
      end)
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
  settings.load = load
end

load()
return settings
