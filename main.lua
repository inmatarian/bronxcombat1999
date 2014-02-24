__TESTING = true

require 'global'
local observer = require 'observer'
local object = require 'object'
local timer = require 'timer'
local input = require 'input'
local color = require 'color'
local graphics = require 'graphics'
local component = require 'component'
local gamemode = require 'gamemode'
local debugscreen = require 'debugscreen'

main = object {
  load = function(self)
    graphics:init()
    input:reset()
    self.current_state = gamemode.shield()
    self.debuginfo = debugscreen()
    self.debuginfo.player = self.current_state.player
  end,

  update = function(self, dt)
    if dt > 0.2 then dt = 0.2 end

    input:update(dt)

    if input.tap.screenshot then graphics:save_screenshot() end
    if input.tap.debug_info then self.debuginfo:toggle() end
    if input.tap.changescale then graphics:next_scale() end
    if input.tap.debug_terminate then love.event.quit() end
    if input.tap.fullscreen then graphics:toggle_fullscreen() end

    self.current_state:send("update", dt)
    timer:update_timers(dt)
    self.debuginfo:update_debug(dt)
  end,

  draw = function(self)
    graphics:start()
    self.current_state:send("draw")
    self.debuginfo:draw_debug()
    graphics:stop()
  end,

  resize = function(self, w, h)
    graphics:on_resize(w, h)
  end,
}

-- Fill out love event handlers with Main object calls
for _, callback in ipairs({ "load", "update", "draw", "resize" }) do
  love[callback] = function(...)
    RESET_DEBUG_HOOK()
    main[callback](main, ...)
  end
end

-- All input controls go to the input singleton
for _, callback in ipairs {
  "keypressed", "keyreleased", "textinput",
  "gamepadpressed", "gamepadreleased", "gamepadaxis"
} do
  love[callback] = function(...)
    input[callback](input, ...)
  end
end

