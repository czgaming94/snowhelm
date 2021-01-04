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

function Item:init(G, id)
	Game = G
	print(7)
	self.img = "data/img/" .. Game.data.ItemTxt[id]["name"] .. ".png"
	self.imgObj = lg.newImage(self.img)
	self.id = id
	self.power = Game.data.itemTxt[id].power
	self.type = Game.data.itemTxt[id]["type"]
end

return Item