local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Monster = require("src.monster")
local B = class()
local Game, Map, Player, Battle
--[[


---------------------------------------------------------------------------------------------------------
						BATTLE
---------------------------------------------------------------------------------------------------------


--]]

function B:init(G)
	Game = G
	Player = Game.data.Player
	Map = Game.data.Map
	Battle = self
	Game.data.battle = Battle
	self.bg = Map.data.battlebgs[random(1,#Map.data.battlebgs)]
	self.bgObj = lg.newImage("data/img/" .. self.bg .. ".png")
	self.monsters = {}
	self.currentTarget = nil
	local num = Game.data.maps[Map.data.img:gsub("data/img/", ""):gsub(".png", "")]
	local number = ceil(random(1,4) * num)
	local start = 1
	while start <= number do
		monster = Monster(Game)
		table.insert(self.monsters, monster)
		start = start + 1
	end
	self.totalMonsters = #self.monsters
	self.shownItems = false
	self.lastTarget = nil
	self.rewards = {}
	self.rewards.gold = 0
	--Game.data.canMove = false
end

function B:calcDamageToMonster(id)
	local m = self.monsters[id]
	self.currentTarget = m
	
	if Player:calcHitChance(self) > m:calcEvasion() then
		local weaponDamage = 1
		if Player.data.items.equipped.main.item then
			weaponDamage = Player:calcWeaponDamage()
		end
		local power = ceil((Player:getStat("STRENGTH") * 100) / (Player.data.hpScale * 100))
		local roll = 0 + weaponDamage + power
		local damage = random(0, roll)
		
		if damage > 0 then
			m:hurt(damage)
		else
			Game:Info(m.name .." dodged your attack!")
		end
	else
		Game:Info(m.name .." dodged your attack!")
	end
end

function B:giveItems()
	Game.data.activeText = ""
	for k,val in pairs(Battle.rewards) do
		if type(val) == "table" then
			for i,v in pairs(val) do
				if i ~= "gold" then
					Game.data.activeText = Game.data.activeText .. Player:addItem(Game, v.id, 1, 0, true)
				end
			end
		end
		if k == "gold" then
			Player:add("gold", val)
			Game.data.activeText = Game.data.activeText .. "@@@" .. tostring(val) .. " Gold"
		end
	end
	Game.data.showLoot = true
	Game.data.canMove = false
end

return B