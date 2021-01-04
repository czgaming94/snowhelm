local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Item = class()
local Game, Map, Player, Battle, Monster

--[[


---------------------------------------------------------------------------------------------------------
						ITEM
---------------------------------------------------------------------------------------------------------


--]]

function Item:init(Game, id)
	self.name = Game.data.itemText[id][1]
	self.img = "data/img/item/" .. self.name:gsub(" ",""):lower() .. ".png"
	self.imgObj = lg.newImage(self.img)
	self.id = id
	self.power = Game.data.itemText[id].power
	self.type = Game.data.itemText[id]["type"]
end

return Item