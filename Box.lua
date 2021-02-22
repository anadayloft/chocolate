local Concord = require "lib/Concord" -- https://github.com/Tjakka5/Concord
local Chocolate = require "Chocolate"

local Box = {}

Concord.component("box_position",
	function(component, x, y)
		component.x = x
		component.y = y
	end
)

Concord.component("scoreable")

local BoxDrawSystem = Concord.system({
	pool = { "chocolate", "box_position" }
})

local BoxMouseSystem = Concord.system({
	pool = { "box_position" }
})


function BoxDrawSystem:draw(box, window_width, window_height)
	box.sheet:clear()
	for _, entity in ipairs(self.pool) do
		local choc = entity.chocolate.drawable.whole_choc
		local deco = entity.chocolate.drawable.whole_deco
		local filling = false
		if entity.scoreable then
			choc = entity.chocolate.drawable.half_choc
			deco = entity.chocolate.drawable.half_deco
			filling = entity.chocolate.drawable.filling
		end
		box.sheet:add(
			choc,
			(entity.box_position.x - 1) * Chocolate.drawables.size,
			(entity.box_position.y - 1) * Chocolate.drawables.size
		)
		if filling then
			box.sheet:add(
				filling,
				(entity.box_position.x - 1) * Chocolate.drawables.size,
				(entity.box_position.y - 1) * Chocolate.drawables.size
			)
		end
		if entity.chocolate.deco then
			box.sheet:add(
				deco,
				(entity.box_position.x - 1) * Chocolate.drawables.size,
				(entity.box_position.y - 1) * Chocolate.drawables.size
			)
		end
	end
	
	love.graphics.draw(
		box.sheet,
		(window_width - box.width * Chocolate.drawables.size) / 2,
		(window_height - box.height * Chocolate.drawables.size) / 2
	)
end

function BoxDrawSystem:finish(box, palate)
	local bds = box.world:getSystem(BoxDrawSystem)
	bds:setEnabled(false)
	local bms = box.world:getSystem(BoxMouseSystem)
	bms:setEnabled(false)
	box.not_turn = "disabled"
end

function BoxMouseSystem:eat(box, x, y)
	local chocolate = box.chocolates[x][y]
	if chocolate.box_position then
		box.remaining_chocolates = box.remaining_chocolates - 1
		chocolate:give("scoreable")
		box.cooldown = 2
		box.not_turn = true
	end
end

function Box.new(self, width, height, chocolate_list)
	box = {
		width = width,
		height = height,
		world = Concord.world(),
		sheet = love.graphics.newSpriteBatch(Chocolate.drawables.image, 10000),
		remaining_chocolates = width * height,
		chocolates = {},
		cooldown = 0,
		not_turn = false,
		highscore = 0
	}
	box.world:addSystems(BoxDrawSystem, BoxMouseSystem)
	
	local hs = love.filesystem.read(box.width * box.height .. "_highscore")
	if hs then box.highscore = tonumber(hs) end
	
	-- need to prep these in advance, extra set of iters ... oh well
	for x = 1, width do
		box.chocolates[x] = {}
	end
	
	for x = 1, width do
		for y = 1, height do
			local chocolate = false
			if not box.chocolates[x][y] then
				chocolate = Chocolate:entity()
				if true -- love.math.random(0, 2) ~= 0
				and width + 1 - x > x
				and height + 1 - y > y then
					box.chocolates[x][height + 1 - y] = chocolate
					box.chocolates[width + 1 - x][y] = chocolate
					box.chocolates[width + 1 - x][height + 1 - y] = chocolate
				end
			else
				local color = box.chocolates[x][y].chocolate.color
				local shape = box.chocolates[x][y].chocolate.shape
				local filling = box.chocolates[x][y].chocolate.filling
				local deco = box.chocolates[x][y].chocolate.deco
				chocolate = Chocolate:entity(color, shape, filling, deco)
			end
			chocolate:give("box_position", x, y)
			box.chocolates[x][y] = chocolate
			box.world:addEntity(chocolate)
		end
	end
	
	function box.update(self, palate, dt)
		self.cooldown = self.cooldown - dt
		if self.cooldown <= 0 then
			self.world:emit("update", self, palate, dt)
			if self.not_turn and self.remaining_chocolates > 0 then
				if self.cooldown <= -3 then
					while true do
						local box_x = love.math.random(1, self.width)
						local box_y = love.math.random(1, self.height)
						local chocolate = self.chocolates[box_x][box_y]
						if chocolate.box_position then
							chocolate:remove("box_position")
							self.remaining_chocolates = self.remaining_chocolates - 1
							self.not_turn = false
							break
						end
					end
				end
			else
				self.cooldown = 0
			end
			if self.remaining_chocolates == 0 then
				self.world:emit("finish", self, palate)
			end
		end
	end

	function box.draw(self, window_width, window_height)
		self.world:emit("draw", self, window_width, window_height)
	end
	
	function box.mousepressed(self, window_width, window_height, x, y, button)
		if button == 1 and self.cooldown == 0 then
			box_x = math.ceil((x - window_width / 2) / Chocolate.drawables.size + self.width / 2)
			box_y = math.ceil((y - window_height / 2) / Chocolate.drawables.size + self.height / 2)
			if box_x > 0 and box_x <= self.width
			and box_y > 0 and box_y <= self.height then 
				self.world:emit("eat", self, box_x, box_y)
			end
		end
	end
	
	return box
end

return Box
