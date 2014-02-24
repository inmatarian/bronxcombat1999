-- gamemode package

local modules = {
  'gamemode',
  'shield',
}

local package = select(1, ...)
local exports = {}
for _, modname in ipairs(modules) do
  exports[modname] = require(package .. '.' .. modname)
end
return exports

