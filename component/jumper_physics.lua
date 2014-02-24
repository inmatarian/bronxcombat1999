-- physics component
--

local rectangle = require 'rectangle'

local max, min, floor = math.max, math.min, math.floor
local NUDGE = 0.01
local wall_mask = {
  [0] = { top=false,  bottom=false, left=false, right=false },
  [252] = { top=true,  bottom=false, left=false, right=false },
  [253] = { top=false, bottom=true,  left=false, right=false },
  [254] = { top=false, bottom=false, left=true,  right=false },
  [255] = { top=false, bottom=false, left=false, right=true  },
  [256] = { top=true,  bottom=true,  left=true,  right=true  },
}

local edge_mask = function(entity)
  local mask = wall_mask[entity] or wall_mask[0]
  return mask.top, mask.bottom, mask.left, mask.right
end

local between = function(x, y, z)
  return (x <= y) and (y <= z)
end

local colinear = function(a1, a2, b1, b2)
  return not ((a2<b1) or (a1>b2))
end

local function check_run(get_tiledatum, dx, dy, ex, ey, aw, ah)
  local horiz_collision, vert_collision
  local ax, ay, bx, by
  local l, r = floor(ex/16)-1, floor((ex+aw)/16)+1
  local t, b = floor(ey/16)-1, floor((ey+ah)/16)+1
  for y = t, b do
    for x = l, r do
      local top_edge, bottom_edge, left_edge, right_edge = edge_mask(get_tiledatum(x, y))
      if top_edge or bottom_edge or left_edge or right_edge then
        ax, ay = ex + (dx or 0), ey + (dy or 0)
        bx, by = x*16, y*16
        if dx then
          if (dx > 0) and left_edge then
            if between(ex+aw, bx, ax+aw) and colinear(ay, ay+ah, by, by+16) then
              dx = max(-0.0, (dx - (ax+aw - bx+NUDGE)))
              horiz_collision = "right"
            end
          elseif (dx < 0) and right_edge then
            if between(ax, bx+16, ex) and colinear(ay, ay+ah, by, by+16) then
              dx = min(0.0, (dx + (bx+16+NUDGE - ax)))
              horiz_collision = "left"
            end
          end
        end
        if dy then
          if (dy > 0) and top_edge then
            if between(ey+ah, by, ay+ah) and colinear(ax, ax+aw, bx, bx+16) then
              dy = max(-0.0, (dy - (ay+ah - by+NUDGE)))
              vert_collision = "bottom"
            end
          elseif (dy < 0) and bottom_edge then
            if between(ay, by+16, ey) and colinear(ax, ax+aw, bx, bx+16) then
              dy = min(0.0, (dy + (by+16+NUDGE - ay)))
              vert_collision = "top"
            end
          end
        end
      end
    end
  end
  return dx, dy, horiz_collision, vert_collision
end

local resolve_world_collisions = function(get_tiledatum, dx, dy, ex, ey, ew, eh)
  local horiz, vert, _
  dx, _, horiz   = check_run(get_tiledatum, dx, nil, ex, ey, ew, eh)
  _, dy, _, vert = check_run(get_tiledatum, nil, dy, ex+dx, ey, ew, eh)
  return dx, dy, horiz, vert
end

local resolve_all_collisions = function(entity, tx, ty, dx, dy)
  local sx = entity.x + entity.jumper_physics_rectangle.x
  local sy = entity.y + entity.jumper_physics_rectangle.y
  local sw, sh = entity.jumper_physics_rectangle.w, entity.jumper_physics_rectangle.h
  tx = tx + entity.jumper_physics_rectangle.x
  ty = ty + entity.jumper_physics_rectangle.y

  local fdx, fdy, horiz, vert = resolve_world_collisions(
    entity.get_world_tiledatum, tx-sx, ty-sy, sx, sy, sw, sh)

  if (sx + fdx) ~= tx then dx = 0 end
  if (sy + fdy) ~= ty then dy = (dy < 0) and (dy * 0.25) or 0 end

  local retx = sx + fdx - entity.jumper_physics_rectangle.x
  local rety = sy + fdy - entity.jumper_physics_rectangle.y
  return retx, rety, dx, dy, (vert=="bottom")
end

local jumper_physics_component = {
  jumper_physics_component = "jumper_physics",

  -- properties required:
  --    x, y,
  --    get_world_tiledatum

  dx = 0, dy = 0,
  jump_power = 280, x_speed = 112, jump_cutoff = 0.7,
  gravity = 768, terminal_velocity = 256,
  grounded = false, jumping = false, tangible = true,

  jumper_physics_init = function(self, rect)
    self.jumper_physics_rectangle = rect or rectangle()
  end,

  jumper_physics_apply_forces = function(self, dt)
    local x, y = self.x or 0, self.y or 0
    local dx, dy = self.dx, self.dy

    -- x component
    x = x + dx*dt

    -- y component
    dy = min(dy + self.gravity*(dt*0.5), self.terminal_velocity)
    y = y + dy*dt
    dy = min(dy + self.gravity*(dt*0.5), self.terminal_velocity)

    self.x, self.y, self.dx, self.dy, self.grounded = resolve_all_collisions(self, x, y, dx, dy)
    if self.jumping and self.dy >= 0 then self.jumping = false end
  end,

  jumper_physics_apply_controls = function(self, hold_left, hold_right, hold_jump_len)
    self.dx = 0
    if hold_left then self.dx = self.dx - self.x_speed end
    if hold_right then self.dx = self.dx + self.x_speed end

    if self.jumping and (hold_jump_len <= 0) then
      self.jumping = false
      self.dy = self.dy * self.jump_cutoff
    end

    if (hold_jump_len > 0) and (hold_jump_len <= 0.15) and self.grounded then
      self.grounded = false
      self.jumping = true
      self.dy = -self.jump_power
    end
  end,
}

return jumper_physics_component

