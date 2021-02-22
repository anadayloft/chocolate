local Concord = require "lib/Concord"  -- https://github.com/Tjakka5/Concord

local Chocolate = require "Chocolate"
local Box = require "Box"

local Palate = {}

Concord.component("score",
	function(component, score, score_pool, was_favourite, score_order)
		component.score = score
		component.score_pool = score_pool
		component.was_favourite = was_favourite
        component.score_order = score_order
	end
)

Palate.ScoreSystem = Concord.system({
	pool = { "chocolate", "scoreable" }
})

function Palate.ScoreSystem:update(box, palate, dt)
	palate.score_time = palate.score_time + dt
	palate.favourite_time = palate.favourite_time + dt
	local score_intake = love.math.random(1, 5)
	if palate.score_time >= 0.18 and palate.score_pool >= score_intake then
		palate.score_time = 0
		palate.score = palate.score + score_intake
		palate.score_pool = palate.score_pool - score_intake
	end
	for _, entity in ipairs(self.pool) do
		table.insert(palate.chocolates_eaten, entity)
		local score_increase = 0
		local score_pool_increase = 0
		local color = entity.chocolate.color
		local shape = entity.chocolate.shape
		local filling = entity.chocolate.filling
		local deco = entity.chocolate.deco
		
		palate.ate_favourite = false
		if color == palate.favourites.color then
			palate.ate_favourite = "Favourite color!"
			local count = 0
			for _, e2 in ipairs(palate.chocolates_eaten) do
				if e2.chocolate.color == palate.favourites.color then
					count = count + 1
				end
			end
			score_increase = score_increase + 100 * count
			score_pool_increase = score_pool_increase + entity.chocolate.mass * 2
		else
			score_pool_increase = score_pool_increase + entity.chocolate.mass
		end
		if filling == palate.favourites.filling then
			if palate.ate_favourite ~= false then
				palate.ate_favourite = "Double favourite!"
			else
				palate.ate_favourite = "Favourite filling!"
			end
			score_increase = score_increase + 100 * table.getn(palate.chocolates_eaten)
			score_pool_increase = score_pool_increase + entity.chocolate.mass * 3
		end
		if deco == palate.favourites.deco then
			if palate.ate_favourite == "Double favourite!" then
				palate.ate_favourite = "Triple favourite!"
			elseif palate.ate_favourite ~= false then
				palate.ate_favourite = "Double favourite!"
			else
				palate.ate_favourite = "Favourite decoration!"
			end
			score_increase = score_increase + math.floor(1000 / table.getn(palate.chocolates_eaten))
			score_pool_increase = score_pool_increase + entity.chocolate.mass * 2
		end
		if shape == "slab" then
			score_increase = score_increase + 50
		end
		if score_pool_increase == 0 then score_pool_increase = entity.chocolate.mass end
		if palate.ate_favourite == "Triple favourite!" then
			score_increase = score_increase * 3
			score_pool_inrease = score_pool_increase * 3
		elseif palate.ate_favourite == "Double favourite!" then
			score_increase = score_increase * 2
			score_pool_increase = score_pool_increase * 2
		end
		
		entity:give("score",
			score_increase,
			score_pool_increase,
			palate.ate_favourite,
			table.getn(palate.chocolates_eaten)
		)
		entity:remove("scoreable")
		entity:remove("box_position")
		
		-- bonuses (one per turn)
		
		if color == palate.had_in_a_row_type.color
		and shape == palate.had_in_a_row_type.shape
		and filling == palate.had_in_a_row_type.filling
		and deco == palate.had_in_a_row_type.deco then
			palate.had_in_a_row = palate.had_in_a_row + 1
		else
			palate.had_in_a_row_type.color = color
			palate.had_in_a_row_type.shape = shape
			palate.had_in_a_row_type.filling = filling
			palate.had_in_a_row_type.deco = deco
			palate.had_in_a_row = 1
		end
		
		if type(palate.had_colors) == "table" then
			palate.had_colors[color] = true
			if palate.had_colors.dark
			and palate.had_colors.milk
			and palate.had_colors.white then
				palate.had_colors = true
			end
		end
		
		if type(palate.had_shapes_in_color[color]) == "table" then
			palate.had_shapes_in_color[color][shape] = true
			if palate.had_shapes_in_color[color].slab
			and palate.had_shapes_in_color[color].torte
			and palate.had_shapes_in_color[color].diamond
			and palate.had_shapes_in_color[color].truffle then
				palate.had_shapes_in_color[color] = true
			end
		end
		
		if palate.had_shapes_in_color[color] == true then
			palate.had_shapes_in_color[color] = false
			score_increase = score_increase + 3000
			palate.ate_favourite = color:gsub("^%l", string.upper) .. " chocolate flush!"
		elseif palate.had_in_a_row >= 3 then
			score_increase = score_increase + palate.had_in_a_row * 200
			palate.ate_favourite = palate.had_in_a_row .. " of a kind!"
		elseif palate.had_colors == true then
			palate.had_colors = false
			score_increase = score_increase + 750	
			palate.ate_favourite = "One of each color!"
		end
		
		if palate.ate_favourite ~= false then
			palate.favourite_time = 0
		end
		palate.score = palate.score + score_increase
		palate.score_pool = palate.score_pool + score_pool_increase
	end
end

Palate.FinishSystem = Concord.system({
	pool = { "chocolate", "score" }
})

Palate.FinalScoreSystem = Concord.system({
	pool = { "chocolate", "score" }
})

function Palate.FinishSystem:finish(box, palate)
	if palate.score_pool == 0 then
		local pss = box.world:getSystem(Palate.ScoreSystem)
		pss:setEnabled(false)
		local pfs = box.world:getSystem(Palate.FinishSystem)
		pfs:setEnabled(false)
		local pfss = box.world:addSystem(Palate.FinalScoreSystem)
		palate.favourite_time = 100
		local had_favourite = false
		for i_entity, entity in ipairs(self.pool) do
			if entity.score.was_favourite ~= false then had_favourite = true end
		end
		
		if had_favourite == false then palate.score = "0 (Ate no favourites!)" end
		
		if palate.score > box.highscore then
			love.filesystem.write(
				box.width * box.height .. "_highscore",
				palate.score
			)
			palate.score = palate.score .. " (New record!)"
		end
	end
	
	
	-- Note: finish, update, and draw are still being emitted by box, but the systems that were
	-- handling them have been disabled. Replace them for FinalScoreSystem, then replace box with Box:new
	-- and the systems should all reset
	
	-- it's an ugly, tangled mess. No doubt about it.
end

function Palate.FinalScoreSystem:draw(box, window_width, window_height)
	box.sheet:clear()
	local x_offset = 32
	local y_offset = -24
	
	table.sort(
		self.pool,
		function(a, b)
			if a.score.score + a.score.score_pool > b.score.score + b.score.score_pool then
				return true
			elseif a.score.score + a.score.score_pool == b.score.score + b.score.score_pool then
				if a.score.score_order < b.score.score_order then 
					return true
				end
			end
			return false
		end
	)
	
	for i_entity, entity in ipairs(self.pool) do
		if i_entity > 8 then break end
		box.sheet:add(
			entity.chocolate.drawable.half_choc,
			0,
			i_entity * Chocolate.drawables.size
		)
		if entity.chocolate.filling then
			box.sheet:add(
				entity.chocolate.drawable.filling,
				0,
				i_entity * Chocolate.drawables.size
			)
		end
		if entity.chocolate.deco then
			box.sheet:add(
				entity.chocolate.drawable.half_deco,
				0,
				i_entity * Chocolate.drawables.size
			)
		end
		
		local fav = entity.score.was_favourite
		local fav_pre = " - "
		if fav == false then
			fav = ""
			fav_pre = ""
		end
		love.graphics.print(
			"Points: " .. entity.score.score + entity.score.score_pool
				.. fav_pre .. fav,
			x_offset + 36,
			y_offset + 6 + i_entity * Chocolate.drawables.size
		)
-- 		love.graphics.print(
-- 			"Name: " .. entity.chocolate.name,
-- 			x_offset + 36,
-- 			y_offset + 14 + i_entity * Chocolate.drawables.size
-- 		)
	end
	
	love.graphics.draw(
		box.sheet,
		x_offset,
		y_offset
	)
end

function Palate:new()
	local palate = {
		favourites = {
			color = Chocolate.colors[love.math.random(1, table.getn(Chocolate.colors))],
			filling = Chocolate.fillings[love.math.random(1, table.getn(Chocolate.fillings))],
	        deco = Chocolate.decos[love.math.random(1, table.getn(Chocolate.decos))]
		},
		score = 0,
		score_pool = 0,
		score_time = 0,
		chocolates_eaten = {},
		ate_favourite = false,
		favourite_time = 0,
		had_colors = {
			dark = false,
			milk = false,
			white = false
		},
		had_shapes_in_color = {
			dark = {
				slab = false,
				torte = false,
				diamond = false,
				truffle = false
			},
			milk = {
				slab = false,
				torte = false,
				diamond = false,
				truffle = false
			},
			white = {
				slab = false,
				torte = false,
				diamond = false,
				truffle = false
			}
		},
		had_in_a_row = 0,
		had_in_a_row_type = {
			color = false,
			shape = false,
			filling = false,
			deco = false
		}
	}
	
	function palate.reset(self)
		self.score = 0
		-- score_pool can be carried over by not waiting for score display!
		-- note, doing so means your score cannot be saved as a high score
		self.score_time = 0
		self.chocolates_eaten = {}
		self.ate_favourite = false
		self.favourite_time = 0
		self.had_colors = {
			dark = false,
			milk = false,
			white = false
		}
		self.had_shapes_in_color = {
			dark = {
				slab = false,
				torte = false,
				diamond = false,
				truffle = false
			},
			milk = {
				slab = false,
				torte = false,
				diamond = false,
				truffle = false
			},
			white = {
				slab = false,
				torte = false,
				diamond = false,
				truffle = false
			}
		}
		self.had_in_a_row = 0
		self.hade_in_a_row_type = {
			color = false,
			shape = false,
			filling = false,
			deco = false
		}
	end
	
	return palate
end

return Palate
