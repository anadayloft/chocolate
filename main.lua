require "lib/Concord" -- https://github.com/Tjakka5/Concord

local Chocolate = require "Chocolate"
local Box = require "Box"
local Palate = require "Palate"

function love.load()
	love.graphics.setDefaultFilter("nearest")
	love.graphics.setBackgroundColor(love.math.colorFromBytes( 154, 112, 60, 255))
	
	scale = 2
	window_width, window_height = love.graphics.getDimensions( )
	
	Chocolate:load()
	
	palate = Palate:new()
	
	box = Box:new(4, 4)
	box.world:addSystems(Palate.ScoreSystem, Palate.FinishSystem)
end

function love.update(dt)
	box:update(palate, dt)
end

function love.draw()
	love.graphics.scale(scale)
	love.graphics.print("Highscore [" .. box.width * box.height .. "]: " .. box.highscore, 10, 10)
	love.graphics.print("Score: " .. palate.score, 10, 24)
	
	if palate.ate_favourite ~= false and palate.favourite_time < 4 then
		love.graphics.print(palate.ate_favourite, 10, 38)
	end
	
	if box.not_turn == false then
		love.graphics.print("Please eat a chocolate!", 226, 10)
	elseif box.not_turn == true then
		love.graphics.print("Please wait for other player ...", 200, 10)
	else
		love.graphics.print("Press enter to continue ...", 222, 10)
	end
	
	love.graphics.translate(0, 32)
	box:draw(window_width / scale, window_height / scale)
	
end

function love.keypressed(key, scancode, is_repeat)
	if box.not_turn == "disabled" then
		if key == "return" then
			palate:reset()
			local w, h = love.math.random(4, 10), love.math.random(2, 6)
			if w % 2 ~= 0 then w = w + 1 end
			if h % 2 ~= 0 then h = h + 1 end
			if w < h then
				w, h = h, w
			end
			box = Box:new(w, h)
			box.world:addSystems(Palate.ScoreSystem, Palate.FinishSystem)
		elseif key == "p" then
			palate = Palate:new()
		end
	elseif key == "b" then
		palate:reset()
		local w, h = love.math.random(4, 10), love.math.random(2, 6)
		if w % 2 ~= 0 then w = w + 1 end
		if h % 2 ~= 0 then h = h + 1 end
		if w < h then
			w, h = h, w
		end
		box = Box:new(w, h)
		box.world:addSystems(Palate.ScoreSystem, Palate.FinishSystem)
	end
end

function love.mousepressed( x, y, button, istouch, presses)
	box:mousepressed(window_width / scale, window_height / scale, x / scale, (y - 32 * scale) / scale, button)
end

function love.quit()
	
end
