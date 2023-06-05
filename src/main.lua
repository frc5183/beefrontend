local log = require"lib.log"
local state = require"lib.state"
require"lib.external.gooi"
require"lib.math2".integrate(math)
--local https = require"https"
local http = require"http"
local button
local menu=require"state.menu"


gooi.desktopMode()
function love.load()
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