WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--[[
	游戏启动时，会运行一次代码；用来初始化游戏
]]
function love.load()
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT,{
		fullscreen = false,
		resizable = false,
		vsync = true
	})
end

--[[
	每次update之后就是draw
]]
function love.draw()
	love.graphics.printf(
		'Hello Pong!',			-- text to render
		0,						-- starting X (0 since we're going to center it based on width)
		WINDOW_HEIGHT / 2 - 6,	-- starting Y (halfway down the screen)
		WINDOW_WIDTH,			-- number of pexels to center within (the entire screen here)
		'center')				-- alignment mode, can be 'center', 'left', or 'right'
end

