
local object = require 'object'
local timer = require 'timer'
local input = require 'input'
local graphics = require 'graphics'
local color = require 'color'
local rectangle = require 'rectangle'
local gamemode = require 'gamemode.gamemode'
local component = require 'component'

local annoying_text = object(component.colored, {

  some_primes = { 29, 31, 59, 61, 89,  97, 127, 131 },

  _init = function(self)
    self:color(color.RED)
    self.clock = 0
    self:on('draw', self:bind(self.draw_text))
    self.timer = timer:create_interval(0.5, self:bind(self.update_text))
  end,

  draw_text = function(self)
    graphics:set_color(self:color())
    graphics:write("center", 140, "Winners Don't Play Videogames")
  end,

  update_text = function(self, dt)
    local c = self:color()
    c = c:hue(c:hue() + self.some_primes[math.random(1, #self.some_primes)])
    self:color(c)
  end,
})


local amazing_rectangle_sprite = object(component.image, component.colored,
  component.zindex, component.jumper_physics, {

  x = 0,
  y = 0,

  _init = function(self)
    self:color(color.PUREWHITE)
    self:load_image("shield.png")
    self:jumper_physics_init(rectangle {
      x=4, y=4,
      w=self:image_width()-8,
      h=self:image_width()-8
    })
    self:on('draw', self:bind(self.draw_that_shit))
    self:on('update', self:bind(self.update_that_shit))
    return self
  end,

  draw_that_shit = function(self)
    graphics:set_color(self:color())
    self:draw_image(math.floor(self.x), math.floor(self.y))
  end,

  update_that_shit = function(self, dt)
    self:jumper_physics_apply_controls(input.hold.left, input.hold.right, input.holdlen.jump)
    self:jumper_physics_apply_forces(dt)
  end,

  get_world_tiledatum = function(x, y)
    if (y >= 0) and (y < 8) and (x >= 0) and (x < 15) then return 0 else return 256 end
  end
})


local shieldmode = gamemode({
  _init = function(self)
    self:init_gamemode()
    self.player = amazing_rectangle_sprite({x=80, y=20})
    self:add_child(self.player, annoying_text())
    self:on('update', self:bind(self.update_sheildstate))
    self:on('draw', self:bind(self.draw_sheildstate))
  end,

  update_sheildstate = function(self, dt, ...)
    self:update_childen(dt, ...)
  end,

  draw_sheildstate = function(self, ...)
    self:draw_childen(...)
  end,
})

return shieldmode

