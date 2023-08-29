require"love.graphics"
---@type love.Image
local bee = love.graphics.newImage("asset/png/bee.png")
---@type love.Channel
local channel = love.thread.getChannel("assets")
channel:push({category="beefrontend_png", id="beepng", asset=bee})