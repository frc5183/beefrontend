local list 
local http = require"http"
local settings = require"state.settings"
local state = require"lib.state"
local dump = require"lib.dump"
local refresh
local main
local json = require"lib.external.json"
local token
local newMode = false
local item = {}
local activeItem = {id = "NIL" }
local canEdit
item.loaded=false
item.name="item"
item.setMain = function(Main) main=Main end
item.setList = function(List) list=List end
item.setActiveItem = function(newItem) activeItem=newItem end
item.setCanEdit = function(edit) canEdit=edit end
item.switchto = function () gooi.setGroupEnabled("item", true) end
item.switchaway = function () gooi.setGroupEnabled("item", false) newMode=false end
local id
item.setNewMode = function(val) newMode=val end

item.load = function ()
  
  local func
  if (canEdit) then func = gooi.newText else func = gooi.newLabel end
  
item.title = func{
  text=activeItem.name,
  x=20,
  y=20,
  w=100,
  h=50,
  group="item"
}
if (not newMode) then
item.checkouts = gooi.newButton{
  text="Checkouts",
  x=20,
  y=70,
  w=100,
  h=50,
  group="item",
}
end
item.price = gooi.newLabel{
  text="Price",
  x=20,
  y=120,
  w=100,
  h=50,
  group="item"
}
item.pricetext = func{
  text=activeItem.price,
  x=20,
  y=170,
  w=100,
  h=50,
  group="item"
}
item.id = gooi.newLabel{
  text="ID: " .. activeItem.id,
  x=20,
  y=220,
  w=100,
  h=50,
  group="item"
}
item.photo = gooi.newLabel{
  text="Photo Link",
  x=20,
  y=270,
  w=100,
  h=50,
  group="item"
}
item.phototext = func{
  text=activeItem.photo,
  x=20,
  y=320,
  w=100,
  h=50,
  group="item"
}
item.part = gooi.newLabel{
  text="Part Number",
  x=20,
  y=370,
  w=100,
  h=50,
  group="item"
}
item.parttext = func{
  text=activeItem.partNumber,
  x=20,
  y=420,
  w=100,
  h=50,
  group="item"
}
item.retailer = gooi.newLabel{
  text="Retailer",
  x=20,
  y=470,
  w=100,
  h=50,
  group="item"
}
item.retailertext = func{
  text=activeItem.retailer,
  x=20,
  y=520,
  w=100,
  h=50,
  group="item"
}
item.description = func{
  text=activeItem.description,
  x=20,
  y=570,
  w=100,
  h=50,
  group="item"
}
if (canEdit) then
item.save = gooi.newButton{
  text="Save Item",
  x=20,
  y=620,
  w=100,
  h=50,
  group="item"
}
item.save:onRelease(function ()
    local r, c, h, resbody
    if (not newMode) then
    list.items_list[id].photo = item.phototext:getText()
    list.items_list[id].retailer = item.retailertext:getText()
    list.items_list[id].description = item.description:getText()
    list.items_list[id].price = item.pricetext:getText()
    list.items_list[id].name=item.title:getText()
    list.items_list[id].partNumber=item.parttext:getText()
    r, c, h, resbody = http.complete("PATCH", "/items/" .. id, nil, list.items_list[id], true)
  else 
    local out = {photo=item.phototext:getText(), retailer=item.retailertext:getText(), description=item.description:getText(), price=item.pricetext:getText(), name=item.title:getText(), partNumber=item.parttext:getText(), checkout="", checkouts=""}
    r, c, h, resbody = http.complete("POST", "/items/new", nil, out, true)
    
  end
    list.reset()
    state.switch(list)
  end)
end
item.back = gooi.newButton{
  text="Back",
  x=20,
  y=670,
  w=100,
  h=50,
  group="item"
  
}
item.back:onRelease(function () state.switch(list) end)

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
  item.parttext:setText(activeItem.partNumber)
  id=activeItem.id
end

gooi.setGroupEnabled("item", false)
return item