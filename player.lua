local player = {}

------Variables------
local sprite = {}
local audio = {}
local hp = 10
local px = 500
local py = 0
local mult = (WIDTH/1920)*4.5
local size = 16 * (WIDTH/1920)*4.5
local velocity = (WIDTH/1920)*800
local keys = {right = "right", left = "left", jump = "space", buildRes = "1", buildComm = "2", buildInd = "3"}
local time = 17
local moving = false
local jumping = false
local jumpInitSpeed = (HEIGHT/1080)*1400
local gravVel = 0
local gravStr = 10
local velLimit = 1700
local buildType = 1
local meteorTime = 0
local building = false
local frame = 0
local frameTime = 0.035

------Functions------
function player.load()
    --loads player sprite
    love.graphics.setDefaultFilter("nearest")
    for i = 1, 21, 1 do
      sprite[i] = love.graphics.newImage("res/player/player_".. i .. ".png")
    end
    
    --loads player sounds
    audio[1] = love.audio.newSource("res/audio/step.mp3", "static")
    audio[2] = love.audio.newSource("res/audio/jump.mp3", "static")
   
    --sets player's initial height
    py = FLOOR - size - 8
end

function player.update(dt)
    player.move(dt)
    
    --time = time+dt*velocity*0.05
    time = time + dt
    
    if time >= frameTime then
      time = 0
      frame = frame + 1
    end
    
    --goes to start screen if player is killed
    if hp <= 0 then
      gameState = 0
    end
    
    --makes stepping sound when moving and not jumping
    if moving ~= false and not jumping then
      audio[1]:play()
    end
    
    py = py + gravVel*dt
    if buildings.checkFloorCollision(px, py, size, size) then
      gravVel = 0
      jumping = false
    else
      if gravVel + gravStr > velLimit then
        gravVel = velLimit
      else
        gravVel = gravVel + gravStr
      end
      jumping = true
    end
      
    if meteorTime < 600 then
      meteorTime = meteorTime + 25*dt
    else
      meteorTime = 600
    end
    
    if buildings.checkBodyCollision(px, py, size, size) and gravVel > 1200 then
      player.gravVel = 0
      py = HEIGHT-(math.ceil((HEIGHT-py)/buildings.getFh())*buildings.getFh())
    end
end

function player.draw()
    --draws player
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite[player.defineSprite()], px, py, 0, mult, mult)
    
end

-----------------
function player.defineSprite()
    -- loops through building animation frames
    if building and frame >= 24 then
      frame = 0
      building = false
    end
    
    --returns the sprite index to draw based on the direction the player is moving
    if building then
      return frame%4 + 18
    elseif moving == "right" and not jumping then
      return frame%8 + 1
    elseif moving == "left" and not jumping then
      return frame%8 + 9
    elseif moving == "right" then
      return 1
    elseif moving == "left" then
      return 13
    else
      return 17
    end
    
end

function player.move(dt)
    --walks right or left or doesn't walk
    if love.keyboard.isDown(keys.right) and not love.keyboard.isDown(keys.left) and px < WIDTH - size then
      px = px + velocity*dt
      moving = "right"
    elseif love.keyboard.isDown(keys.left) and not love.keyboard.isDown(keys.right)  and px > 0  then
      px = px - velocity*dt
      moving = "left"
    else
      moving = false
    end
    
    --doesn't allow player to walk out of screen
    if px < 0 then
      px = 1
    elseif px > WIDTH - size then
      px = WIDTH - size
    end
    
end

function player.build()
    --when build key is pressed, start build animation
    frame = 18
    building = true
end

function player.jumped()
    if buildings.checkFloorCollision(px, py, size, size) then
      gravVel = -jumpInitSpeed
      audio[2]:play()
    end
    
end

function player.checkCollision(x, y)
  if x + 80>= px and x - 80 <= px then
    if y + 80>= py and y - 80 <= py then
      return true
    end
  end
  return false
end

------gets/sets------
function player.getSpriteWidth(i, kind)
    kind = kind or "ready"
    if kind == "ready" then
      return sprite[i]:getWidth() * mult
    elseif kind == "pure" then
      return sprite[i]:getWidth()
    end
end

function player.getSpriteHeight(i, kind)
    kind = kind or "ready"
    if kind == "ready" then
      return sprite[i]:getHeight() * mult
    elseif kind == "pure" then
      return sprite[i]:getHeight()
    end
end

function player.getMeteorTime()
    return meteorTime
end

function player.getPx()
    return px
end

function player.getPy()
    return py
end

function player.getHp()
    return hp
end

function player.getKeys()
    return keys
end

function player.getBuildType()
    return buildType
end

function player.getGravVel()
    return gravVel
end

function player.setBuildType(a)
    buildType = a
end

function player.damage(a)
    hp = hp - a
end

--
return player