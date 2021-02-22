local Concord = require "lib/Concord" -- https://github.com/Tjakka5/Concord

local Chocolate = {}

Concord.component("chocolate",
	function(component, color, shape, filling, deco)
		component.color = color
		component.shape = shape
		component.filling = filling
		component.deco = deco
		component.drawable = {
			half_choc = Chocolate.drawables.half_chocs[shape][color],
			whole_choc = Chocolate.drawables.whole_chocs[shape][color]
		}
		if shape == "slab" then
			component.mass = love.math.random(10, 20)
		else
			component.mass = love.math.random(5, 15)
		end
		if filling then
			component.drawable.filling = Chocolate.drawables.fillings[shape][filling]
		end
		if deco then
			component.drawable.half_deco = Chocolate.drawables.half_decos[shape][deco]
			component.drawable.whole_deco = Chocolate.drawables.whole_decos[shape][deco]
		end

		-- naming chocolates removed
		-- better that player sees chocolate as whatever they want
		-- who am i to tell you what a gooey red filling means to you!
                
-- 		if shape == "slab" then
-- 			component.name = color:gsub("^%l", string.upper) .. " chocolate slab"
--         elseif shape == "truffle" then
--             if filling then
-- 				component.name = color:gsub("^%l", string.upper) .. " " .. filling .. " truffle"
-- 			else 
-- 				component.name = color:gsub("^%l", string.upper) .. " chocolate truffle"
-- 			end
-- 		elseif shape == "torte" then
--             if filling then
-- 				component.name = color:gsub("^%l", string.upper) .. " " .. filling .. " filled torte"
-- 			else
-- 				component.name = color:gsub("^%l", string.upper) .. " chocolate torte"
-- 			end
-- 		else
-- 			if filling then
-- 				component.name = color:gsub("^%l", string.upper) .. " " .. filling .. " filled chocolate"
--             elseif deco then
-- 				component.name = color:gsub("^%l", string.upper) .. " chocolate with " .. deco
-- 			else
-- 				component.name = color:gsub("^%l", string.upper) .. " chocolate"
-- 			end
-- 		end
	end
)

Chocolate.colors = {
	"dark",
	"milk",
	"white"
}
Chocolate.shapes = {
	"slab",
	"torte",
	"diamond",
	"truffle"
}
Chocolate.fillings = {
	"cream",
	"fudge",
	"hazelnut",
	"cherry",
	"caramel",
	"mint"
}
Chocolate.decos = {
	"coconut shavings",
	"cocoa shavings",
	"hazelnut glaze",
	"cherry glaze",
	"caramel glaze",
	"mint glaze"
}

function Chocolate.entity(self, color, shape, filling, deco)
	if not color then 
		color =  self.colors[love.math.random(1, table.getn(self.colors))]
		shape = self.shapes[love.math.random(1, table.getn(self.shapes))]
		filling = self.fillings[love.math.random(0, table.getn(self.fillings))]
		deco = self.decos[love.math.random(0, table.getn(self.decos))]
	end
	
	if shape == "slab" 
	or (color == "dark" and filling == "fudge")
	or (color == "milk" and filling == "hazelnut")
	or (color == "white" and filling == "cream")
	or filling == 0 then
		filling = nil
	end
	
	if (color == "dark" and deco == "cocoa shavings")
	or (color == "milk" and deco == "hazelnut glaze")
	or (color == "white" and deco == "coconut shavings")
	or deco == 0 then
		deco = nil
	end
	
	return Concord.entity():give("chocolate", color, shape, filling, deco)
end

-- Must be run before using!
function Chocolate.load(self)
	self.drawables = {
		image = love.graphics.newImage("art/chocolates.png"),
		sheet_width = 768,
		sheet_height = 128,
		size = 32,
		half_chocs = {},
		whole_chocs = {},
		fillings = {},
		half_decos = {},
		whole_decos = {},
	}
	
	local whole_choc_offset = table.getn(self.colors) * self.drawables.size
	local filling_offset = whole_choc_offset + table.getn(self.colors) * self.drawables.size
	local half_deco_offset = filling_offset + table.getn(self.fillings) * self.drawables.size
	local whole_deco_offset = half_deco_offset + table.getn(self.decos) * self.drawables.size
	
	for i_shape, shape in ipairs(self.shapes) do
		self.drawables.half_chocs[shape] = {}
		self.drawables.whole_chocs[shape] = {}
		self.drawables.fillings[shape] = {}
		self.drawables.half_decos[shape] = {}
		self.drawables.whole_decos[shape] = {}
		
		for i_color, color in ipairs(self.colors) do
			self.drawables.half_chocs[shape][color] = love.graphics.newQuad(
				(i_color - 1) * self.drawables.size,
				(i_shape - 1) * self.drawables.size,
				self.drawables.size, self.drawables.size,
				self.drawables.sheet_width, self.drawables.sheet_height
			)
			self.drawables.whole_chocs[shape][color] = love.graphics.newQuad(
				whole_choc_offset + (i_color - 1) * self.drawables.size,
				(i_shape - 1) * self.drawables.size,
				self.drawables.size, self.drawables.size,
				self.drawables.sheet_width, self.drawables.sheet_height
			)
		end
		for i_filling, filling in ipairs(self.fillings) do
			self.drawables.fillings[shape][filling] = love.graphics.newQuad(
				filling_offset + (i_filling - 1) * self.drawables.size,
				(i_shape - 1) * self.drawables.size,
				self.drawables.size, self.drawables.size,
				self.drawables.sheet_width, self.drawables.sheet_height
			)
		end
		for i_deco, deco in ipairs(self.decos) do
			self.drawables.half_decos[shape][deco] = love.graphics.newQuad(
				half_deco_offset + (i_deco - 1) * self.drawables.size,
				(i_shape - 1) * self.drawables.size,
				self.drawables.size, self.drawables.size,
				self.drawables.sheet_width, self.drawables.sheet_height
			)
			self.drawables.whole_decos[shape][deco] = love.graphics.newQuad(
				whole_deco_offset + (i_deco - 1) * self.drawables.size,
				(i_shape - 1) * self.drawables.size,
				self.drawables.size, self.drawables.size,
				self.drawables.sheet_width, self.drawables.sheet_height
			)
		end
	end
end

return Chocolate
