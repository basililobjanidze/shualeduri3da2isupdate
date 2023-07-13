local Bullet = {}

function Bullet.new(x, y, size, speed)
    local bullet = {
        x = x,
        y = y,
        size = size,
        speed = speed
    }
    setmetatable(bullet, { __index = Bullet })
    return bullet
end

function Bullet:update(dt)
    self.y = self.y - self.speed * dt
end

function Bullet:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
end

function Bullet:checkCollision(object)
    return self.x < object.x + object.size and
           object.x < self.x + self.size and
           self.y < object.y + object.size and
           object.y < self.y + self.size
end

function Bullet:isOffScreen()
    return self.y < 0
end

return Bullet
