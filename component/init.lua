-- components package

local modules = {
  'actor',
  'colored',
  'image',
  'jumper_physics',
  'zindex',
}

local package = select(1, ...)
local exports = {}
for _, modname in ipairs(modules) do
  exports[modname] = require(package .. '.' .. modname)
end
return exports

