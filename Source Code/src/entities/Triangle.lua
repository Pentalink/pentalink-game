Triangle = Class{}

function Triangle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function Triangle:render()
    love.graphics.setColor(0, 50, 150)
    love.graphics.polygon('fill', {self.x, self.y + self.height/2, self.x + self.width, self.y, self.x + self.width, self.y + self.height})
end
