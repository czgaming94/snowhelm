local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local serpent = require("src.serpent")
local G = class()
local B = require("src.battle")
local Game, Map, Player, Battle, Monster
--[[


---------------------------------------------------------------------------------------------------------
						GAME
---------------------------------------------------------------------------------------------------------


--]]

function G:init()
	self.data = {
		quitGame = {["data/img/quitgamedefault.png"] = true, ["data/img/quitgameactive.png"] = true},
		newGame = {["data/img/newgamedefault.png"] = true, ["data/img/newgameactive.png"] = true},
		loadGame = {["data/img/loadgamedefault.png"] = true, ["data/img/loadgamedisabled.png"] = true, ["data/img/loadgameactive.png"] = true},
		newGameClasses = {["data/img/stealthdefault.png"] = true, ["data/img/stealthactive.png"] = true, ["data/img/meleedefault.png"] = true, ["data/img/meleeactive.png"] = true, ["data/img/magicdefault.png"] = true, ["data/img/magicactive.png"] = true},
		maps = {["cherrichills"] = 1, ["grayhold"] = 2},
		Map = nil,
		Player = nil,
		battle = nil,
		curSave = "snowhelm001.sav",
		icons = {},
		backgrounds = {},
		fonts = {},
		saves = {},
		gameState = 0,
		choice = nil,
		showNewGameFinal = false,
		wantsToQuit = false,
		choosingNewGameName = false,
		watchedIntro = false,
		curStep = nil,
		newGameBG = nil,
		loadGameBG = nil,
		loadMenu = false,
		lastActiveObj = nil,
		newGameStep = nil,
		newGameBgId = 1,
		newGameChoice = nil,
		newGameName = "",
		newGameStats = {},
		newGameStatPointsLeft = 25,
		curX = 0,
		curY = 0,
		speechText = {},
		itemText = {},
		items = {},
		monsterText = {},
		monsters = {},
		mapText = {},
		days = 1,
		activeText = "",
		canMove = false,
		files = {"speechText", "itemText", "monsterText", "mapText"},
		tileCanvas = lg.newCanvas(4200,2800),
		showBattle = false,
		showInventory = false,
		showLoot = false,
		mainMenuAudio = nil,
		clickAudio = nil,
		showBattleAnimation = false,
		fadescreen = nil,
		fadeColorBlack = {0,0,0,0},
		fadeColorWhite = {0,0,0,0},
		snapshot = nil,
		showRestScreen = false,
		askRestBG = nil,
		showAskRest = false,
		restCost = 0,
		safeRest = false,
		showOverlay = false,
		animateFrom = "",
		musicFiles = {},
		mapMusic = nil
	}
	self:loadFiles()
	Game = self
end

function G:setSnap(img)
	Game.data.showOverlay = true
	Game.data.snapshot = lg.newImage(self)
	Game.data.fadescreen = {"fill", 0, 0, lg.getWidth(), lg.getHeight()}
	Game.data.canMove = false
	if Game.data.animateFrom == "battle" then Game:makeBattle() end
	if Game.data.animateFrom == "rest" then Game:makeRest() end
end

function G:makeRest()
	self.data.showRestScreen = true
end

function G:makeBattle()
	self.data.showBattleAnimation = true
	self.data.battle = B(self)
	Battle = self.data.battle
end

function G:loadFiles()
	for key, file in pairs(self.data.files) do
		for line in lf.lines("data/txt/" .. file .. ".txt") do
			if string.sub(line, 1, 1) == "#" then goto notTxtItem end
			local dataText = split("\t", line)
			local send = {}
			for k,i in pairs(dataText) do if k ~= 1 then table.insert(send, i) end end
			table.insert(self.data[file], tonumber(dataText[1]), send)
			::notTxtItem::
		end
	end
	
	self:setItems()
	self:setMonsters()
end

function G:setItems()
	for key, item in pairs(self.data.itemText) do
		local i = {}
		i.id = key
		i.name = item[1]
		i.type = item[2]
		i.power = item[3]
		i.description = item[4]
		i.tier = item[5]
		self.data.items[item[1]:lower():gsub("%s+","")] = i
	end
end

function G:setMonsters()
	local stats = {ACCURACY={},AGILITY={},ENDURANCE={},INTELLECT={},LUCK={},PERCEPTION={},SPEED={},STRENGTH={}}
	for key, monster in pairs(self.data.monsterText) do
		local m = {}
		local damage = string.split(monster[2], "d")
		local health = string.split(monster[3], "d")
		
		m.id = key
		m.name = monster[1]
		m.rolls = tonumber(damage[1])
		m.hit = tonumber(damage[2])
		
		m.hp = 0
		local h = 1
		while h <= tonumber(health[1]) do
			m.hp = m.hp + love.math.random(1, tonumber(health[2]))
			h = h + 1
		end
		
		m.gold = 0
		local gold = string.split(monster[12], "d")
		local g = 1
		while g <= tonumber(gold[1]) do
			m.gold = m.gold + love.math.random(1, tonumber(gold[2]))
			g = g + 1
		end
		
		m.ac = monster[4]
		m.level = monster[5]
		m.skill = monster[6]
		m.resistances = monster[7]
		m.stats = string.split(monster[8], ",", "number")
		stats.ACCURACY.value,stats.AGILITY.value,stats.ENDURANCE.value,stats.INTELLECT.value,stats.LUCK.value,stats.PERCEPTION.value,stats.SPEED.value,stats.STRENGTH.value = m.stats[1],m.stats[2],m.stats[3],m.stats[4],m.stats[5],m.stats[6],m.stats[7],m.stats[8]
		m.stats = stats
		m.maps = monster[9]
		m.itemTiers = monster[10]
		m.maxItems = monster[11]
		local size = string.split(monster[13], ",")
		m.w = size[1]
		m.h = size[2]
		
		self.data.monsters[monster[1]:lower():gsub("%s+","")] = m
	end
end

function G:showMonsters(battle)
	if not battle then return false end
	local count = #battle.monsters
	
	if count == 0 and not battle.shownItems then
		if #battle.rewards > 1 then
			battle:giveItems()
			battle.shownItems = true
		else
			Game.data.showOverlay = false
			Game.data.canMove = true
			Game.data.showBattle = false
			Game.data.showInventory = false
			Game.data.showLoot = false
			Game.data.battle = nil
			Game.data.activeText = ""
			return
		end
	end
	local midRange = 416 - (32 * count - 1)
	local curPos = midRange - 32
	local curM = 1
	local mx,my = lm.getPosition()
	
	for key, m in pairs(battle.monsters) do
		if curM <= 5 then
			lg.rectangle("fill", curPos - 5, 230, 70, 70)
			if (mx >= curPos and mx <= curPos + m.w) and (my >= 236 and my <= 236 + m.h) then
				lg.print(m.name, curPos, 200)
			end
			lg.draw(m.imgObj, curPos, 236)
		elseif curM <= 10 then
			lg.rectangle("fill", curPos - 5, 244, 70, 70)
			if (mx >= curPos and mx <= curPos + m.w) and (my >= 236 and my <= 236 + m.h) then
				lg.print(m.name, curPos, 250)
			end
			lg.draw(m.imgObj, curPos, 305)
		elseif curM <= 15 then
			lg.rectangle("fill", curPos - 5, 363, 70, 70)
			if (mx >= curPos and mx <= curPos + m.w) and (my >= 236 and my <= 236 + m.h) then
				lg.print(m.name, curPos, 310)
			end
			lg.draw(m.imgObj, curPos, 369)
		else
			lg.rectangle("fill", curPos - 5, 427, 70, 70)
			if (mx >= curPos and mx <= curPos + m.w) and (my >= 236 and my <= 236 + m.h) then
				lg.print(m.name, curPos, 370)
			end
			lg.draw(m.imgObj, curPos, 433)
		end
		curPos = curPos + 71
		curM = curM + 1
	end
end

function G:GUI()
	lg.setColor(0,0,0,.7)
	lg.rectangle("fill", 0, 550, 800, 50)
	lg.setColor(1,1,1,1)
	lg.rectangle("line", -1, 549, 802, 50)
	local font = lg.getFont()
	if font ~= self.data.fonts.fancy then lg.setFont(self.data.fonts.fancy) font = lg.getFont() end
	local x = 10
	lg.print("Gold: " .. Player.data.gold, x, 567)
	x = x + font:getWidth("Gold: " .. Player.data.gold) + 30
	
	lg.print("HP: ", x, 567)
	x = x + font:getWidth("HP: ") + 5
	
	lg.print(Player.data.hp .. "/" .. Player.data.hpMax, x, 567)
	x = x + font:getWidth(Player.data.hp .. "/" .. Player.data.hpMax) + 30
	
	lg.print("MP: ", x, 567)
	x = x + font:getWidth("MP: ") + 5
	lg.print(Player.data.mp .. "/" .. Player.data.mpMax, x, 567)
end

function G:setSelf()
	Map = self.data.Map
	Player = self.data.Player
	if type(Map.data.printed) == "string" or type(Map.data.obj) == "string" then
		Map.data.printed = lg.newImage(Map.data.img) 
		Map.data.obj = lg.newQuad(0,0,Map.data.width,Map.data.height,Map.data.printed:getDimensions())
	end	
	if type(self.data.fonts.header) == "string" then self.data.fonts.header = lg.newFont("data/font/header.ttf", 20) end
	if type(self.data.fonts.text) == "string" then self.data.fonts.text = lg.newFont(16) end
end


function G:getSelf()
	return self
end

function G:reset()
	self.data.quitGame = {["data/img/quitgamedefault.png"] = true, ["data/img/quitgameactive.png"] = true}
	self.data.newGame = {["data/img/newgamedefault.png"] = true, ["data/img/newgameactive.png"] = true}
	self.data.loadGame = {["data/img/loadgamedefault.png"] = true, ["data/img/loadgamedisabled.png"] = true, ["data/img/loadgameactive.png"] = true}
	self.data.newGameClasses = {["data/img/stealthdefault.png"] = true, ["data/img/stealthactive.png"] = true, ["data/img/meleedefault.png"] = true, ["data/img/meleeactive.png"] = true, ["data/img/magicdefault.png"] = true, ["data/img/magicactive.png"] = true}
	self.data.curSave = "snowhelm001.sav"
	self.data.gameState = 0
	self.data.choice = nil
	self.data.showNewGameFinal = false
	self.data.wantsToQuit = false
	self.data.choosingNewGameName = false
	self.data.watchedIntro = false
	self.data.curStep = nil
	self.data.newGameBG = nil
	self.data.loadGameBG = nil
	self.data.lastActiveObj = nil
	self.data.newGameStep = nil
	self.data.newGameBgId = 1
	self.data.newGameChoice = nil
	self.data.newGameName = ""
	self.data.newGameStats = {}
	self.data.newGameStatPointsLeft = 25
	self.data.activeText = ""
	self.data.canMove = false
end

function G:generateBattle()
	Game.data.animateFrom = "battle"
	lg.captureScreenshot(self.setSnap)
end

function G:showRest()
	Game.data.animateFrom = "rest"
	lg.captureScreenshot(self.setSnap)
end

function G:loadMusic()
	local files = love.filesystem.getDirectoryItems("data/audio/music/")
	for k,v in pairs(files) do
		if not self.data.musicFiles[k] then
			print(v)
			self.data.musicFiles[k] = v
		end
	end
end

function G:Rest()
	self:showRest()
	Player.data.gold = Player.data.gold - self.data.restCost
	self.data.restCost = 0
	Player.data.hp = Player.data.hpMax
	Player.data.mp = Player.data.mpMax
	self.data.days = self.data.days + 1
end

function G:askRest(cost, safe)
	self.data.showAskRest = true
	self.data.restCost = cost or 0
	self.data.safeRest = safe or false
	self.data.showOverlay = true
end

function G:Chest(quality, items, gold, tile)
	local text = ""
	tile = tile or Player.data.tile
	if Map.data.tiles[tile] then
		Map.data.tiles[tile].img.imgType = "chestopen"
		Map.data.tiles[tile].img.imgObj = lg.newImage("data/img/chestopen.png")
		Map.data.tiles[tile].event = nil
	end
	if items then
		quality = quality and quality or 0
		if type(items) == "table" then
			for k,v in pairs(items) do
				text = text .. Player:addItem(Game, v[1], v[2], quality)
			end
		end
	end
	if gold then
		Player.data.gold = Player.data.gold + gold
		text = text .. "@@@" .. tostring(gold) .. " Gold"
	end
	self:Info(text)
end

function G:Speak(id)
	if Game.data.speechText[id] then 
		Game.data.canMove = false
		Game.data.activeText = Game.data.speechText[id][1]
	end
end

function G:Info(text)
	self.data.canMove = false
	if type(text) == "number" then
		if self.data.mapText[text] then
			self.data.activeText = self.data.mapText[text][1]
			debugText = self.data.activeText
		end
		self:save()
	elseif type(text) == "string" then
		self.data.activeText = text
		self.debugText = text
	end
end

function G:save()
	local saveData = {
		map = {name = Map.data.name, x = Map.data.x, y = Map.data.y, block = Player.data.tile},
		player = deepcopy(Player.data),
		tiles = deepcopy(Map.data.tiles)
	}
	
	for k, i in pairs(saveData.player) do
		if type(saveData.player[k]) == "userdata" then
			saveData.player[k] = nil
		end
	end
	
	for k, i in ipairs(saveData.tiles) do
		if not i.img and i.display then
			saveData.tiles[k] = nil
		else 
			if i.event then
				saveData.tiles[k].event = nil
			end
			saveData.tiles[k].obj = nil
		end
		
	end
	
	for k, i in pairs(saveData.player.stats) do
		saveData.player.stats[k].upArrow,saveData.player.stats[k].downArrow = nil, nil
	end
	
	local text = serpent.block(saveData):gsub("%snil,%s", "")
	if lf.getInfo(Player.data.name .. ".sav") then lf.remove(Player.data.name .. ".sav") end
	lf.write(Player.data.name .. ".sav", "return { Data = " .. text .. " }")
end

return G