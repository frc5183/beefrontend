
local log = require"lib.log"
local state = require"lib.state"
require"lib.external.gooi"
require"lib.math2".integrate(math)
local http = require"http"
local button
local menu=require"state.menu"

if (love.system.getOS() == "Windows" or love.system.getOS() == "Linux" or love.system.getOS() == "OS X") then
  gooi.desktopMode()
  log.info("Desktop Mode Enabled")
end
function love.load()
  gooi.setGroupEnabled("item", false)
  gooi.setGroupEnabled("settings", false)
  gooi.setGroupEnabled("list", false)
  gooi.setGroupEnabled("err", false)
  gooi.setGroupEnabled("menu", false)
  state.switch(menu)
end
function love.draw()
  gooi.draw(state.getStateName())
end


function love.mousepressed(x, y, button)     gooi.pressed() end
function love.mousereleased(x, y, button)    gooi.released() end
function love.textinput(text)                gooi.textinput(text) end
function love.keypressed(k, code, isrepeat)  gooi.keypressed(k, code) end
function love.keyreleased(k, code, isrepeat) gooi.keyreleased(k, code) end
function love.update(dt)
  gooi.update(dt)
end