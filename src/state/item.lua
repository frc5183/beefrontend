-- Imports
local http = require "http"
local state = require "lib.state"
local json = require "lib.external.json"
local flux = require "lib.external.flux"
local wait = require "lib.wait"
local err = require "state.error"
local math2 = require "lib.math2"
local constant = require "constant"
local canEdit = true
local list
local gui = require "lib.gui"
---@type table
local activeItem = {
  name = "New Item",
  price = "0",
  id = "ID Available After Creation",
  photo = "photo",
  retailer = "retailer",
  description = "description",
  partNumber = "0x000000"
}
---@type table
local item = {}
---@type Container
local container

local function newitem()
  return {
    name = "New Item",
    price = "0",
    id = "ID Available After Creation",
    photo = "photo",
    retailer = "retailer",
    description = "description",
    partNumber = "0x000000"
  }
end
---@param isNew boolean
local function load(isNew)
  if isNew then activeItem = newitem() end
  local list_builder = gui.List(0, 40, 20, 660, 1140, constant.buttonForegroundColor, 10)
  local save
  local func
  local func2
  local a, b, c
  if (canEdit) then
    func = list_builder.TextInput
    a = "normal"
    b = constant.textColor
    c = constant.buttonBackgroundColor
    save = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Save Item", 18, "center", b, c)
  else
    func = list_builder.TextRectangle
    a = constant.textColor
    b = constant.buttonBackgroundColor
    c = nil
  end
  local _texts = {}
  local _item = {
    name = "item",
    save = save,
    back = list_builder.TextButton(640, 50, constant.buttonForegroundColor, "Back", 18, "center", b, c),
    title = func(640, 50, constant.buttonForegroundColor, activeItem.name, 18, "left", a, b, c),
    price = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Price", 18, "center", b, c),
    priceText = func(640, 50, constant.buttonForegroundColor, activeItem.price, 18, "left", a, b, c),
    id = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "ID: " .. activeItem.id, 18, "center", b, c),
    photo = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor,
      "Photo RawData (Future will have image-taking and display)", 18, "center", b, c),
    photoText = func(640, 50, constant.buttonForegroundColor, activeItem.photo, 18, "left", a, b, c),
    part = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Part Number", 18, "center", b, c),
    partText = func(640, 50, constant.buttonForegroundColor, activeItem.partNumber or "", 18, "left", a, b, c),
    retailer = list_builder.TextRectangle(640, 50, constant.buttonForegroundColor, "Retailer", 18, "center", b, c),
    retailerText = func(640, 50, constant.buttonForegroundColor, activeItem.retailer, 18, "left", a, b, c),
    description = func(640, 50, constant.buttonForegroundColor, activeItem.description, 18, "left", a, b, c),
  }
  container = gui.Container(0, 0, 720, 1280, constant.buttonForegroundColor, 720, 1280)
  container:add(list_builder.construct())
  container:add(_item.back)
  for k, v in pairs(_item) do
    item[k] = v
  end
  if save then
    container:add(_item.save)
    table.insert(_texts, _item.title)
    table.insert(_texts, _item.priceText)
    table.insert(_texts, _item.photoText)
    table.insert(_texts, _item.partText)
    table.insert(_texts, _item.retailerText)
    table.insert(_texts, _item.description)
    save:onClick(function(pt, button, presses)
      if (save:contains(pt) and button == 1) then
        local r, c, h, resbody
        if isNew then
          local out = {
            photo = _item.photoText:getText(),
            retailer = _item.retailerText:getText(),
            description = _item.retailerText:getText(),
            price = _item.priceText:getText(),
            name = item.title:getText(),
            partNumber = item.partText:getText(),
            checkout = "",
            checkouts = ""
          }
          r, c, h, resbody = http.complete("POST", "/items/new", nil, out, true)
          if (c ~= 201) then
            pcall(function()
              err.setState(list)
              err.load()
              local resbody = json.decode(resbody)
              err.title:setText(resbody.status)
              err.err:setText(resbody.message)
              state.switch(err)
            end)
            wait(0.05, function() state.switch(err) end)
          else
            list.load()
            wait(0.05, function() state.switch(list) end)
          end
        else
          local out = {
            photo = _item.photoText:getText(),
            retailer = _item.retailerText:getText(),
            description = _item.retailerText:getText(),
            price = _item.priceText:getText(),
            name = item.title:getText(),
            partNumber = item.partText:getText(),
            checkout = activeItem.checkout or "",
            checkouts = activeItem.checkouts or ""
          }
          r, c, h, resbody = http.complete("PATCH", "/items/" .. activeItem.id, nil, activeItem.id, true)
          if c ~= 200 then
            pcall(function()
              err.setState(list)
              err.load()
              local resbody = json.decode(resbody)
              err.title:setText(resbody.status)
              err.err:setText(resbody.message)
            end)
            wait(0.05, function() state.switch(err) end)
          end
        end
      end
    end)
  end
  _item.back:onClick(function(pt, button, presses)
    if (_item.back:contains(pt) and button == 1) then
      list.load()
      wait(0.05, function() state.switch(list) end)
    end
  end)
  function item.draw()
    gui.Sizer.begin()
    container:draw()
    gui.Sizer.finish()
  end

  function item.update(dt)
    wait.update()
    local x, y = love.mouse.getPosition()
    local x, y = gui.Sizer.translate(x, y)
    local pt = math2.Point2D(x, y)
    flux.update(dt)
    container:update(dt, pt)
  end

  function item.mousemoved(x, y, dx, dy, istouch)
    local x, y = gui.Sizer.translate(x, y)
    local dx, dy = gui.Sizer.scale(dx, dy)
    container:mousemoved(x, y, dx, dy, istouch)
  end

  function item.keypressed(key, scancode, isRepeat)
    container:keypressed(key, scancode, isRepeat)
  end

  function item.textinput(text)
    container:textinput(text)
  end

  function item.wheelmoved(dx, dy, x, y)
    local x, y = gui.Sizer.translate(x, y)
    container:wheelmoved(dx, dy, x, y)
  end

  function item.mousepressed(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:press(math2.Point2D(x, y), button, presses)
  end

  function item.mousereleased(x, y, button, istouch, presses)
    local x, y = gui.Sizer.translate(x, y)
    container:click(math2.Point2D(x, y), button, presses)
  end

  item.switchto = function()
    for k, v in ipairs(_texts) do
      v:enable()
    end
  end
  item.switchaway = function()
    for k, v in ipairs(_texts) do
      v:disable()
    end
  end
  item.load = load
  item.setList = function(List) list = List end
  item.setActiveItem = function(newItem) activeItem = newItem end
end
load(false)
return item
