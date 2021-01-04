local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Monster = class()
local Game, Map, Player, Battle
--[[


---------------------------------------------------------------------------------------------------------
						MONSTER
---------------------------------------------------------------------------------------------------------


--]]

--[[
	RESISTANCES - [1] FIRE [2] AIR [3] POISON
	STATS - [1] ACCURACY [2] AGILITY  [3] ENDURANCE [4] INTELLECT [5] LUCK [6] PERCEPTION [7] SPEED [8] STRENGTH 
--]]
function Monster:init(G)
	Game = G
	Map = Game.data.Map
	Player = Game.data.Player
	Battle = Game.data.battle
	local num = Game.data.maps[Map.data.img:gsub("data/img/", ""):gsub(".png", "")]
	local allowedMonsters = {}
	for key,m in pairs(Game.data.monsters) do
		if string.match(m.maps, tostring(num)) then table.insert(allowedMonsters, m) end
	end
	local monType = allowedMonsters[random(1, #allowedMonsters)]
	for k,v in pairs(monType) do self[k] = v end
	self.img = self.name:lower():gsub("%s+", "")
	self.imgObj = lg.newImage("data/img/monster/" .. self.img .. ".png")
	self.alive = true
end

function Monster:generateItems()
	local m = self
	local items = {}
	
	local allowedItems = {}
	
	for k, v in pairs(Game.data.items) do
		if string.match(self.itemTiers, v.tier) then table.insert(allowedItems, v) end
	end
	
	local i = 0
	
	while i < random(0, tonumber(self.maxItems)) do
		table.insert(items, allowedItems[random(1, #allowedItems)])
		i = i +1
	end
	return items
end

function Monster:hurt(dmg)
	local m = self
	if dmg > m.hp then
		Battle.rewards.gold = Battle.rewards.gold + m.gold
		Info("You dealt " .. dmg .. " damage to " .. m.name .. " dealing the killing blow!")
		table.insert(Battle.rewards, m:generateItems())
		table.remove(Battle.monsters, id)
	else
		Info("You dealt " .. tostring(dmg) .. " damage to " .. m.name .. "!")
		m.hp = m.hp - dmg
	end
end

function Monster:calcEvasion()
	return (random(1,100) + ceil((self.level + ceil(self:getStat("SPEED") / 2)) / 2) + ceil(self:getStat("LUCK") / 2))
end

function Monster:getStat(stat)
	return self.stats[stat].value
end

function Monster:setStat(stat, newVal)
	self.stats[stat].value = newVal
end

function Monster:SplitStats()
	return unpack(pairsByKeys(self.stats))
end

return Monster