local oldState
local state = require"lib.state"
local err={}
err.name="err"
err.back = gooi.newButton({
    text="Back",
    x=20,
    y=120,
    w=100,
    h=50,
    group="err"
  })
err.title = gooi.newLabel({
    text="ERROR",
    x=20,
    y=20,
    w=100,
    h=50,
    group="err"
  }
)
err.err=gooi.newLabel({
    text="UNUSED",
    x=20,
    y=70,
    w=500,
    h=50,
    group="err"
    
  }
)

err.switchto = function () gooi.setGroupEnabled("err", true) end
err.switchaway = function () gooi.setGroupEnabled("err", false) end
err.back:onRelease(function () 
    state.switch(oldState)
  end)
err.setState = function (old) oldState=old end
gooi.setGroupEnabled("err", false)
return err