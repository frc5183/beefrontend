local log = require"lib.log"
local state = require"lib.state"
local settings = {}
local json = require"lib.external.json"
local menu;
local f = love.filesystem.newFile("settings.json")
  f:open"r"
  local c = f:read()
  local tbl
  pcall(function ()
   tbl = json.decode(c) end)
  if tbl==nil then tbl={username="", password="", url=""} end
settings.name="settings"
settings.user=gooi.newButton({
    text="Username",
    x=20,
    y=20,
    w=100,
    h=50,
    group="settings"
  }
)


settings.pass=gooi.newButton({
    text="Password",
    x=20,
    y=120,
    w=100,
    h=50,
    group="settings"
  }
)
---[[
settings.userText=gooi.newText({
    text=tbl.username,
    x=20,
    y=70,
    w=200,
    h=50,
    group="settings"
  }
)
--]]
settings.passText=gooi.newText({
    text=tbl.password,
    x=20,
    y=170,
    w=200,
    h=50,
    group="settings"
  }
)
settings.urlText=gooi.newText({
    text=tbl.url,
    x=20,
    y=270,
    w=200,
    h=50,
    group="settings"
  }
)
--]]
settings.url=gooi.newButton({
    text="ServerURL",
    x=20,
    y=220,
    w=100,
    h=50,
    group="settings"
  }
)
settings.back=gooi.newButton({
    text="Back",
    x=20,
    y=370,
    w=100,
    h=50,
    group="settings"
  }
)
settings.save=gooi.newButton({
    text="Save",
    x=20,
    y=320,
    w=100,
    h=50,
    group="settings"
  }
)
settings.save:onRelease(function () local str = json.encode{password=settings.passText:getText(), username=settings.userText:getText(), url=settings.urlText:getText()}
    love.filesystem.remove("settings.json")
  local f = love.filesystem.newFile("settings.json")
  f:open"a"
  f:write(str)
  f:flush()
  f:close()
  end)
settings.back:onRelease(function () state.switch(menu) end)
settings.setMenu = function (m)
  menu=m
  end
settings.switchto = function () gooi.setGroupEnabled("settings", true) end
settings.switchaway = function () gooi.setGroupEnabled("settings", false) end
gooi.setGroupEnabled("settings", false)
return settings