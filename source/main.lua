import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local playerSprite = nil

local coinSprite = nil
local score = 0

local playerSpeed = 4

local playTimer = nil
local playTime = 30 * 1000 -- denotes the time in miliseconds

local function resetTimer()
	-- sets the timer to start at playtime with starting value of playtime and ending value of 0 and progressing linerly
	playTimer = playdate.timer.new(playTime,playTime,0,playdate.easingFunctions.linear)
end

local function initializeTimer()
	playTimer = playdate.timer.new(0,playTime,0,playdate.easingFunctions.linear)
end

local function moveCoin()
	local randX = math.random(40,360)
	local randY = math.random(40,200)
	coinSprite:moveTo(randX,randY)
end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())
	local playerImage = gfx.image.new("images/player")
	playerSprite = gfx.sprite.new(playerImage)
	-- we're using a colon instead of a dot because we are effecting this particular instance
	playerSprite:moveTo(200,120) 
	playerSprite:setCollideRect(0,0, playerSprite:getSize())
	-- playdate resoultion (400x,240y)
	playerSprite:add()--adds the sprite to the screen

	local coinImage = gfx.image.new("images/coin")
	coinSprite = gfx.sprite.new(coinImage)
	moveCoin()
	coinSprite:setCollideRect(0,0, coinSprite:getSize())
	coinSprite:add()

	--create the backgroud immage
	local backgroundImage= gfx.image.new("images/background")
	gfx.sprite.setBackgroundDrawingCallback (
		function(x,y,width, height)
			gfx.setClipRect(x,y,width,height)
			backgroundImage:draw(0,0) -- draws the backgroud image in the upper corner
			gfx.clearClipRect()
		end
	)
	-- resetTimer()
	initializeTimer()
end

initialize()

function playdate.update()
	if playTimer.value == 0 then -- stops the player if the timer is 0
		if playdate.buttonJustPressed(playdate.kButtonA) then -- resets the timer when the a button is pressed
			resetTimer()
			moveCoin()
			score = 0
		end
	else
		if playdate.buttonIsPressed(playdate.kButtonUp)then
			playerSprite:moveBy(0, - playerSpeed) -- moves the sprite up
		end
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			playerSprite:moveBy(playerSpeed,0)-- moves the sprite right
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			playerSprite:moveBy(0,playerSpeed) -- moves the sprite down
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			playerSprite:moveBy(-playerSpeed, 0) --moves the sprite left
		end

		local collisions = coinSprite:overlappingSprites()
		if #collisions >= 1 then
			moveCoin()
			score += 1
		end
	end

	playdate.timer.updateTimers() -- tells the playdate to update the timers, which are used by the grid system an crankler	
	gfx.sprite.update() --this tells the sprite class to update everything in the draw list on each loop
	gfx.drawText("Time: " .. math.ceil(playTimer.value/1000),5,5) -- draws the timer in the upper left corner of the screen
	gfx.drawText("Score: " .. score, 320, 5)
end