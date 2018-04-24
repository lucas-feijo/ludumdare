local player = {}
local data = {
  sprite = {},
  audio = {},
  hp = 10,
  px = 500, py = 0,
  mult = (WIDTH/1920)*4.5,
  size = 16 * (WIDTH/1920)*4.5,
  velocity = (WIDTH/1920)*800,  
  keys = {right = "right", left = "left", jump = "space",
          buildRes = "1", buildComm = "2", buildInd = "3"},
  time = 17,
  moving = false,
  jumping = false,
  jumpInitSpeed = (HEIGHT/1080)*1400,
  gravVel = 0,
  gravStr = 10,
  velLimit = 1700,
  buildType = 1,
  meteorTime = 0,
  building = false
}

function player.load()
    love.graphics.setDefaultFilter("nearest")
    for i = 1, 21, 1 do
      player.setSprite(love.graphics.newImage("res/player/player_".. i .. ".png"), i)
    end
    
    player.setAudio(1 , love.audio.newSource("res/audio/step.mp3", "static")) 
    player.setAudio(2 , love.audio.newSource("res/audio/jump.mp3", "static"))
    player.setPy(FLOOR - player.getSize() - 8)
end

function player.setSprite(a, num)
    data.sprite[num] = a
end

function player.getSprite(num)
    return data.sprite[num]
end

function player.getMeteorTime()
    return data.meteorTime
end

function player.setPx(a)
    data.px = a
end

function player.getPx()
    return data.px
end

function player.setPy(a)
    data.py = a
end

function player.getPy()
    return data.py
end

function player.setHp(a)
    data.hp = a
end

function player.getHp()
    return data.hp
end

function player.getBuildResKey()
    return data.keys.buildRes
end

function player.getBuildCommKey()
    return data.keys.buildComm
end

function player.getBuildIndKey()
    return data.keys.buildInd
end

function player.getBuildType()
    return data.buildType
end

function player.setBuildType(t)
    data.buildType = t
end

function player.getHp()
    return data.hp
end
function player.setVelocity(a)
    data.velocity = (WIDTH/1920)*a
end
function player.getVelocity()
    return data.velocity
end
function player.getJumpKey()
    return data.keys.jump
end
function player.setMult(a)
    data.mult = a*(WIDTH/1920)
end

function player.getMult()
    return data.mult
end

function player.getGravVel()
    return data.gravVel
end

function player.getSize()
    return data.size
end
function player.setAudio(num, a)
    data.audio[num] = a
end

function player.build()
    data.time = 18
    building = true
end
function player.jumped()
    if buildings.checkFloorCollision(player.getPx(), player.getPy(), player.getSize(), player.getSize()) then
      data.gravVel = -data.jumpInitSpeed
      data.audio[2]:play()
    end
end
--
function player.getFrame()
    if building and data.time >= 26 then
      building = false
    end
    if building then
      return player.getSprite(math.floor(data.time)%4 + 18)
    elseif data.moving == "right" and not jumping then
      return player.getSprite(math.floor(data.time)%((16)/2) + 1)
    elseif data.moving == "left" and not jumping then
      return player.getSprite(math.floor(data.time)%((16)/2) + 1 + (16)/2)
    elseif data.moving == "right" and jumping then
      return player.getSprite(1)
    elseif data.moving == "left" and jumping then
      return player.getSprite(13)
    else
      return player.getSprite(17)
    end
end
function player.uFrame(dt)
    data.time = data.time+dt*data.velocity*0.05
end

--
function player.move(dt)
    if love.keyboard.isDown(data.keys.right) and not love.keyboard.isDown(data.keys.left) and data.px < WIDTH - player.getSize() then
      data.px = data.px + data.velocity*dt
      data.moving = "right"
    elseif love.keyboard.isDown(data.keys.left) and not love.keyboard.isDown(data.keys.right)  and data.px > 0  then
      data.px = data.px - data.velocity*dt
      data.moving = "left"
    else
      data.moving = false
    end
    
    if data.px < 0 then
      data.px = 1
    elseif data.px > WIDTH - player.getSize() then
      data.px = WIDTH - player.getSize()
    end
    
end

function player.update(dt)
    player.uFrame(dt)
    player.move(dt)
    
    if data.hp <= 0 then
      gameState = 0
    end
    
    if data.moving ~= false and not jumping then
      data.audio[1]:play()
    end
    
    player.setPy(player.getPy() + data.gravVel*dt)
    if buildings.checkFloorCollision(player.getPx(), player.getPy(), player.getSize(), player.getSize()) then
      data.gravVel = 0
      jumping = false
    else
      if data.gravVel + data.gravStr > data.velLimit then
        data.gravVel = data.velLimit
      else
        data.gravVel = data.gravVel + data.gravStr
      end
      jumping = true
    end
      
    if data.meteorTime < 600 then
      data.meteorTime = data.meteorTime + 25*dt
    else
      data.meteorTime = 600
    end
    
    if buildings.checkBodyCollision(data.px, data.py, data.size, data.size) and player.getGravVel() > 1200 then
      player.gravVel = 0
      data.py = HEIGHT-(math.ceil((HEIGHT-data.py)/buildings.getFh())*buildings.getFh())
    end
end

function player.checkCollision(x, y)
  if x + 80>= data.px and x - 80 <= data.px then
    if y + 80>= data.py and y - 80 <= data.py then
      return true
    end
  end
  return false
end

function player.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(player.getFrame(), player.getPx(), player.getPy(), 0, player.getMult(), player.getMult())
end
--
return player