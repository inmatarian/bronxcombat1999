
local object = require 'object'
local timer = require 'timer'
local color = require 'color'
local graphics = require 'graphics'
local input = require 'input'

local debugscreen = object {

  active = __TESTING,
  fps = 0,
  mem = 0,

  _init = function(self)
    self.update_clock = timer:create_interval(1, self:bind(self.update_clock))
  end,

  toggle = function(self) self.active = not self.active end,

  draw_debug = function(self)
    if not self.active then return end
    graphics:set_color(color.PUREWHITE)
    graphics:write(0, 0, "FPS:%s Mem:%s KP:%s", self.fps, self.mem, input.lastKey and input.lastKey or ' ')
    if self.player then
      graphics:write(0, 10, "X:%3i Y:%3i", self.player.x, self.player.y)
      graphics:write(0, 20, "dX:%3i dY:%3i", self.player.dx, self.player.dy)
    end
  end,

  update_clock = function(self)
    self.fps = string.format("%3i", love.timer.getFPS())
    local mem = tonumber(collectgarbage("count"))
    if mem >= 1000 then
      self.mem = string.format("%3.1fM", mem/1000)
    else
      self.mem = string.format("%3ik", mem)
    end
  end,

  update_debug = function(self, dt)
    --
  end,
}

return debugscreen

