-- Imports
local http = require"http"
local settings = require"state.settings"
local state = require"lib.state"
local dump = require"lib.dump"
local json = require"lib.external.json"
local item = require"state.item"
local flux = require"lib.external.flux"
local log = require"lib.log"
local wait = require"lib.wait"
local gui = require"lib.gui"
-- State Info and Basic Content
local list = {
  name="list",
  title = gui.TextButton(20, 20, 200, 50, gui.Color(0, 0, 1, 1), "Items: ", 18, "center"),
  refresh = gui.TextButton(20, 70, 200, 50, gui.Color(0, 0, 1 ,1), "Refresh", 18, "center"),
  up = gui.TextButton(20, 120, 200, 50, gui.Color(0, 0, 1, 1), "Scroll Up", 18, "center"),
  down = gui.TextButton(20, 670, 200, 50, gui.Color(0, 0, 1, 1), "Scroll Down", 18, "center"),
  back = gui.TextButton(20, 720, 200, 50, gui.Color(0, 0, 1, 1), "Back", 18, "center")
}
for k=0, 9 do 
  list["item" .. (k+1)] = gui.TextButton(20, 170+(k*50), 200, 50, gui.Color(0, 0, 1, 1), "Item Placeholder " .. (k+1), 18, "center")
      
end
-- Local Shared Variables
local items={}
local items_lookup={}
local start=1
local canEdit = true
local enabled = false
local main
-- Item Configurations and Load Functions
item.setCanEdit(canEdit)
item.setList(list)
item.load()
local function refresh () 

  local r, c, h, resbody = http.complete("GET", "/items/all", {}, {}, true)
  log.info("HTTP Response Code: " .. c or "")
  start=1
    local t = json.decode(resbody)
    
      items=t.data
    
  for k, v in pairs(items) do items_lookup[v]=k end
  
  for k=1, math.min(#items, 10) do 
    list["item" .. (k)]:setText(items[k].name)
    list["item" .. (k)].item = items[k]
    if (list["item" .. (k)].oldid~=nil) then 
      local t=list["item" .. (k)].oldid
      
      list["item" .. (k)]:removeOnClick( t )
    end
    list["item" .. (k)].oldid = list["item" .. (k)]:onClick(function (pt, button, presses)
        if (enabled and list["item" .. (k)]:contains(pt) and button==1) then
          item.setActiveItem(list["item" .. (k)].item)
          item.reload()
          wait(0.05, function () state.switch(item) end)
        end
      end)
    end
  list.items_list = items
list.items_lookup = items_lookup
end
list.reset=refresh
local function up() 
  if (items_lookup[list.item1.item]==1) then return end
  for k=1, 10 do
    local item = list["item" .. (k)]
    local indexitem = items_lookup[item.item]
    if not indexitem then return end
    item:setText(items[indexitem-1].name)
    item.item = items[indexitem-1]
  end
end
local function down()
  if (items_lookup[list.item10.item]==#items) then return end
  for k=1, 10 do
    local item = list["item" .. (k)]
    local indexitem = items_lookup[item.item]
    if not indexitem then return end
    item:setText(items[indexitem+1].name)
    item.item = items[indexitem+1]
  end
end



list.items_list = items
list.items_lookup = items_lookup
if (canEdit) then
  
  list.newitem = gui.TextButton(240, 120, 200, 50, gui.Color(0, 0, 1, 1), "New Item", 18, "center")
list.newitem:onClick(function (pt, button, presses)
    if (enabled and list.newitem:contains(pt) and button==1) then
      
    item.setNewMode(true)
    item.reload()
    wait(0.05, function () state.switch(item) end)
    end
  end
)
end

-- Button Callbacks
list.refresh:onClick(function (pt, button) if (enabled and list.refresh:contains(pt) and button==1) then refresh() end end)
list.up:onClick(function (pt, button) if (enabled and list.up:contains(pt) and button==1) then up() end end)
list.down:onClick(function (pt, button) if (enabled and list.down:contains(pt) and button==1) then down() end end)
list.back:onClick(function (pt, button) if (enabled and list.back:contains(pt) and button==1) then 
    wait(0.05, function () state.switch(main) end)
     end end)

--State Switch Functions
list.switchto = function () enabled=true
  refresh() end
list.switchaway = function () enabled=false  end
-- State Love2D Functions
function list.mousemoved() end
function list.textinput() end
function list.keypressed() end
function list.wheelmoved() end
function list.draw() 
  list.back:draw()
  list.up:draw()
  list.down:draw()
  list.refresh:draw()
  if (canEdit) then list.newitem:draw() end
  for k=1, 10 do
    local item = list["item" .. (k)]
    item:draw()
  end
end
function list.update(dt)
  wait.update()
  flux.update(dt)
  local pt = math.Point2D(love.mouse.getPosition())
  list.back:update(dt, pt)
  list.up:update(dt, pt)
  list.down:update(dt, pt)
  list.refresh:update(dt, pt)
  if (canEdit) then list.newitem:update(dt, pt) end
  for k=1, 10 do
    local item = list["item" .. (k)]
    item:update(dt, pt)
  end
end
-- State Data-Chain Functions
list.setMenu = function (m) main=m  item.setMain(main) end

--Return State
return list