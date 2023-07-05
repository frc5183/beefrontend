-- Imports
local http = require"http"
local settings = require"state.settings"
local state = require"lib.state"
local dump = require"lib.dump"
local json = require"lib.external.json"
local flux = require"lib.external.flux"
local wait = require"lib.wait"
local log = require"lib.log"
local gui = require"lib.gui"
-- State Info and Basic Content
local item = {
  name="item",
}
-- Local Shared Variables
local activeItem={
  name="New Item",
  price = "0",
  id="ID Available After Creation",
  photo = "photo",
  retailer = "retailer",
  description="description",
  partNumber="0x000000"
}
local enabled = false
local newMode = false
local list 
local refresh
local main
local token
local canEdit
local id
-- State Load Functions
item.load = function ()
  if (item.price) then return end
  local func
  if (canEdit) then func = gui.TextInput else func = gui.TextButton end
  item.title = func(20, 20, 200, 50, gui.Color(0, 0, 1, 1), activeItem.name, 18, "left", "normal")
    item.checkouts = gui.TextButton(20, 70, 200, 50, gui.Color(0, 0, 1, 1), "Checkouts", 18, "center")
  item.price = gui.TextButton(20, 120, 200, 50, gui.Color(0, 0, 1, 1), "Price", 18, "center")
  item.pricetext = func(20, 170, 200, 50, gui.Color(0, 0, 1, 1), activeItem.price, 18, "left", "normal")
  item.id = gui.TextButton(20, 220, 200, 50, gui.Color(0, 0, 1, 1), "ID: " .. activeItem.id, 18, "center")
  item.photo = gui.TextButton(20, 270, 200, 50, gui.Color(0, 0, 1, 1), "Photo Link", 18, "center")
  item.phototext = func(20, 320, 200, 50, gui.Color(0, 0, 1, 1), activeItem.photo, 18, "left", "normal")
  item.part = gui.TextButton(20, 370, 200, 50, gui.Color(0, 0, 1, 1), "Part Number", 18, "center")
  item.parttext = func(20, 420, 200, 50, gui.Color(0, 0, 1, 1), activeItem.partNumber, 18, "left", "normal")
  item.retailer = gui.TextButton(20, 470, 200, 50, gui.Color(0, 0, 1, 1), "Retailer", 18, "center")
  item.retailertext = func(20, 520, 200, 50, gui.Color(0, 0, 1, 1), activeItem.retailer, 18, "left", "normal")
  item.description = func(20, 570, 200, 50, gui.Color(0, 0, 1, 1), activeItem.description, 18, "left", "normal")
  if (canEdit) then
  item.save = gui.TextButton(20, 620, 200, 50, gui.Color(0, 0, 1, 1), "Save Item", 18, "center")
  item.save:onClick(function (pt, button, presses)
      if (enabled and item.save:contains(pt) and button==1) then 
        local r, c, h, resbody
    if (not newMode) then
    list.items_list[id].photo = item.phototext:getText()
    list.items_list[id].retailer = item.retailertext:getText()
    list.items_list[id].description = item.description:getText()
    list.items_list[id].price = item.pricetext:getText()
    list.items_list[id].name=item.title:getText()
    list.items_list[id].partNumber=item.parttext:getText()
    r, c, h, resbody = http.complete("PATCH", "/items/" .. id, nil, list.items_list[id], true)
    log.info("HTTP Response Code: " .. c or ""  )
  else 
    local out = {photo=item.phototext:getText(), retailer=item.retailertext:getText(), description=item.description:getText(), price=item.pricetext:getText(), name=item.title:getText(), partNumber=item.parttext:getText(), checkout="", checkouts=""}
    r, c, h, resbody = http.complete("POST", "/items/new", nil, out, true)
    log.info("HTTP Response Code: " .. c or "")
  end
    list.reset()
    wait(0.05, function () state.switch(list) end)
    end
  end)
end
  item.back = gui.TextButton(20, 670, 200, 50, gui.Color(0, 0, 1 ,1), "Back", 18, "center")
  item.back:onClick(function (pt, button, pushes)
      if (enabled and item.back:contains(pt) and button==1) then
        wait(0.05, function () state.switch(list) end)
      end
  end)
end

item.reload = function () 
  
  if (newMode) then activeItem={
      name="New Item",
      price = "0",
      id="ID Available After Creation",
      photo = "photo",
      retailer = "retailer",
      description="description",
      partNumber="0x000000"
      }
    end
  item.title:setText(activeItem.name)
  item.pricetext:setText(tostring(activeItem.price))
  item.id:setText("ID: " .. activeItem.id)
  item.phototext:setText(activeItem.photo)
  item.retailertext:setText(activeItem.retailer)
  item.description:setText(activeItem.description)
  print(activeItem.partnumber)
  item.parttext:setText(activeItem.partNumber or "")
  id=activeItem.id
end
-- State Switch Functions
item.switchto = function () enabled=true
  if (canEdit) then
  item.pricetext:enable()
  item.phototext:enable()
  item.retailertext:enable()
  item.description:enable()
  item.parttext:enable()
  item.title:enable()
  end
  end
item.switchaway = function ()
  enabled=false
  if (canEdit) then
  item.pricetext:disable()
  item.phototext:disable()
  item.retailertext:disable()
  item.description:disable()
  item.parttext:disable()
  item.title:disable()
  end
  newMode=false end
-- State Love2D Functions
item.update = function (dt)
  wait.update()
    local pt = math.Point2D(love.mouse.getPosition())
    flux.update(dt)
    item.back:update(dt, pt)
    if (canEdit) then
      item.save:update(dt, pt)
      item.pricetext:update(dt, pt)
      item.phototext:update(dt, pt)
      item.retailertext:update(dt, pt)
      item.description:update(dt, pt)
      item.parttext:update(dt, pt)
      item.title:update(dt, pt)
    end
  end

function item.mousemoved(x, y, dx, dy, istouch)
  if (canEdit) then
    item.pricetext:mousemoved(x, y)
    item.phototext:mousemoved(x, y)
    item.retailertext:mousemoved(x, y)
    item.description:mousemoved(x, y)
    item.parttext:mousemoved(x, y)
    item.title:mousemoved(x, y)
  end
end
function item.textinput(text)
  if (canEdit) then
    item.pricetext:textinput(text)
    item.phototext:textinput(text)
    item.retailertext:textinput(text)
    item.description:textinput(text)
    item.parttext:textinput(text)
    item.title:textinput(text)
  end
end
function item.keypressed(key, scancode, isrepeat)
  if (canEdit) then
    item.pricetext:keypressed(key, scancode, isrepeat)
    item.phototext:keypressed(key, scancode, isrepeat)
    item.retailertext:keypressed(key, scancode, isrepeat)
    item.description:keypressed(key, scancode, isrepeat)
    item.parttext:keypressed(key, scancode, isrepeat)
    item.title:keypressed(key, scancode, isrepeat)
  end
end
function item.wheelmoved(dx, dy)
  if (canEdit) then
    item.pricetext:wheelmoved(dx, dy)
    item.phototext:wheelmoved(dx, dy)
    item.retailertext:wheelmoved(dx, dy)
    item.description:wheelmoved(dx, dy)
    item.parttext:wheelmoved(dx, dy)
    item.func:wheelmoved(dx, dy)
  end
end
function item.draw()
  
  item.price:draw()
  item.pricetext:draw()
  item.id:draw()
  item.photo:draw()
  item.phototext:draw()
  item.retailer:draw()
  item.retailertext:draw()
  item.description:draw()
  item.parttext:draw()
  item.part:draw()
  item.back:draw()
  item.title:draw()
  if (not newMode) then item.checkouts:draw() end
  if item.save then item.save:draw() end
end
-- State Data-Chain Functions
item.setMain = function(Main) main=Main end
item.setList = function(List) list=List end
item.setActiveItem = function(newItem) activeItem=newItem end
item.setCanEdit = function(edit) canEdit=edit end
item.setNewMode = function(val) newMode=val end

--Return State
return item