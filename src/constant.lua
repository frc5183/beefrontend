local Color = require "lib.gui.color"
local safety = require "lib.safety"
local constants
constants = {
    ---@type Color
    backgroundColor = Color(0, 0, 0, 1),
    ---@type Color
    buttonForegroundColor = Color(1, 1, 1, 1),
    ---@type Color
    buttonBackgroundColor = Color(0, 0, 0, 1),
    ---@type Color
    textColor = Color(1, 1, 1, 1),
    ---@type Color
    selectedColor = Color(0, 1, 0, 1),

    ---@type Color
    black = Color(0, 0, 0, 1),
    ---@type Color
    white = Color(1, 1, 1, 1),

    setDarkMode = function(dark)
        safety.ensureBoolean(dark, "dark")
        if dark then
            constants.backgroundColor = constants.black
            constants.buttonForegroundColor = constants.white
            constants.buttonBackgroundColor = constants.black
            constants.textColor = constants.white
        else
            constants.backgroundColor = constants.white
            constants.buttonForegroundColor = constants.black
            constants.buttonBackgroundColor = constants.white
            constants.textColor = constants.black
        end
    end
}

return constants
