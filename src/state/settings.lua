local log = require"lib.log"
local state = require"lib.state"
local settings = {}
local json = require"lib.external.json"
local menu;
local f = love.filesystem.newFile("settings.json")
  f:open"r"
  local c = f:read()
  pcall(function ()
   settings.tbl = json.decode(c) end)
  if settings.tbl==nil then settings.tbl={username="", password="", url="", secret="", id="", zerotrust="false"} end
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
    text=settings.tbl.username,
    x=20,
    y=70,
    w=200,
    h=50,
    group="settings"
  }
)
--]]
settings.passText=gooi.newText({
    text=settings.tbl.password,
    x=20,
    y=170,
    w=200,
    h=50,
    group="settings"
  }
)
settings.urlText=gooi.newText({
    text=settings.tbl.url,
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
    y=620,
    w=100,
    h=50,
    group="settings"
  }
)
settings.save=gooi.newButton({
    text="Save",
    x=20,
    y=570,
    w=100,
    h=50,
    group="settings"
  }
)
local check = false;
if settings.tbl.zerotrust=="true" then check=true end
settings.zerotrust = gooi.newCheck{
  text="Zero Trust Enabled",
  x=20,
  y=320,
  w=300,
  h=50,
  group="settings",
  checked=check
}
settings.id = gooi.newButton{
  text="ID",
  x=20,
  y=370,
  w=200,
  h=50,
  group="settings"
}
settings.idtext = gooi.newText{
  text=settings.tbl.id,
  x=20,
  y=420,
  w=400,
  h=50,
  group="settings"
}
settings.secret = gooi.newButton{
  text="Secret",
  x=20,
  y=470,
  w=200,
  h=50,
  group="settings"
} 
settings.secrettext = gooi.newText{
  text=settings.tbl.secret,
  x=20,
  y=520,
  w=600,
  h=50,
  group="settings"
  }
settings.save:onRelease(function () local str = json.encode{secret=settings.secrettext:getText(), zerotrust=tostring(settings.zerotrust.checked), id=settings.idtext:getText(), password=settings.passText:getText(), username=settings.userText:getText(), url=settings.urlText:getText()}
    love.filesystem.remove("settings.json")
  local f = love.filesystem.newFile("settings.json")
  f:open"a"
  f:write(str)
  f:flush()
  f:close()
  settings.tbl=json.decode(str)
  end)
settings.back:onRelease(function () state.switch(menu) end)
settings.setMenu = function (m)
  menu=m
  end
settings.switchto = function () gooi.setGroupEnabled("settings", true) end
settings.switchaway = function () gooi.setGroupEnabled("settings", false) end
gooi.setGroupEnabled("settings", false)
return settings