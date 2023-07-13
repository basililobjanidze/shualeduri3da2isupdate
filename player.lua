-- player.lua

local Player = {}
Player.__index = Player

function Player.new(x, y, size, speed)
    local player = setmetatable({}, Player)
    player.x = x
    player.y = y
    player.size = size
    player.speed = speed
    return player
end

function Player:update(dt)
    -- Player movement
    if love.keyboard.isDown("w") and self.y > 0 then
        self.y = self.y - self.speed * dt
    elseif love.keyboard.isDown("s") and self.y < love.graphics.getHeight() - self.size then
        self.y = self.y + self.speed * dt
    end

    if love.keyboard.isDown("a") and self.x > 0 then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("d") and self.x < love.graphics.getWidth() - self.size then
        self.x = self.x + self.speed * dt
    end
end

function Player:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
end

function Player:checkCollision(object)
    return self.x < object.x + object.size and
           object.x < self.x + self.size and
           self.y < object.y + object.size and
           object.y < self.y + self.size
end

return Player
