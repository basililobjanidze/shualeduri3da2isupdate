-- object.lua

local Object = {}
Object.__index = Object

function Object.new(x, y, size, speed)
    local object = setmetatable({}, Object)
    object.x = x
    object.y = y
    object.size = size
    object.speed = speed
    return object
end

function Object:update(dt)
    self.y = self.y + self.speed * dt
end

function Object:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
end

return Object
