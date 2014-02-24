-- coroutine actors

local actor = {
  component = "actor",

  actor_init = function(self, func)
    self._actor = {
      dt = 0,
      thread = coroutine.create(function() func(self) end)
    }
  end,

  actor_run = function(self, ...)
    if not self:actor_done() then
      local err, msg = coroutine.resume(self._actor.thread, ...)
      if err == false then
        error(debug.traceback(self._actor.thread, msg))
      end
    end
  end,

  actor_wait = function(self, secs)
    repeat
      local dt = coroutine.yield(true)
      if not secs then
        self._actor.dt = 0
        return dt
      end
      self._actor.dt = self._actor.dt + dt
    until self._actor.dt >= secs
    self._actor.dt = self._actor.dt - secs
    return secs
  end,

  actor_done = function(self)
    if not self._actor.thread then return true end
    return (coroutine.status(self._actor.thread)=="dead")
  end,
}

return actor

