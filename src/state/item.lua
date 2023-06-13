local list 
local http = require"http"
local settings = require"state.settings"
local state = require"lib.state"
local dump = require"lib.dump"
local refresh
local main
local json = require"lib.external.json"
local token
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
item.switchaway = function () gooi.setGroupEnabled("item", false) end
local id

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
item.checkouts = gooi.newButton{
  text="Checkouts",
  x=20,
  y=70,
  w=100,
  h=50,
  group="item",
  }
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
item.retailer = gooi.newLabel{
  text="Retailer",
  x=20,
  y=370,
  w=100,
  h=50,
  group="item"
}
item.retailertext = func{
  text=activeItem.retailer,
  x=20,
  y=420,
  w=100,
  h=50,
  group="item"
}
item.description = func{
  text=activeItem.description,
  x=20,
  y=470,
  w=100,
  h=50,
  group="item"
}
item.save = gooi.newButton{
  text="Save Item",
  x=20,
  y=520,
  w=100,
  h=50,
  group="item"
}
item.save:onRelease(function ()
    list.items_list[id].photo = item.phototext:getText()
    list.items_list[id].retailer = item.retailertext:getText()
    list.items_list[id].description = item.description:getText()
    list.items_list[id].price = item.pricetext:getText()
    list.items_list[id].name=item.title:getText()
    local r, c, h, resbody = http.complete("PATCH", "/items/" .. id, nil, list.items_list[id], true)
    print(dump.dump2{r, c, h, resbody})
    list.reset()
    state.switch(list)
    end)
item.back = gooi.newButton{
  text="Back",
  x=20,
  y=570,
  w=100,
  h=50,
  group="item"
  
}
item.back:onRelease(function () state.switch(list) end)
gooi.setGroupEnabled("item", false)

end

item.reload = function () 
  item.title:setText(activeItem.name)
  item.pricetext:setText(tostring(activeItem.price))
  item.id:setText("ID: " .. activeItem.id)
  item.phototext:setText(activeItem.photo)
  item.retailertext:setText(activeItem.retailer)
  item.description:setText(activeItem.description)
  gooi.setGroupEnabled("item", false)
  id=activeItem.id
end
gooi.setGroupEnabled("item", false)

return item