
local log = require"lib.log"
local state = require"lib.state"
require"lib.math2".integrate(math)
local http = require"http"
local gui = require"lib.gui"
local button
local menu = require "state.menu"
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