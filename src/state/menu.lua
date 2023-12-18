-- Imports
local log = require "lib.log"
local state = require "lib.state"
local settings = require "state.settings"
local math2 = require "lib.math2"
local http = require "http"
local json = require "lib.external.json"
local list = require "state.list"
local gui = require "lib.gui"
local flux = require "lib.external.flux"
local err = require "state.error"
local wait = require "lib.wait"
local constant = require "constant"
local menu = {}
---@type Container
local container
local function load()
  local list_builder = gui.List(0, 40, 20, 660, 1260, constant.buttonForegroundColor, 10)
  local _menu = {
    name = "menu",
    login = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Login", 18, "center", constant.textColor,
      constant.buttonBackgroundColor),
    settings = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Settings", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    exit = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Exit", 18, "center", constant.textColor,
      constant.buttonBackgroundColor)
  }
  for k, v in pairs(_menu) do
    menu[k] = v
  end
  settings.setMenu(menu)
  list.setMenu(menu)
  menu.login:onClick(function(pt, button)
    if (menu.login:contains(pt) and button == 1) then
      local content = "{\"login\":\"" ..
          settings.userText:getText() .. "\", \"password\":\"" .. settings.passText:getText() .. "\"}"



      if (settings.tbl.zerotrust == "true") then
        local i, j, r, c, h, resbody
        pcall(function()
          r, c, h, resbody = http.complete("POST", "/users/login", {}, json.decode(content), false)
          i, j = string.find(h["set-cookie"] or h["Set-Cookie"], "CF_Authorization=.-%;")
        end)
        if not (i and j) then
          wait(0.05, function()
            err.load()
            err.title:setText("ERROR")
            err.err:setText("Invalid Zerotrust")
            err.setState(menu)
            state.switch(err)
          end)
        else
          http.setCookie(string.sub(h["set-cookie"] or h["Set-Cookie"], i + string.len("CF_Authorization="), j - 1))
        end
      end
      r, c, h, resbody = http.complete("POST", "/users/login", {}, json.decode(content), false)
      if c == 200 then
        if not (h.Authorization or h.authorization) then
          wait(0.05, function()
            err.load()
            err.title:setText("ERROR " .. c)
            err.err:setText("Connection Error: Check URL")
            err.setState(menu)
            state.switch(err)
          end)
        end
        http.setToken(h.Authorization or h.authorization)

        wait(0.05, function()
          list.load()
          state.switch(list)
        end)
      else
        wait(0.05, function()
          err.load()
          err.title:setText("ERROR " .. c)
          err.err:setText("Connection Error: Check URL")
          pcall(function() err.err:setText(json.decode(resbody or "{\"message\":\"connection refused\"}").message) end)
          err.setState(menu)
          state.switch(err)
        end)
      end
    end
  end)
  container = gui.Container(0, 0, 720, 1280, constant.backgroundColor, 720, 1280)
  container:add(list_builder.construct())
  menu.settings:onClick(function(pt, button)
    if (menu.settings:contains(pt) and button == 1) then
      wait(0.05,
        function()
          settings.load()
          settings.setMenu(menu)
          state.switch(settings)
        end)
    end
  end)
  menu.exit:onClick(function(pt, button) if (menu.exit:contains(pt) and button == 1) then love.event.quit() end end)
  -- State Switch Functions
  menu.switchto = function()
  end
  -- State Love2D Functions
  function menu.draw()
    gui.Sizer.begin()
    container:draw()
    gui.Sizer.finish()
  end

  function menu.update(dt)
    wait.update()
    local x, y = love.mouse.getPosition()
    local x, y = gui.Sizer.translate(x, y)
    local pt = math2.Point2D(x, y)
    flux.update(dt)
    container:update(dt, pt)
  end

  function menu.mousemoved(x, y, dx, dy, istouch)
    local x, y = gui.Sizer.translate(x, y)
    local dx, dy = gui.Sizer.scale(dx, dy)
    container:mousemoved(x, y, dx, dy, istouch)
  end

  function menu.keypressed(key, scancode, isRepeat)
    container:keypressed(key, scancode, isRepeat)
  end

  function menu.textinput(text)
    container:textinput(text)
  end

  function menu.wheelmoved(dx, dy, x, y)
    local x, y = gui.Sizer.translate(x, y)
    container:wheelmoved(dx, dy, x, y)
  end

  function menu.mousepressed(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:press(math2.Point2D(x, y), button, presses)
  end

  function menu.mousereleased(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:click(math2.Point2D(x, y), button, presses)
  end

  menu.load = load
end
load()
return menu
