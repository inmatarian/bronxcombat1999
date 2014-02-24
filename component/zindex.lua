
local z_index_component = {
  z_index_component = "z_index",
  z = 0,

  z_index = function(self, z)
    if z == nil then return self.z else self.z = z end
    return self
  end,
}

return z_index_component

