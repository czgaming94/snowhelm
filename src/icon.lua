local min, max, ceil, floor, random = math.min, math.max, math.ceil, math.floor, love.math.random
local ld, lf, lg, lm, lv = love.data, love.filesystem, love.graphics, love.mouse, love.video
local class = require("src.class")
local Icon = class()
local Game, Map, Player, Battle, Monster
--[[


---------------------------------------------------------------------------------------------------------
						ICON
---------------------------------------------------------------------------------------------------------


--]]

--[[
	Game.data.icons.newIcon = Icon("data/img/iconImage.png", "data/img/iconActive.png", "data/img/iconDisabled.png", 50, 100, 5, 65, 5, 150)
	-- for icon
	Game.data.backgrounds.bg = lg.newImage("data/img/background.png")
	-- for fast background
--]]

function Icon:init(img,imgActive,imgDisabled,x,y,hoverStartX,hoverEndX,hoverStartY,hoverEndY,parent)
	self.img = img or "default.png"
	self.imgDefault = img or "defualt.png"
	self.imgActive = imgActive or nil
	self.imgDisabled = imgDisabled or nil
	self.imgObj = lg.newImage(img) or lg.newImage("defualt.png")
	self.x = x or 0
	self.y = y or 0
	self.hoverStartX = hoverStartX or 0
	self.hoverStartY = hoverStartY or 0
	self.hoverEndX = hoverEndX or 0
	self.hoverEndY = hoverEndY or 0
	self.parent = parent or nil
	self.active = true
	self.generated = {}
end

--[[
	Finds proper image for self and displays
--]]
function Icon:display(Game)
	--print(29)
	local curActive
	
	if string.match(self.img, "continue") then
		if Game.data.newGameStatPointsLeft and Game.data.newGameStatPointsLeft == 0 then
			self.active = true
		end
	end
	if self.active then
		curActive = self.imgDefault
		if Game.data.loadGame[self.img] then
			if #Game.data.saves < 1 then
				curActive = self.imgDisabled
				goto checkSkip 
			else
				curActive = self.imgDefault
			end
		end
		if string.match(self.img, "continue") then
			if (Game.data.newGameName and Game.data.newGameName ~= "") then
				Game.data.newGameStatPointsLeft = nil
				curActive = self.imgDefault
			else
				if (not Game.data.newGameName or Game.data.newGameName == "")  and (Game.data.newGameStatPointsLeft and Game.data.newGameStatPointsLeft == 0) then
					curActive = self.imgDefault
				elseif (Game.data.newGameStatPointsLeft and Game.data.newGameStatPointsLeft > 0) then
					if Game.data.newGameStatPointsLeft then
						curActive = self.imgDisabled
						goto checkSkip
					end
				end
				if (not Game.data.newGameName or Game.data.newGameName == "") and Game.data.choosingNewGameName then
					curActive = self.imgDisabled
					goto checkSkip
				end
			end
		end
		if self:hovered(Game) then
			Game.data.lastActiveObj = self
			curActive = self.imgActive 
		end
		
		::checkSkip::
		self.img = curActive
	end
	if not self.generated[self.img] then
		self.imgObj = lg.newImage(self.img)
		self.generated[self.img] = self.imgObj
	else 
		self.imgObj = self.generated[self.img]
	end
	
	lg.draw(self.imgObj, self.x, self.y)
	return self.imgObj
end

--[[
	True -- Mouse is over icon
	False -- Mouse is not over icon
--]]
function Icon:hovered(Game)
	local x,y = lm.getPosition()
	if Game.data.lastActiveObj == self then Game.data.lastActiveObj = nil end
	return (x >= (self.x + self.hoverStartX) and x < (self.x + self.hoverEndX)) and (y >= (self.y + self.hoverStartY) and y < (self.y + self.hoverEndY))
end


return Icon