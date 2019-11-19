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

	-- set the title of our application window
	love.window.setTitle('Pong')

	-- the "RNG" , Random Number Generator, so that calls to random are always random
	-- use the current time, since that will vary on startup every time
	math.randomseed(os.time())

	-- more "retro-looking" font object we can use for any text
	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)

	-- set LOVE2D's active font to the smallFont object
	love.graphics.setFont(smallFont)

	-- initialize window with virtual resolution
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true, 
		vsync = true
	})

	-- initialize score variables, used for rendering on the screen and keeping track of the winner 
	player1Score = 0
	player2Score = 0

	-- either going to be 1 or 2; whomever is scored on gets to serve following turn
	servingPlayer = 1


	-- initialize our player paddles; make them global so that they can be detected by other functions and modules
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10 - 5, VIRTUAL_HEIGHT - 10 - 30, 5, 20)


	-- place a ball in the middle of the screen
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- game state variable used to transition between different parts of the game, (used for beginning, menus, main game, high score list, etc.)
	-- we will use this to determine behavior during render and update
	gameState = 'start'
	
end

-- w, s, up, down,写在love.update(dt)而不是love.keypressed(key)里，是因为杆要根据dt实现上下移动，而love.keypressed(key)中不存在dt
-- 同样的，球的移动，也要在update(dt)中
--[[
	Runs every frame, with "dt" passed in, our delta in seconds since the last frame, which "LVOE2D" supplies us(提供给我们， to provide someone with something that they need or want）.
]]
function love.update(dt)

	if gameState == 'serve' then
		-- before switching to play, initialize ball's velocity based on player who last scored
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = - math.random(140, 200)
		end

	elseif gameState == 'play' then
		-- detect ball collision with paddles, reversing dx if true and slightly increase it, then altering the dy on the position of collision
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5 -- 5 is the width of paddle

			-- keep velocity going in the same direction, but randomize it
			if ball.dy < 0 then
				ball.dy = - math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end
		
		if ball:collides(player2) then
			ball.dx = - ball.dx * 1.03
			ball.x = player2.x - 4 -- 4 is the width of ball

			-- also keep dy going in the same direction, randomize its size
			if ball.dy < 0 then
				ball.dy = - math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end

		-- detect upper and lower screen boundary collision and reverse dy if collided

		if ball.y <= 0 then 
			ball.y = 0
			ball.dy = - ball.dy
		end

		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = - ball.dy
		end
		
		-- if we reach the left or right edge of the screen, 
		-- go back to start and update the score
		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			if player2Score == 10 then
				gameState = 'done'
				winningPlayer = 2
			else
				ball:reset()
				gameState = 'serve'
			end
		end

		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			if player1Score == 10 then
				gameState = 'done'
				winningPlayer = 1
			else
				ball:reset()
				gameState = 'serve'
			end
		end

	end

	



	-- player1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end
	
	-- player2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	if gameState == 'play' then
		ball:update(dt)
	end
	
	player1:update(dt)
	player2:update(dt)
	
	
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
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then

			gameState = 'serve'
			
			player1Score = 0
			player2Score = 0

			servingPlayer = winningPlayer == 1 and 2 or 1
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
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		-- no UI message to display in play state
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf('Press Enter to restart!', 0, 50, VIRTUAL_WIDTH, 'center')
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

	-- new function just to demonstrate how to see FPS in LOVE2D
	displayFPS()

	push:apply('end')
end

--[[
	Renders the current FPS.
]]
function displayFPS()
	-- simple FPS display scross all states
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end