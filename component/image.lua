
local image_component = {
  image_component = "image",

  load_image = function(self, name)
    self._image = love.graphics.newImage(name)
    self._image:setFilter("nearest", "nearest")
  end,
  draw_image = function(self, x, y)
    love.graphics.draw(self._image, x, y)
  end,
  image_width = function(self) return self._image:getWidth() end,
  image_height = function(self) return self._image:getHeight() end,
}

return image_component

