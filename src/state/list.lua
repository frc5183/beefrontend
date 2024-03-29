-- Imports
local http = require "http"
local state = require "lib.state"
local math2 = require "lib.math2"
local json = require "lib.external.json"
local err = require "state.error"
local item = require "state.item"
local flux = require "lib.external.flux"
local wait = require "lib.wait"
local constant = require "constant"
local gui = require "lib.gui"
local menu
local canEdit = true
---@type table
local items
local list = {}
item.setList(list)
---@type Container
local container
---@type boolean
local initial = true
---@type integer
local adjust = 0
local function load()
  local list_builder = gui.List(0, 40, 20, 660, 1140, constant.buttonForegroundColor, 10)
  local _list = {
    name = "list",
    back = gui.TextButton(0, 0, 320, 50, constant.buttonForegroundColor, "Back", 18, "center", constant.textColor,
      constant.buttonBackgroundColor),
    refresh = gui.TextButton(0, 0, 320, 50, constant.buttonForegroundColor, "Refresh", 18, "center", constant.textColor,
      constant.buttonBackgroundColor),
    left = gui.TextButton(320, 0, 320, 50, constant.buttonForegroundColor, "Page Left", 18, "center", constant.textColor,
      constant.buttonBackgroundColor),
    right = gui.TextButton(320, 0, 320, 50, constant.buttonForegroundColor, "Page Right", 18, "center",
      constant.textColor, constant.buttonBackgroundColor),
    topDouble = list_builder.Container(640, 50, constant.buttonForegroundColor, 640, 50),
    bottomDouble = list_builder.Container(640, 50, constant.buttonForegroundColor, 640, 50),
  }
  if (not initial) then
    ---Response
    ---@type number
    local r
    ---Response Code (equal to r)
    ---@type number
    local c
    ---Response Headers
    ---@type table
    local h
    ---Response Body
    ---@type table
    local resbody
    local r, c, h, resbody = http.complete("GET", "/items/all", {}, {}, true)
    ---@type table
    local t
    pcall(function() t = json.decode(resbody) end)
    if not (t) then
      wait(0.05, function()
        err.load()
        err.title:setText("ERROR")
        err.err:setText("Invalid Response Body")
        err.setState(list)
        state.switch(err)
      end)
      return
    else
      items = t.data
      if (type(items) ~= "table") then
        items = {}
      end
      for k = adjust + 1, math.min(adjust + 50, #items) do
        local newbutton = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "PLACEHOLDER", 18, "center",
          constant.textColor, constant.buttonBackgroundColor)
        local newitem = items[k]
        newbutton:setText(newitem.name)
        newbutton:onClick(function(pt, button, presses)
          if (newbutton:contains(pt) and button == 1) then
            item.setActiveItem(newitem)
            item.load(false)
            wait(0.05, function() state.switch(item) end)
          end
        end)
      end
      if (canEdit) then
        local newitem = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "New Item", 18, "center",
          constant.textColor, constant.buttonBackgroundColor)
        newitem:onClick(function(pt, button, presses)
          if (newitem:contains(pt) and button == 1) then
            item.load(true)
            wait(0.05, function() state.switch(item) end)
          end
        end)
      end
    end
  end
  container = gui.Container(0, 0, 720, 1280, constant.buttonForegroundColor, 720, 1280)
  container:add(list_builder.construct())
  local b = _list.back
  b:onClick(function(pt, button, presses)
    if (b:contains(pt) and button == 1) then
      menu.load()
      wait(0.05, function() state.switch(menu) end)
    end
  end)
  _list.topDouble:add(b)
  local b = _list.refresh
  b:onClick(function(pt, button, presses)
    if (b:contains(pt) and button == 1) then
      load()
    end
  end)
  _list.topDouble:add(b)
  local b = _list.right
  b:onClick(function(pt, button, presses)
    if (b:contains(pt) and button == 1) then
      if (adjust + 50 < #items) then
        adjust = adjust + 50
      end
      load()
    end
  end)
  _list.bottomDouble:add(b)
  local b = _list.left
  b:onClick(function(pt, button, presses)
    if (b:contains(pt) and button == 1) then
      if (adjust - 50 >= 0) then
        adjust = adjust - 50
      end
      load()
    end
  end)
  _list.bottomDouble:add(b)
  for k, v in pairs(_list) do
    list[k] = v
  end
  function list.draw()
    gui.Sizer.begin()
    container:draw()
    gui.Sizer.finish()
  end

  function list.update(dt)
    wait.update()
    local x, y = love.mouse.getPosition()
    local x, y = gui.Sizer.translate(x, y)
    local pt = math2.Point2D(x, y)
    flux.update(dt)
    container:update(dt, pt)
  end

  function list.mousemoved(x, y, dx, dy, istouch)
    local x, y = gui.Sizer.translate(x, y)
    local dx, dy = gui.Sizer.scale(dx, dy)
    container:mousemoved(x, y, dx, dy, istouch)
  end

  function list.keypressed(key, scancode, isRepeat)
    container:keypressed(key, scancode, isRepeat)
  end

  function list.textinput(text)
    container:textinput(text)
  end

  function list.wheelmoved(dx, dy, x, y)
    local x, y = gui.Sizer.translate(x, y)
    container:wheelmoved(dx, dy, x, y)
  end

  function list.mousepressed(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:press(math2.Point2D(x, y), button, presses)
  end

  function list.mousereleased(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:click(math2.Point2D(x, y), button, presses)
  end

  -- State Data-Chain Functions
  list.setMenu = function(m)
    menu = m
  end
  initial = false
  list.load = load
end
load()
return list
