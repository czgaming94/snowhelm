local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local la, ld, lf, lg, lm, lv = love.audio, love.data, love.filesystem, love.graphics, love.mouse, love.video
local sw, sh = lg.getDimensions()
local class = require("src.class")
local serpent = require("src.serpent")
local Tile = class()
local funcs = require("src.helper")
local G = require("src.game")
local M = require("src.map")
local P = require("src.player")
local B = require("src.battle")
local Item = require("src.item")
local Icon = require("src.icon")
local Mon = require("src.monster")
local Game, Map, Player, Battle, Icons, BG
local introVideo = lg.newVideo(lv.newVideoStream("data/video/intro.ogg"))
local showIntro = false
local allowBattle = true


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


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function G:setSnap(img)
	Game.data.showOverlay = true
	Game.data.snapshot = lg.newImage(self)
	Game.data.fadescreen = {"fill", 0, 0, lg.getWidth(), lg.getHeight()}
	Game.data.canMove = false
	if Game.data.animateFrom == "battle" then Game:makeBattle() end
	if Game.data.animateFrom == "rest" then Game:makeRest() end
end

function G:makeRest()
	Game.data.showRestScreen = true
end

function G:makeBattle()
	Game.data.showBattleAnimation = true
	Game.data.battle = B(Game)
	Battle = Game.data.battle
end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

function P:SplitStats()
	return unpack(pairsByKeys(self.data.stats))
end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------


--[[


	LOVE FUNCTIONS


--]]
--[[
	Handles name generation, player movement, and game menu navigation
--]]
function love.keypressed( key, scancode, isrepeat )
	if Game.data.choosingNewGameName and Game.data.newGameName and not Game.data.showNewGameFinal then
		if key == "backspace" then
			if string.len(Game.data.newGameName) > 0 then
				Game.data.newGameName = Game.data.newGameName:sub(1,-2)
			end
		end
	end
	
	if Game.data.gameState == 5 then
		if Game.data.canMove then
			local tile = Player.data.tile
			if key == "r" then
				if not tile.inTown then
					if tile.img and tile.img.imgType == "campfire" then
						askRest(0, true)
					else
						askRest(0, false)
					end
				end
			end
			if key == "i" then
			
			end
			if table.find({"up", "down", "left", "right", "w", "a", "s", "d"}, key) then		
				local modifier = 0
				local moveX,moveY = Map.data.x, Map.data.y
				local pMoveX,pMoveY = Player.data.x, Player.data.y
				local tiles = Map.data.tiles
				
				if Game.data.canMove then
					if key == "up" or key == "w" then
						if not tiles[tile.id - 84] then return false end
						tile = tiles[tile.id - 84]
						pMoveY, moveY = pMoveY + 50, moveY + 50
					end
					if key == "right" or key == "d" then
						if not tiles[tile.id + 1] or tiles[tile.id + 1].x ~= tile.x + 50 then return false end
						tile = tiles[tile.id + 1]
						pMoveX, moveX = pMoveX - 50, moveX - 50
					end
					if key == "down" or key == "s" then
						if not tiles[tile.id + 84] then return false end
						tile = tiles[tile.id + 84]
						pMoveY, moveY = pMoveY - 50, moveY - 50
					end
					if key == "left" or key == "a" then
						if not tiles[tile.id - 1] or tiles[tile.id - 1].x ~= tile.x - 50 then return false end
						tile = tiles[tile.id - 1]
						pMoveX, moveX = pMoveX + 50, moveX + 50
					end
					if not tile.canWalk then return false end
					
					local chance = random(1, 100)
					if tile.inTown then chance = 100 end
					
					if chance + (20 - Player.data.level) > 25 then
						if type(tiles[tile.id].event) == "function" then
							tiles[tile.id].event(Game)
						end
						if tile.img then
							if tile.img.imgType == "tree" or tile.img.imgType == "smallrock" or tile.img.imgType == "treelog" then return false end
						end
						Player.data.tile = tile
						Map.data.x, Map.data.y = moveX, moveY
					else
						if allowBattle then
							Game:generateBattle()
						end
					end
				end
			end
		end
		
		if Game.data.activeText ~= "" and not Game.data.canMove then
			if key == "escape" then
				Game.data.canMove = true
				if Game.data.activeText ~= "" then
					Game.data.activeText = ""
				end
				if Game.data.battle and #Game.data.battle.monsters == 0 then
					Game.data.showBattle = false
					Game.data.battle = nil
				end
			end
		end
		
	end
end

function love.mousereleased(x, y, button)
	if Game.data.lastActiveObj then Game.data.lastActiveObj = nil end
end

function love.textinput(t)
	if Game.data.choosingNewGameName and not Game.data.showNewGameFinal and t ~= " " then
		if string.len(Game.data.newGameName) < 22 then Game.data.newGameName = Game.data.newGameName .. t end
	end
end

--[[
	Creates instances of all icons
--]]
function love.load(t)
	math.randomseed(os.time())
	Game = G()
	if not Game then debug.debug() end
	Game.debugText = ""
	Game:loadMusic()
	Game.data.activeText = ""
	Game.data.fonts.header = lg.newFont("data/font/header.ttf", 20)
	Game.data.fonts.fancy = lg.newFont("data/font/header.ttf", 14)
	Game.data.fonts.text = lg.newFont(16)
	Game.data.clickAudio = la.newSource("data/audio/click.mp3", "static")
	local files = lf.getDirectoryItems("/")
	for k,i in ipairs(files) do
		if string.match(i,".sav") then
			local item = {}
			item.file = i
			item.boxColor = {1,1,1,.5}
			item.textColor = {0,0,0,.5}
			table.insert(Game.data.saves, item)
		end
	end
	
	Icons = Game.data.icons
	BG = Game.data.backgrounds
	BG.intro = lg.newImage("data/img/background.png")
	
		
	-- Start Menu
	Icons.newGameDefault = Icon("data/img/newgamedefault.png", "data/img/newgameactive.png", "data/img/newgamedisabled.png", 50, 590, 7,365,7,92)
	Icons.loadGameDefault = Icon("data/img/loadgamedefault.png", "data/img/loadgameactive.png", "data/img/loadgamedisabled.png", 460, 590, 7,365,7,92)
	Icons.quitGameDefault = Icon("data/img/quitgamedefault.png", "data/img/quitgameactive.png", "data/img/quitgamedisabled.png", 880, 590, 7,365,7,92)
	
	-- Start Menu Quit
	BG.quitGameMenu = lg.newImage("data/img/quitmenudefault.png")
	Icons.quitGameYes = Icon("data/img/quitmenuyesdefault.png", "data/img/quitmenuyesactive.png", nil, 800, 340, 7,95,7,66)
	Icons.quitGameNo = Icon("data/img/quitmenunodefault.png", "data/img/quitmenunoactive.png", nil, 920, 340, 7,95,7,66)
	
	-- Start Menu New Game
	BG.newGameBG = lg.newImage("data/img/newgamemenubg.png")
	BG.newGameBG2 = lg.newImage("data/img/newgamemenubg2.png")
	BG.newGameBG3 = lg.newImage("data/img/confirmdefault.png")
	Icons.startGameContinue = Icon("data/img/continuedefault.png", "data/img/continueactive.png", "data/img/continuedisabled.png", 460, 565, 5, 265, 5, 60)
	Icons.startGameOver = Icon("data/img/startoverdefault.png", "data/img/startoveractive.png", "data/img/startoverdisabled.png", 460, 565, 5, 265, 5, 60)
	
	Icons.newGameStealth = Icon("data/img/stealthdefault.png", "data/img/stealthactive.png", nil, 200, 320, 10,260,10,300)
	Icons.newGameMelee = Icon("data/img/meleedefault.png", "data/img/meleeactive.png", nil, 510, 320, 10,260,10,300)
	Icons.newGameMagic = Icon("data/img/magicdefault.png", "data/img/magicactive.png", nil, 820, 320, 10,260,10,300)
	
	-- Load Game Menu
	BG.loadGameBG = lg.newImage("data/img/loadgamemenubg.png")
	
	-- Rest Menu
	Icons.restYes = Icon("data/img/restyesdefault.png", "data/img/restyesactive.png", nil, 115, 355, 7, 75, 7, 51)
	Icons.restNo = Icon("data/img/restnodefault.png", "data/img/restnoactive.png", nil, 185, 355, 7, 75, 7, 51)
end


function love.update(dt)
	if Game.data.showBattleAnimation then
		if Game.data.fadeColorBlack[4] < 1 then
			Game.data.fadeColorBlack[4] = Game.data.fadeColorBlack[4] + 0.025
		else
			if not Game.data.canMove then
				Game.data.showBattleAnimation = false
				Game.data.showBattle = true
			end
		end
	end
	if Game.data.showRestScreen then
		if not Game.data.whiteFadeOut then
			if Game.data.fadeColorWhite[4] < 1 then
				Game.data.fadeColorWhite[4] = Game.data.fadeColorWhite[4] + 0.025
			else
				Game.data.whiteFadeOut = true
			end
		else
			if Game.data.fadeColorWhite[4] > 0 then
				Game.data.fadeColorWhite[4] = Game.data.fadeColorWhite[4] - 0.025
			end
		end
		if Game.data.whiteFadeOut then
			if Game.data.fadeColorWhite[1] < 1 then
				for i=1, #Game.data.fadeColorWhite do
					if i < 4 then
						Game.data.fadeColorWhite[i] = Game.data.fadeColorWhite[i] + 0.025
					end
				end
			else
				if not Game.data.canMove then
					Game.data.showRestScreen = false
					Game.data.whiteFadeOut = false
					Game.data.canMove = true
					Game.data.showOverlay = false
					Game.data.fadeColorWhite = {0,0,0,0}
				end
			end
		end
	end
end

--[[
	Creates all instances of images and text
--]]
function love.draw()
	if type(Game.data.fonts.header) == "string" then Game.data.fonts.header = lg.newFont("data/font/header.ttf", 20) end

	lg.scale( sw / 1280, sh / 720 )
	lg.setColor(1,1,1,1)
	if Game.data.gameState < 2 then 
		if not Game.data.mainMenuAudio then
			Game.data.mainMenuAudio = la.newSource("data/audio/mainmenu.mp3", "stream")
		end
		if not Game.data.mainMenuAudio:isPlaying() then
			Game.data.mainMenuAudio:play()
		end
		lg.draw(BG.intro, 0, 0)
	end
	if Game.data.gameState == 0 then
		if not Game.data.wantsToQuit then
			Icons.newGameDefault:display(Game)
			Icons.loadGameDefault:display(Game)
			Icons.quitGameDefault:display(Game)
		end
	end
	if Game.data.gameState == 1 then
		if Game.data.curStep == "newGame" then
			if not Game.data.newGameStep then
				lg.draw(BG.newGameBG, 140, 220)
				Icons.newGameStealth:display(Game)
				Icons.newGameMelee:display(Game)
				Icons.newGameMagic:display(Game)
			else
				displayNewGame(Game.data.newGameStep)
			end
		end
		if Game.data.curStep == "loadGame" then
			lg.draw(BG.loadGameBG, 140, 220)
			local startY = 350
			local mx,my = lm.getPosition()
			for k,i in pairs(Game.data.saves) do
				if (mx >= 175 and mx <= 1075) and (my >= startY and my <= startY + 30) then
					i.boxColor = {1,1,1,1}
					i.textColor = {0,0,0,1}
				else
					i.boxColor = {1,1,1,.5}
					i.textColor = {0,0,0,.5}
				end
				lg.setColor(i.boxColor)
				lg.rectangle("fill", 175, startY, 900, 30)
				lg.setColor(i.textColor)
				lg.print(i.file:gsub(".sav", ""), Game.data.fonts.header, 185, startY + 3)
				startY = startY + 30
				lg.setColor(1,1,1)
			end
		end
	end
	if Game.data.gameState == 3 then
        if introVideo:isPlaying() then
			lg.scale( sw / introVideo:getWidth() , sh / introVideo:getHeight() )
            lg.draw(introVideo, 0, 0)
			lg.scale( introVideo:getWidth() / sw , introVideo:getHeight() / sh )
		else
			loadMap(true)
        end
    end
	if Game.data.gameState == 5 then
		if Game.data.mainMenuAudio:isPlaying() then Game.data.mainMenuAudio:stop() end
		if not Game.data.mapMusic or not Game.data.mapMusic:isPlaying() then 
			Game.data.mapMusic = la.newSource("data/audio/music/" .. Game.data.musicFiles[random(1,#Game.data.musicFiles)], "stream")
			Game.data.mapMusic:play()
		end
		if not Game.data.showBattle and not Game.data.showBattleAnimation then
			lg.draw(Game.data.canvas, Map.data.x, Map.data.y)
			Map:displayTiles(Game)
			Player:display(Game)
			lg.print(love.timer.getFPS())
			lg.print(Game.debugText,40,40)
			Game:GUI()
		end
		if Game.data.showOverlay then
			lg.setColor(0,0,0,.3)
			lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
			lg.setColor(1,1,1,1)
		end
		if not Game.data.showBattleAnimation and Game.data.showBattle then
			lg.draw(Game.data.battle.bgObj, 0, 0)
			if not Battle and allowBattle then
				Game:generateBattle()
				Battle = Game.data.battle
			end
			Game:showMonsters(Battle)
		elseif Game.data.showBattleAnimation then
			lg.draw(Game.data.snapshot, 0, 0)
			lg.setColor(Game.data.fadeColorBlack)
			lg.rectangle(unpack(Game.data.fadescreen))
			lg.setColor(1,1,1,1)
		end
		if Game.data.showAskRest then
			if not Game.data.askRestBG or type(Game.data.askRestBG) == "string" then Game.data.askRestBG = lg.newImage("data/img/restbg.png") end
			lg.draw(Game.data.askRestBG, 100, 320)
			if Game.data.restCost > 0 then
				lg.print("Would you like to pay " .. tostring(Game.data.restCost) .. " gold to rest here?", Game.data.fonts.fancy, 115, 340)
			else
				lg.print("Would you like to rest here?", Game.data.fonts.fancy, 115, 340)
			end
			Icons.restYes:display(Game)
			Icons.restNo:display(Game)
		end
		if Game.data.showRestScreen then
			lg.draw(Game.data.snapshot, 0, 0)
			lg.setColor(Game.data.fadeColorWhite)
			lg.rectangle(unpack(Game.data.fadescreen))
		end
	end
	if Game.data.wantsToQuit then
		lg.draw(BG.quitGameMenu, 200, 320)
		Icons.quitGameYes:display(Game)
		Icons.quitGameNo:display(Game)
	end
	
	if not Game.data.canMove then
		if Game.data.activeText ~= "" then 
			local heightAdd = 1
			for i in string.gfind(Game.data.activeText, "@@@") do heightAdd = heightAdd + 1 end
			local toPrint = string.gsub(tostring(Game.data.activeText), "@@@", "\n")
			local w,h = Game.data.fonts.text:getWidth(toPrint) * 0.85, (Game.data.fonts.text:getHeight(toPrint) + 4) * heightAdd
			local x = (800 / 2) - (w / 2)
			lg.setColor(0,0,0,.6)
			lg.rectangle("fill", x, 480 - (10 * heightAdd), w, h, 7, 7, 3)
			lg.setColor(1,1,1,1)
			lg.rectangle("line", x, 480 - (10 * heightAdd), w, h, 7, 7, 3)
			lg.print(toPrint, x + 7, 480 - (10 * heightAdd) + 10)
			if not Battle or (Battle and #Battle.monsters == 0) then
				lg.setColor(0,0,0,.6)
				lg.rectangle("fill", 350, 450 - (10 * heightAdd), 100, 30, 7, 7, 3)
				lg.setColor(1,1,1,1)
				lg.rectangle("line", 350, 450 - (10 * heightAdd), 100, 30, 7, 7, 3)
				lg.print("Press ESC", 365, 450 - (10 * heightAdd) + 10)
			end
		end
	end
	
	lg.setColor(1,1,1,1)
end




--[[
	Handles ALL mouseclick events
--]]
function love.mousepressed(x, y, button, istouch)
	if Game.data.loadMenu then
		local mx, my = lm.getPosition()
		local startY = 350
		for k,i in pairs(Game.data.saves) do
			if (mx >= 175 and mx <= 1075) and (my >= startY and my <= startY + 30) then
				Game.data.clickAudio:play()
				loadMap(false, nil, nil, nil, i.file)
				Game.data.loadMenu = nil
				break
			end
			startY = startY + 30
		end
	end
	if Game.data.lastActiveObj then
		local s = Game.data.lastActiveObj
		
		if string.match(s.img, "arrow") then
			if Game.data.clickAudio:isPlaying() then Game.data.clickAudio:stop() end
			Game.data.clickAudio:play()
			if string.match(s.img, "up") then
				if Game.data.newGameStatPointsLeft then
					local val = s.parent.value
					if val < 20 and Game.data.newGameStatPointsLeft > 0 then
						val = val + 1
						Game.data.newGameStatPointsLeft = Game.data.newGameStatPointsLeft - 1
					end
					s.parent.value = val
				end
			elseif string.match(s.img, "down") then
				if Game.data.newGameStatPointsLeft then
					local val = s.parent.value
					if val > 8 then
						val = val - 1
						Game.data.newGameStatPointsLeft = Game.data.newGameStatPointsLeft + 1
					end
					s.parent.value = val
				end
			end
		end
		
		if string.match(s.img, "quit") then
			Game.data.clickAudio:play()
			if string.match(s.img, "yes") then
				love.event.quit()
			elseif string.match(s.img, "no") then
				Game.data.wantsToQuit = false
			end
		end
		
		if string.match(s.img, "rest") then
			Game.data.clickAudio:play()
			if string.match(s.img, "yes") then
				Game.data.showAskRest = false
				Game.data.fadeColorWhite = {0,0,0,0}
				Rest()
			elseif string.match(s.img, "no") then
				Game.data.showAskRest = false
				Game.data.canMove = true
				Game.data.showOverlay = false
			end
		end
		
		if Game.data.quitGame[s.img] then
			Game.data.clickAudio:play()
			Game.data.wantsToQuit = true 
		end
	
		if Game.data.newGame[s.img] then
			Game.data.clickAudio:play()
			Game.data.curStep = "newGame"
			Game.data.gameState = 1
		end
		if Game.data.loadGame[s.img] then
			Game.data.clickAudio:play()
			Game.data.curStep = "loadGame"
			Game.data.gameState = 1
			Game.data.loadMenu = true
		end
		
		if Game.data.newGameClasses[s.img] then
			Game.data.clickAudio:play()
			if string.match(s.img, "stealth") then
				Game.data.newGameStep = 1
			elseif string.match(s.img, "melee") then
				Game.data.newGameStep = 2
			elseif string.match(s.img, "magic") then
				Game.data.newGameStep = 3
			end
		end
		
		if string.match(s.img, "continue") then
			Game.data.clickAudio:play()
			if Game.data.newGameStatPointsLeft and Game.data.newGameStatPointsLeft == 0 then
				Game.data.choosingNewGameName = true
			end
			if Game.data.newGameName and Game.data.newGameName ~= "" and not Game.data.showNewGameFinal then
				Game.data.showNewGameFinal = true
				Game.data.choosingNewGameName = false
			elseif Game.data.showNewGameFinal then
				Game.data.showNewGameFinal = false
                Game.data.gameState = 3
				if showIntro then introVideo:play() end
            end
		end
		
		if string.match(s.img, "startover") then
			Game.data.clickAudio:play()
			Game:reset()
		end
	end
	if Game.data.showBattle and not Game.data.showBattleAnimation then
		local count = #Game.data.battle.monsters
		local midRange = 416 - (32 * count - 1)
		local curPos = midRange - 32
		local curM = 1
		local mx,my = lm.getPosition()
		
		--for key, m in pairs(Game.data.battle.monsters) do
		while curM <= count do
			if curM <= 5 then
				if (mx >= curPos and mx <= curPos + 64) and (my >= 236 and my <= 300) then
					Game.data.battle:calcDamageToMonster(curM)
				end
			elseif curM <= 10 then
				if (mx >= curPos and mx <= curPos + 64) and (my >= 236 and my <= 300) then
					
				end
			elseif curM <= 15 then
				if (mx >= curPos and mx <= curPos + 64) and (my >= 236 and my <= 300) then
					
				end
			else
				if (mx >= curPos and mx <= curPos + 64) and (my >= 236 and my <= 300) then
					
				end
			end
			curPos = curPos + 71
			curM = curM + 1
		end
	end
end

--[[

	HELPER FUNCTIONS

--]]

--[[
	Display menu sequence for starting a new game
--]]
function displayNewGame(c)
	if c then
		local choice
		if c == 1 then
			choice = "stealth" 
		elseif c == 2 then
			choice = "melee"
		elseif c == 3 then
			choice = "magic"
		else
			Game:reset()
			return false
		end
		local sP = {470, 350, 765, 350, 470, 325}
		local sP2 = {800, 350, 1100, 350, 800, 325}
		if choice and not Game.data.showNewGameFinal then
			lg.draw(BG.newGameBG2, 140, 220)
			if not Game.data.choosingNewGameName then
				Icons.newGameChoice = Icon("data/img/" .. choice .. "default.png", nil, nil, 180, 325, 0,0,0,0)
				Icons.newGameChoice.active = false
				Game.data.newGameChoice = choice
				Icons.newGameChoice:display(Game)
				local stats = {STRENGTH = "STRENGTH", INTELLECT = "INTELLECT", PERCEPTION = "PERCEPTION", ENDURANCE = "ENDURANCE", ACCURACY = "ACCURACY", AGILITY = "AGILITY", SPEED = "SPEED", LUCK = "LUCK"}
				
				local cnt = 1
				for key,index in pairsByKeys(stats) do
					local using = sP
					
					if cnt > 4 then
						using = sP2
					end
					
					using[2] = using[2] + 41
					using[4] = using[4] + 41
					using[6] = using[6] + 41
					
					if not Game.data.newGameStats[index] then 
						local stat = {}
						stat.name = index
						stat.upArrow = Icon("data/img/uparrowdefault.png", "data/img/uparrowactive.png", "data/img/uparrowdisabled.png", using[1]+200, using[2] - 42, 3, 30, 3, 38, stat)
						stat.downArrow = Icon("data/img/downarrowdefault.png", "data/img/downarrowactive.png", "data/img/downarrowdisabled.png", using[1]+265, using[2] - 42, 3, 30, 3, 38, stat)
						stat.value = 10
						Game.data.newGameStats[index] = stat
					end
					
					lg.setColor(25,25,25,.5)
					lg.line(using[1], using[2], using[3], using[4])
					
					lg.setColor(200,200,200,1)
					lg.print(index, Game.data.fonts.header, using[5], using[6])
					
					Game.data.newGameStats[index].upArrow:display(Game)
					if Game.data.newGameStats[index].value == 20 then
						lg.print(Game.data.newGameStats[index].value, Game.data.fonts.header, using[1]+230,using[2]-30)
					else 
						lg.print(Game.data.newGameStats[index].value, Game.data.fonts.header, using[1]+237,using[2]-30)
					end
					Game.data.newGameStats[index].downArrow:display(Game)
					cnt = cnt + 1
				end
				Icons.startGameContinue:display(Game)
				lg.print("Points Remaining: " .. Game.data.newGameStatPointsLeft, Game.data.fonts.header, 760, 590)
			else
				lg.setColor(25,25,25,.5)
				lg.line(250, 380, 1025, 380)
				lg.setColor(200,200,200,1)
				lg.print("Enter Your Name:", Game.data.fonts.header, 250, 350)
				lg.print(Game.data.newGameName, Game.data.fonts.header, 580, 350)
				Icons.startGameContinue.x = 250
				Icons.startGameContinue.y = 400
				Icons.startGameContinue:display(Game)
			end
		else
			sP[2], sP[4], sP[6] = sP[2] + 40, sP[4] + 40, sP[6] + 40
			sP2[2], sP2[4], sP2[6] = sP2[2] + 40, sP2[4] + 40, sP2[6] + 40
			lg.draw(BG.newGameBG3, 140, 220)
			Icons.newGameChoice:display(Game)
			local cnt = 1
			for key,index in pairsByKeys(Game.data.newGameStats) do
				local using = sP
				
				if cnt > 4 then
					using = sP2
				end
				
				using[2] = using[2] + 41
				using[4] = using[4] + 41
				using[6] = using[6] + 41
				
				lg.setColor(25,25,25,.5)
				lg.line(using[1], using[2], using[3], using[4])
				
				lg.setColor(200,200,200,1)
				lg.print(index.name, Game.data.fonts.header, using[1], using[6])
				
				lg.setColor(25,25,25,.5)
				lg.line(using[1], 376, 850, 376)
				
				lg.setColor(200,200,200,1)
				if Game.data.newGameStats[key].value == 20 then
					lg.print(Game.data.newGameStats[key].value, Game.data.fonts.header, using[1]+230,using[2]-30)
				else 
					lg.print(Game.data.newGameStats[key].value, Game.data.fonts.header, using[1]+232,using[2]-30)
				end
				cnt = cnt + 1
			end
			lg.print(Game.data.newGameName, Game.data.fonts.header, sP[1], 350)
			Icons.startGameContinue.x = sP[1] - 10
			Icons.startGameContinue.y = 565
			Icons.startGameContinue:display(Game)
			Icons.startGameOver.x = Icons.startGameContinue.x + 320
			Icons.startGameOver:display(Game)
		end
	end
end

--[[
	Starts new game, loads game, or changes map
--]]
function loadMap(newGame, map, startX, startY, file, tile, id)
	--if Game.data.mainMenuAudio:isPlaying() then Game.data.mainMenuAudio:stop() end
	love.window.setMode(800,600)
	tile = tile and tile or 1450
	if newGame then
		startX = 1700
		startY = 1500
		map = "data/img/cherrichills.png"
		Game.data.Map = M(Game, map, -startX, -startY, 1) 
		Map = Game.data.Map
		Map:generateTiles()
		Map:setTiles()
		Map:resetImage()
		Game.data.Player = P(Game, Game.data.newGameChoice,Game.data.newGameStats,Game.data.newGameName, 350, 300, 2386)
		Player = Game.data.Player
		Game:setSelf()
	elseif not newGame and file then
		file = file and file or "snowhelm001.save"
		local loadData = lf.load(file)
		local index = 1
		loadData = loadData()
		loadData = loadData.Data
		
		local data = {}
		
		data.Map = loadData.map
		data.Player = loadData.player
		data.Tiles = loadData.tiles
		
		Game.data.Map = M(Game, data.Map.name, data.Map.x, data.Map.y, data.Player.tile, data.Map.id)
		Map = Game.data.Map
		Map:generateTiles()
		Map:setTiles()
		Map:resetImage()
		
		for key, value in pairs(data.Tiles) do
			if value.img and value.img.imgType == "chestopen" then
				Map.data.tiles[value.id].event = nil
			end
			for k, v in pairs(value) do
				Map.data.tiles[value.id][k] = v
			end
			if value.img then
				Map.data.tiles[value.id].img.imgObj = lg.newImage("data/img/" .. value.img.imgType .. ".png")
			end
		end
		
		Game.data.Player = P(Game, data.Player.class, data.Player.stats, data.Player.x, data.Player.y, data.Player.tile)
		Player = Game.data.Player
		Player.data = data.Player
		Player.data.img = lg.newImage("data/img/player.png")
		Game.data.curStep = nil
		Game:setSelf()
	else
		Game.data.Map = M(Game, map, startX, startY, id)
		Map = Game.data.Map
	end
	Game.data.canvas = lg.newCanvas(5000,3600)
	lg.setCanvas(Game.data.canvas)
		lg.draw(Map.data.printed, Map.data.obj, 0, 0)
	lg.setCanvas()
	Game.data.canMove = true
	Game.data.gameState = 5
end