local log = require"lib.log"
local state = require"lib.state"
local http = require"http"
local gui = require"lib.gui"
local menu = require "state.menu"
require"lib.math2".integrate(math)
local om = love.mouse.getPosition
function love.mouse.getPosition()
  local x, y = om()
  x = x or -1
  y = y or -1
  return x, y
end
function love.load()
  state.switch(menu)
end

function love.mousepressed(x, y, button, istouch, presses) 
  gui.ClickPulser:mousePressed(x, y, button, presses)
  
end
function love.mousereleased(x, y, button, istouch, presses)
  gui.ClickPulser:mouseReleased(x, y, button, presses)
end