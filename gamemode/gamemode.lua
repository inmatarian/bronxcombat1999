
local object = require 'object'

local gamemode = object {
  init_gamemode = function(self)
    self.children = {}
    self._children_index = {}
    return self
  end,

  add_child = function(self, ...)
    for i = 1, select('#', ...) do
      local child = select(i, ...)
      if self._children_index[child] then
        table.remove(self.childen, self._children_index[child])
      end
      self.children[#self.children+1] = child
      self._children_index[child] = #self.children
    end
    return self
  end,

  remove_child = function(self, ...)
    for i = 1, select('#', ...) do
      local child = select(i, ...)
      if self._children_index[child] then
        table.remove(self.childen, self._children_index[child])
        self._children_index[child] = nil
      end
    end
    return self
  end,

  draw_childen = function(self, ...)
    local C = object.extend({}, self.children)
    table.sort(C, self._child_compare)
    for i = 1, #C do
      C[i]:send('draw', ...)
    end
    return self
  end,

  _child_compare = function(left, right)
    local lz, rz = left.z or 0, right.z or 0
    return lz < rz
  end,

  update_childen = function(self, ...)
    local C = object.extend({}, self.children)
    for i = 1, #C do
      C[i]:send('update', ...)
    end
    return self
  end,
}

return gamemode

