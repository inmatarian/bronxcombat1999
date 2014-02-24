-- maintains its own clock, don't use timer
-- remember to call animation_update or bind an event
-- self:on("update", self:bind(self.update_animations))


local animated = {

  animation_init = function(self, patterns)
    self.animator = {
      clock = 0,
      index = 1,
      length = 0,
      frame = 0,
      current = 'default',
      pattern = patterns,
    }
  end,

  animation_update = function(self, dt)
    local anim = self.animator
    if (anim.current) and (anim.length ~= 'freeze') then
      anim.clock = anim.clock + dt
      if anim.clock >= anim.length then
        local pattern = anim.patterns[anim.current] or anim.patterns.default
        assert(pattern, "Current pattern not set!")
        anim.clock = anim.clock - anim.length
        anim.index = (anim.index % #pattern) + 1
        anim.frame = pattern[anim.index][1]
        anim.length = pattern[anim.index][2]
      end
    end
  end,

  animation_set = function(self, name)
    if self.animator.current ~= name then self:animation_reset(name) end
    return self
  end,

  animation_reset = function(self, name)
    self.animator.index = 1
    self.animator.clock = 0
    if self.animator.patterns[name] then
      self.animator.current = name
      self.animator.frame = self.animator.patterns[name][1][1]
      self.animator.length = self.animator.patterns[name][1][2]
    else
      self.animator.current = nil
      self.animator.frame = 0
      self.animator.length = nil
    end
    return self
  end,

  animation_frame = function(self)
    return self.animator.frame
  end,
}

return animated

