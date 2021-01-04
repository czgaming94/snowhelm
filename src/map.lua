local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Tile = require("src.tile")
local M = class()
local Game, Map, Player, Battle, Monster
--[[


---------------------------------------------------------------------------------------------------------
						MAPS
---------------------------------------------------------------------------------------------------------


--]]

function M:init(Game, img, startX, startY, startBlock, id, audio)
	Game = Game
	self.data = {
		img = img or "data/img/cherrichills.png",
		printed = nil,
		x = startX or 1300,
		y = startY or 1100,
		id = id or 1,
		OffX = 0,
		OffY = 0,
		width = 0,
		height = 0,
		startBlock = startBlock or 1450,
		obj = nil,
		objects = {tree = {},rock = {},smallhouse = {},largehouse = {},inn = {},dungeon = {},armorshop = {},weaponshop = {}},
		tiles = {},
		battlebgs = {},
		mapAudio = audio and love.audio.newSource(audio) or nil
	}
	self.data.printed = lg.newImage(self.data.img)
	self.data.width = self.data.printed:getWidth()
	self.data.height = self.data.printed:getHeight()
	self.data.obj = lg.newQuad(0,0,self.data.width,self.data.height,self.data.printed:getDimensions())
	self:setBattleBG()
end

function M:generateTiles()
	local tileCount = 1
	local y = 0
	while y < 2800 do
		local x = 0
		while x < 4200 do
			if not self.data.tiles[tileCount] or self.data.tiles[tileCount].display then 
				table.insert(self.data.tiles, tileCount, Tile(x,y,tileCount))
			end
			x = x + 50
			tileCount = tileCount + 1
		end
		y = y + 50
	end
end

function M:setBattleBG()
	if string.match(self.data.img, "cherrichills") then
		self.data.battlebgs = {"grass","rock","woods"}
	elseif string.match(self.data.img, "grayhold") then
		self.data.battlebgs = {"rock", "water", "ruin"}
	end
end

function M:resetImage()
	if type(self.data.printed) == "string" then 
		self.data.printed = lg.newImage(self.data.img)
	end
end

function M:displayTiles(Game)
	if not GHG or GHG < 10 then
		if not GHG then GHG = 0 end
		print(5)
		GHG = GHG + 1
	end
	self = Game.data.Map
	local Player = Game.data.Player
	if Game.data.tileCanvas then
		if type(Game.data.tileCanvas) == "string" then
			Game.data.tileCanvas = nil
		else
			Game.data.tileCanvas:release() 
		end
	end
	Game.data.tileCanvas = lg.newCanvas(4200,2800)
	lg.setCanvas(Game.data.tileCanvas)
	for key,index in pairs(self.data.tiles) do
		if index.display then
			if type(Player.data.tile) == "number" then Player.data.tile = self.data.tiles[Player.data.tile] end
			if (index.x >= Player.data.tile.x - 400 and index.x <= Player.data.tile.x + 400) and (index.y >= Player.data.tile.y - 300 and index.y <= Player.data.tile.y + 300) then
				if index.img then 
					local x, y = index.x, index.y
					if index.img.imgType == "chestopen" then
						if not index.fixed then
							index.img.imgObj = lg.newImage("data/img/" .. index.img.imgType .. ".png")
							index.fixed = true
						end
					end
					if type(index.img.imgObj) == "string" then index.img.imgObj = lg.newImage("data/img/" .. index.img.imgType .. ".png") end
					if index.img.imgType == "treebottom" or index.img.imgType == "treetop" then x = x - 6 y = y - 9 end
					if index.img.imgType == "smallrock" then x = x + 3 end
					if index.img.imgType == "chest" or index.img.imgType == "chestopen" then x = x + 3 y = y + 10 end
					if index.img.imgType == "shrub" then x = x - 6 y = y + 2 end
					if index.img.imgType == "treelogleft" or index.img.imgType == "treelogright" then x = x + 3 y = y + 10 end
					if index.img.imgType == "signpost" then x = x + 11 y = y + 10 end
					if index.img.imgType == "stump" then x = x y = y end
					lg.draw(index.img.imgObj, x, y)
				end
				lg.print(key, index.x, index.y)
			end
			lg.rectangle("line",index.x,index.y,50,50)
		end
	end
	lg.rectangle("line", 0, 0, 4200, 2800)
	lg.setCanvas()
	
	lg.draw(Game.data.tileCanvas, self.data.x + 400, self.data.y + 400)
end

function M:setTiles()
	print(2)
	local map = self.data.img:gsub("data",""):gsub("img",""):gsub("/",""):gsub(".png","")
	if not lf.getInfo("data/events/" .. map .. ".lua") then return false end
	
	local events = require("data/events/" .. map)
	for eventKey,eventIndex in pairs(events) do	
		for key,index in pairs(eventIndex) do
			if self.data.tiles[eventKey].display then
				local data = index
				if key == "img" then 
					data = {imgType = index, imgObj = lg.newImage("data/img/" .. index .. ".png")} 
				end
				self.data.tiles[eventKey][key] = data
			end
		end
	end
end

function M:setPlayer(p)
	Player = p
end

return M