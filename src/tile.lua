local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Tile = class()
--[[


---------------------------------------------------------------------------------------------------------
						TILE
---------------------------------------------------------------------------------------------------------


--]]

function Tile:init(x,y,id)
	self.x = x
	self.y = y
	self.id = id
	self.event = nil
	self.obj = nil
	self.canWalk = true
	self.img = nil
	self.display = true
	self.inTown = false
	self.fixed = false
end

return Tile