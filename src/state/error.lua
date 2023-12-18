-- Imports
local state = require "lib.state"
local log = require "lib.log"
local gui = require "lib.gui"
local wait = require "lib.wait"
local flux = require "lib.external.flux"
local math2 = require "lib.math2"
local constant = require "constant"
local err = {}
local oldState
---@type Container
local container
local function load()
  local list_builder = gui.List(0, 40, 20, 660, 1260, constant.buttonForegroundColor, 10)
  local _err = {
    name = "err",
    title = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "ERROR", 18, "center", constant
      .textColor, constant.buttonBackgroundColor),
    err = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "ERROR", 18, "center", constant.textColor,
      constant.buttonBackgroundColor),
    back = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Back", 18, "center", constant.textColor,
      constant.buttonBackgroundColor)
  }
  for k, v in pairs(_err) do
    err[k] = v
  end
  container = gui.Container(0, 0, 720, 1280, constant.buttonForegroundColor, 720, 1280)
  container:add(list_builder.construct())
  -- Button Callbacks
  err.back:onClick(function(pt, button, presses)
    if (err.back:contains(pt) and button == 1) then
      wait(0.05, function()
        oldState.load()
        state.switch(oldState)
      end)
    end
  end)

  function err.draw()
    gui.Sizer.begin()
    container:draw()
    gui.Sizer.finish()
  end

  function err.update(dt)
    wait.update()
    local x, y = love.mouse.getPosition()
    local x, y = gui.Sizer.translate(x, y)
    local pt = math2.Point2D(x, y)
    flux.update(dt)
    container:update(dt, pt)
  end

  function err.mousemoved(x, y, dx, dy, istouch)
    local x, y = gui.Sizer.translate(x, y)
    local dx, dy = gui.Sizer.scale(dx, dy)
    container:mousemoved(x, y, dx, dy, istouch)
  end

  function err.keypressed(key, scancode, isRepeat)
    container:keypressed(key, scancode, isRepeat)
  end

  function err.textinput(text)
    container:textinput(text)
  end

  function err.wheelmoved(dx, dy, x, y)
    local x, y = gui.Sizer.translate(x, y)
    container:wheelmoved(dx, dy, x, y)
  end

  function err.mousepressed(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:press(math2.Point2D(x, y), button, presses)
  end

  function err.mousereleased(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:click(math2.Point2D(x, y), button, presses)
  end

  --State Data-Chain Functions
  err.setState = function(old) oldState = old end

  -- State Switch Functions
  err.switchto = function()
    log.error("ERROR")
  end
  err.load = load
end
load()
--Return State
return err
