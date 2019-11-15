--[[
	"The Class Update"

	-- Main Program --
]]

-- push is a library that will allow us to draw our game at a virtual resolution, instead of however large our window is; used to provide a more retro aesthetic
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in our game as code, rather than keeping track of many disparate variables and methods
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle and logic for render them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise but which will mechanically function very differently
require 'Ball'





WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[
	Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	-- the "RNG" , Random Number Generator, so that calls to random are always random
	-- use the current time, since that will vary on startup every time
	math.randomseed(os.time())

	-- more "retro-looking" font object we can use for any text
	smallFont = love.graphics.newFont('font.ttf', 8)
	

	scoreFont = love.graphics.newFont('font.ttf', 32)

	-- set LOVE2D's active font to the smallFont object
	love.graphics.setFont(smallFont)

	-- initialize window with virtual resolution
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true, 
		vsync = true
	})

	-- initialize our player paddles; make them global so that they can be detected by other functions and modules
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10 - 5, VIRTUAL_HEIGHT - 10 - 30, 5, 20)


	-- place a ball in the middle of the screen
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	gameState = 'start'
	player1Score = 0
	player2Score = 0
end

-- w, s, up, down,写在love.update(dt)而不是love.keypressed(key)里，是因为杆要根据dt实现上下移动，而love.keypressed(key)中不存在dt
-- 同样的，球的移动，也要在update(dt)中
--[[
	Runs every frame, with "dt" passed in, our delta in seconds since the last frame, which "LVOE2D" supplies us(提供给我们， to provide someone with something that they need or want）.
]]
function love.update(dt)
	-- player1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
		player1:update(dt)
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
		player1:update(dt)
	end
	
	-- player2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
		player2:update(dt)
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
		player2:update(dt)
	end

	if gameState == 'play' then
		ball:update(dt)
	end
	
	
	
end

--[[
	Keyboard handling, called by LOVE2D each frame;
	passes in the key we pressed so we can access.
]]
function love.keypressed(key) 
	-- keys can be accessed by string name
	if key == 'escape' then
		-- function LOVE2D gives us to terminate application
		love.event.quit()
	-- if we press enter during the start state of the game, we'll go into play mode
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
		else
			gameState = 'start'

			-- 开始状态下，重置球
			ball:reset()
		end
	end
end
--[[
	Called after update by LOVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
	-- begin rendering at virtual resolution
	push:apply('start')

	-- gray background
	-- clear the screen with a specific color; in this case, a color similar to some versions of the original Pong
	love.graphics.clear(40, 45, 52, 255)


	-- Hello Pong
	-- draw different things based on the state of the game
	love.graphics.setFont(smallFont)

	if gameState == 'start' then
		love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
	else
		love.graphics.printf('Hello Play State', 0, 20, VIRTUAL_WIDTH, 'center')
	end
	-- 分数
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
	-- render paddles, now using there class's render method
	player1:render()
	player2:render()
	-- render ball using its class's render method
	ball:render()

	push:apply('end')
end