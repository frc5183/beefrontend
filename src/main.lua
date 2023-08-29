local state = require "lib.state"
local assetloader = require "lib.assetloader"
local Sizer = require "lib.gui.subsystem.Sizer"
local menu = require"state.menu"
require "lib.math2".integrate(math)
local om = love.mouse.getPosition
function love.mouse.getPosition()
  local x, y = om()
  x = x or -1
  y = y or -1
  return x, y
end

function love.load()
  assetloader.start()
  Sizer.init(720, 1280)
end

function love.update(dt)
  assetloader.update()
  if assetloader.isFinished() then
    print("FINISHED")
    for k, v in pairs(menu) do print(k, v) end
    menu.load()
    state.switch(menu)
  end
end

function love.draw()
  Sizer.begin()
  love.graphics.print("Loading")
  Sizer.finish()
end
