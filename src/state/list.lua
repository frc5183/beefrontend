local list = {}
local items={}
local items_lookup={}
local http = require"socket.http"
local settings = require"state.settings"
local state = require"lib.state"
local dump = require"lib.dump"
local refresh
local ltn12 = require"ltn12"
local main
local json = require"lib.external.json"
local token
local start=1
list.name="list"
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
function refresh () 
  local resbody = {}
  print(token)
  local r, c, h = http.request({
      method="GET",
      url = settings.urlText:getText() .. "/items/all",
      headers={authorization=token}, sink = ltn12.sink.table(resbody)})
  start=1
  print(dump.dump2({r, c, h, resbody}))
  for k, v in ipairs(resbody) do
    print("AAAAAAAAAA")
    print(dump.dump2(v))
    local t = json.decode(v).data
    print(dump.dump2(t))
    item[k]=json.decode(t
      
      )
  end
    
  for k, v in pairs(items) do items_inverse[v]=k end
  
  for k=1, 10 do 
    items["item" .. (k-1)]:setText()
  end
end

function up() end

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
list.setMenu = function (m) main=m end
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
list.back:onRelease(function () 
    state.switch(main)
    end)
gooi.setGroupEnabled("list", false)
return list