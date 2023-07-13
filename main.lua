local Player = require "player"
local Object = require "object"
local Bullet = require "bullet"

-- Constants
local PLAYER_SIZE = 50
local PLAYER_SPEED = 200
local OBJECT_SIZE = 30
local OBJECT_SPEED_MIN = 100
local OBJECT_SPEED_MAX = 300
local OBJECT_SPAWN_RATE = 0.5
local BULLET_SIZE = 10
local BULLET_SPEED = 500
local BULLET_RELOAD_TIME = 1

-- Game states
local GameState = {
    START = 1,
    PLAYING = 2,
    GAME_OVER = 3
}
local currentState = GameState.START

-- Game objects
local player
local objects = {}
local bullets = {}
local score = 0
local lives = 3
local lastBulletTime = 0

-- Load assets
local shootingSound
local bulletHitSound

function love.load()
    shootingSound = love.audio.newSource("srola.wav", "static")
    bulletHitSound = love.audio.newSource("gartyma.wav", "static")

    love.window.setTitle("Object Shooter")
    love.window.setMode(1360, 720, { resizable = true })
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    love.keyboard.setKeyRepeat(true)

    startGame()
end

-- Start the game
-- Start the game
function startGame()
    player = Player.new(love.graphics.getWidth() / 2 - PLAYER_SIZE / 2, love.graphics.getHeight() - PLAYER_SIZE - 10, PLAYER_SIZE, PLAYER_SPEED)
    objects = {}
    bullets = {}
    score = 0
    lives = 3
    lastBulletTime = 0

    currentState = GameState.START
end


-- Update the game state
function love.update(dt)
    if currentState == GameState.PLAYING then
        player:update(dt)

        -- Object spawning
        if math.random() < OBJECT_SPAWN_RATE * dt then
            local object = Object(math.random(love.graphics.getWidth() - OBJECT_SIZE), -OBJECT_SIZE, OBJECT_SIZE, math.random(OBJECT_SPEED_MIN, OBJECT_SPEED_MAX))
            table.insert(objects, object)
        end

        -- Object movement and collision
        for i = #objects, 1, -1 do
            local object = objects[i]
            if object then
                object:update(dt)

                -- Check collision with player
                if player:checkCollision(object) then
                    lives = lives - 1
                    if lives <= 0 then
                        currentState = GameState.GAME_OVER
                    end
                    table.remove(objects, i)
                end

                -- Check collision with bullets
                for j = #bullets, 1, -1 do
                    local bullet = bullets[j]
                    if bullet and bullet:checkCollision(object) then
                        table.remove(objects, i)
                        table.remove(bullets, j)
                        score = score + 100
                        bulletHitSound:play()
                        break
                    end
                end
            end
        end

        -- Bullet movement
        for i = #bullets, 1, -1 do
            local bullet = bullets[i]
            bullet:update(dt)

            -- Remove bullets that go off-screen
            if bullet:isOffScreen() then
                table.remove(bullets, i)
            end
        end

        -- Bullet reload time
        lastBulletTime = lastBulletTime + dt
    end
end

-- Draw the game objects
function love.draw()
    -- Draw player
    player:draw()

    -- Draw objects
    for _, object in ipairs(objects) do
        object:draw()
    end

    -- Draw bullets
    for _, bullet in ipairs(bullets) do
        bullet:draw()
    end

    -- Draw score and lives
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Lives: " .. lives, love.graphics.getWidth() - 70, 10)

    -- Draw start screen
    if currentState == GameState.START then
        love.graphics.printf("Press Enter to Play", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end

    -- Draw game over screen
    if currentState == GameState.GAME_OVER then
        love.graphics.printf("Game Over\n\nYour Score: " .. score .. "\n\nPress Enter to Play Again", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end

-- Start the game or play again when Enter key is pressed
function love.keypressed(key)
    if key == "return" and currentState == GameState.START then
        currentState = GameState.PLAYING
    elseif key == "return" and currentState == GameState.GAME_OVER then
        startGame()
    elseif key == "space" and currentState == GameState.PLAYING and lastBulletTime >= BULLET_RELOAD_TIME then
        local bullet = Bullet(player.x + PLAYER_SIZE / 2 - BULLET_SIZE / 2, player.y, BULLET_SIZE, BULLET_SPEED)
        table.insert(bullets, bullet)
        shootingSound:play()
        lastBulletTime = 0
    end
end

-- Check collision between two rectangles
function checkCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.size and
           rect2.x < rect1.x + rect1.size and
           rect1.y < rect2.y + rect2.size and
           rect2.y < rect1.y + rect1.size
end
