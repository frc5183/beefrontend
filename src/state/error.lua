local oldState
local state = require"lib.state"
local err={}
local log = require"lib.log"
local gui = require"lib.gui"
local wait = require"lib.wait"
local flux = require"lib.external.flux"
local enabled = false
err.name="err"

err.back = gui.TextButton(20, 120, 200, 50, gui.Color(0, 0, 1, 1), "Back", 18, "center")
err.title= gui.TextButton(20, 20, 200, 50, gui.Color(0, 0, 1, 1), "ERROR", 18, "center")
err.err= gui.TextButton(20, 70, 200, 50, gui.Color(0, 0, 1 ,1), "UNUSED", 18, "center")

err.back:onClick(function (pt, button, presses)
  if (enabled and err.back:contains(pt) and button==1) then
    wait(0.05, function () state.switch(oldState) end)
  end
end)

err.switchto = function ()
  enabled=true
  log.error("ERROR")
  end
err.switchaway = function () 
  enabled=false
end
function err.mousemoved() end
function err.textinput() end
function err.keypressed() end
function err.wheelmoved() end
function err.draw() 
  err.back:draw()
  err.title:draw()
  err.err:draw()
end
function err.update(dt)
  wait.update()
  flux.update(dt)
  local pt = math.Point2D(love.mouse.getPosition())
  err.back:update(dt, pt)
end
err.setState = function (old) oldState=old end
return err