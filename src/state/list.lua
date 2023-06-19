local list = {}
local items={}
local items_lookup={}
local http = require"http"
local settings = require"state.settings"
local state = require"lib.state"
local dump = require"lib.dump"
local refresh
local main
local json = require"lib.external.json"
local canEdit = true
local token
local item = require"state.item"
local start=1
list.name="list"
item.setCanEdit(canEdit)
item.setList(list)
item.load()
list.items_list = items
list.items_lookup = items_lookup
list.setToken = function (newToken) token=newToken end
list.switchto = function () gooi.setGroupEnabled("list", true) refresh() end
list.switchaway = function () gooi.setGroupEnabled("list", false) end
  list.title=gooi.newLabel({
      text="Items: ",
      x=20,
      y=20,
      w=100,
      h=50,
      group="list"
  }
)
for k=0, 9 do 
  list["item" .. (k+1)] = gooi.newButton({
      text="Item Placeholder ".. (k+1),
      x=20, 
      y=170+(k*50),
      w=100,
      h=50,
      group="list"
    }
    )
      
end
if (canEdit) then
list.newitem = gooi.newButton({
    text="New Item",
    x=140,
    y=120,
    w=100,
    h=50,
    group="list"
  }
)
list.newitem:onRelease(function ()
    item.setNewMode(true)
    item.reload()
    state.switch(item)
  end
)
end
function refresh () 

  local r, c, h, resbody = http.complete("GET", "/items/all", {}, {}, true)
  start=1
  
    local t = json.decode(resbody)
    
      items=t.data
    
  for k, v in pairs(items) do items_lookup[v]=k end
  
  for k=1, 10 do 
    list["item" .. (k)]:setText(items[k].name)
    list["item" .. (k)].item = items[k]
    list["item" .. (k)]:onRelease(function () 
        
          
          item.setActiveItem(list["item" .. (k)].item)
          item.reload()
          state.switch(item)
        end)
  end
  list.items_list = items
list.items_lookup = items_lookup
end
list.reset=refresh
function up() 
  if (items_lookup[list.item1.item]==1) then return end
  for k=1, 10 do
    local item = list["item" .. (k)]
    local indexitem = items_lookup[item.item]
    item:setText(items[indexitem-1].name)
    item.item = items[indexitem-1]
  end
end
function down()
  if (items_lookup[list.item10.item]==#items) then return end
  for k=1, 10 do
    local item = list["item" .. (k)]
    local indexitem = items_lookup[item.item]
    item:setText(items[indexitem+1].name)
    item.item = items[indexitem+1]
  end
end
list.refresh = gooi.newButton({
    text="Refresh",
    x=20,
    y=70,
    w=100,
    h=50,
    group="list"
  }
)
list.refresh:onRelease(refresh)
list.setMenu = function (m) main=m  item.setMain(main) end
list.up=gooi.newButton({
    text="SCROLL UP",
    x=20,
    y=120,
    w=100,
    h=50,
    group="list"
  }
)
list.down=gooi.newButton({
    text="SCROLL DOWN",
    x=20,
    y=670,
    w=100,
    h=50,
    group="list"
  }
)
list.back=gooi.newButton({
    text="Back",                            
    x=20,
    y=720,
    w=100,
    h=50,
    group="list"
  }
)
list.up:onRelease(up)
list.down:onRelease(down)
list.back:onRelease(function () 
    state.switch(main)
    end)
gooi.setGroupEnabled("list", false)
return list