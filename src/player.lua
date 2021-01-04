local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Item = require("src.item")
local funcs = require("src.helper")
local P = class()
local Game, Map, Player, Battle, Monster
--[[


---------------------------------------------------------------------------------------------------------
						PLAYER
---------------------------------------------------------------------------------------------------------


--]]

function P:init(G,classType,stats,name,x,y,tile)
	Game = G
	Map = Game.data.Map
	Player = self
	self.data = {
		img = lg.newImage("data/img/player.png"),
		name = name or "New Player",
		stats = stats or {STRENGTH={value=10},INTELLECT={value=10},PERCEPTION={value=10},ENDURANCE={value=10},ACCURACY={value=10},AGILITY={value=10},SPEED={value=10},LUCK={value=10}},
		class = classType or 1,
		tile = tile or 1450,
		x = x or 350,
		y = y or 300,
		gold = 125,
		food = 5,
		hp = 25,
		hpMax = 25,
		mp = 25,
		mpMax = 25,
		level = 1,
		hpScale = 1,
		mpScale = 1,
		pet = lg.newImage("data/img/simon.png"),
		items = {
			equipped = {
				helm = {item = nil, useable = true},
				chest = {item = nil, useable = true},
				gloves = {item = nil, useable = true},
				boots = {item = nil, useable = true},
				main = {item = nil, useable = true},
				offhand = {item = nil, useable = false}
				-- Offhand TODO useable at level 5
			},
			bag = {}
		}
	}
	if self.data.class == "stealth" then self.data.hpScale = 2.25 self.data.mpScale = 2.25 end
	if self.data.class == "melee" then self.data.hpScale = 1.5 self.data.mpScale = 3.0 end
	if self.data.class == "magic" then self.data.hpScale = 3.0 self.data.mpScale = 1.5 end
	
	self:calcStats(self.data.stats)
end

function P:addItem(Game, id, amount, quality)
	doDebug(id, amount, quality)
	local itemText = ""
	
	quality = quality and quality or 1
	
	if id == 0 then
		-- Randomize item
	else
		print(table.show(Game.data.items))
		print(id)
		--local item = table.get(Game.data.items, id, true)
		local item = Item(Game, id)
		local itemCount = 0
		if item then
			print(table.show(item))
			if amount then
				while itemCount < amount do
					table.insert(self.data.items.bag, item)
					itemText = itemText .. "@@@" .. item.name
					itemCount = itemCount + 1
				end
			else
				itemText = itemText .. "@@@" .. item.name
			end
		end
	end
	return itemText
end

function P:calcStats(stats)
	local INT, END = stats["INTELLECT"].value, stats["ENDURANCE"].value
	self.data.hpMax = self.data.hpMax + max(0, ceil(( (100 * END) / (100 * self.data.hpScale)) + (self.data.level - 1)) + 10)
	self.data.mpMax = self.data.mpMax + max(0, ceil(( (100 * INT) / (100 * self.data.mpScale)) + (self.data.level - 1)) + 10)
	self:maxStats(2)
end

function P:calcHitChance(battle)
	if not battle then return false end
	return (random(1,100) + ceil((self.data.level + ((self:getStat("ACCURACY") - battle.currentTarget.level) + ceil(self:getStat("SPEED") / 2)) - battle.currentTarget.level) / 2))
end

function P:calcWeaponDamage()
	doDebug(table.show(self))
end

--[[
	Player:maxStats(0) - Full HP
	Player:maxStats(1) - Full MP
	Player:maxStats(2) - Full HP/MP
--]]
function P:maxStats(t)
	if t == 0 or t == 2 then self.data.hp = self.data.hpMax end
	if t == 1 or t == 2 then self.data.mp = self.data.mpMax end
end

function P:display()
	if not self.data.img or type(self.data.img) == "string" then self.data.img = love.graphics.newImage("data/img/player.png") end
	if not self.data.pet or type(self.data.pet) == "string" then self.data.pet = love.graphics.newImage("data/img/simon.png") end
	lg.draw(self.data.img, self.data.x + 12, self.data.y + 5)
	lg.draw(self.data.pet, self.data.x + 40, self.data.y + 15)
end

function P:setPos(tile)
	self.data.tile = tile
end

function P:calcMaxGold()
	local luck = self:getStat("LUCK")
end

function P:setStat(stat, val)
	self.data.stats[stat] = self:getStat(stat) + val
end

function P:SplitStats()
	return unpack(pairsByKeys(self.data.stats))
end

function P:equipItem(item, slot)
	if not item or not slot then return false end
	self.data.items.equipped[slot].item = item
	return true
end

--[[
	Player:add("hp", 10)
	Player:add("mp", 10)
	Player:add("experience", 500)
	Player:add("gold", 250)
--]]

function P:add(t, amount)
	if not t or not amount or not self.data[t] then return false end
	local limit = self.data[("%sMax"):format(t)] or math.huge
	self.data[t] = min(limit, max(0, self.data[t] + amount))
	return true
end

function P:subtract(t, amount)
	if not t or not amount or not self.data[t] then return false end
	self.data[t] = max(0, self.data[t] - amount)
end

--[[
	[1] ACCURACY 
	[2] AGILITY 
	[3] ENDURANCE 
	[4] INTELLECT 
	[5] LUCK
	[6] PERCEPTION 
	[7] SPEED 
	[8] STRENGTH 
--]]

function P:getStat(stat)
	return self.data.stats[stat].value
end

function P:setStat(stat, newVal)
	self.data.stats[stat].value = newVal
end

return P