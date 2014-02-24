
local color = require 'color'

local colored_component = {
  colored_component = "color",

  _color = color.PUREWHITE,
  _backcolor = color.PUREBLACK,

  color = function(self, c)
    if c==nil then return self._color else self._color = c end
    return self
  end,

  backcolor = function(self, c)
    if c==nil then return self._backcolor else self._backcolor = c end
    return self
  end,
}

return colored_component

