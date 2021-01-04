local data = {
	[866] = {
		img = "signpost",
		event = function(f) f:Info(3) end
	},
	[1805] = {
		canWalk = false
	},
	[1806] = {
		canWalk = false
	},
	[1807] = {
		canWalk = false
	},
	[1808] = {
		img = "chest",
		event = function(f) 
			f:Chest(
				0,
				{
					{0,0},			-- {ITEMID, AMOUNT}
				},
				75,
				1808
			)
		end
	},
	[1889] = {
		canWalk = false
	},
	[1890] = {
		canWalk = false
	},
	[1891] = {
		canWalk = false
	},
	[1892] = {
		canWalk = false
	},
	[1973] = {
		canWalk = false
	},
	[1974] = {
		canWalk = false
	},
	[1975] = {
		canWalk = false
	},
	[1976] = {
		canWalk = false
	},
	[2028] = {
		img = "signpost",
		event = function(f) f:Info(2) end
	},
	[2057] = {
		canWalk = false
	},
	[2058] = {
		canWalk = false
	},
	[2059] = {
		canWalk = false
	},
	[2060] = {
		canWalk = false,
		event = function(f) f:askRest(5, true) end,
	},
	[2123] = {
		img = "chest",
		event = function(f) 
			f:Chest(
				0,
				{
					{0,0}
				},
				100,
				2123
			)
		end
	},
	[2133] = {
		img = "chest",
		event = function(f) 
			f:Chest(
				0,					-- Quality
				{
					{0,0},
					{0,0},
					{0,0},			-- {ITEMID, AMOUNT}
					{1,1}			-- Grants bomb for destroying rock
				},
				75,					-- Gold
				2133				-- Block ID
			)
		end
	},
	[2218] = {
		canWalk = false
	},
	[2225] = {
		canWalk = false
	},
	[2302] = {
		event = function(f) f:askRest(0, true) end
	},
	[2305] = {
		img = "signpost",
		event = function(f) f:Info(1) end,
	},
	[2308] = {
		canWalk = false
	},
	[2309] = {
		canWalk = false
	},
	[2325] = {
		canWalk = false
	},
	[2393] = {
		event = function(f) f:Speak(1) end
	},
	[2558] = {
		img = "chest",
		event = function(f) 
			f:Chest(
				0,
				{
					{0,0},
					{0,0},
					{0,0}
				},
				300,
				2558
			)
		end
	},
	[2595] = {
		img = "signpost",
		event = function(f) f:Info(4) end
	},
	[3859] = {
		img = "chest",
		event = function(f) 
			f:Chest(
				0,
				{
					{5,1},
					{6,1},
					{0,0},
					{0,0}
				},
				800,
				3859
			)
		end
	},
	[4178] = {
		img = "signpost",
		event = function(f) f:Info(5) end
	}
}

local ranges = {
	["tree"] = {{85,108},{253,276},{421,444},{589,612},{637,672},{757,780},{805,840},{973,1008},{1009,1032},{1170,1176},{1118,1125},{1141,1154},{1286,1293},{1309,1322},{1338,1344},{1422,1428},{1506,1512},{1674,1688},{1719,1726},{1773,1785},{1793,1801},1811,{1842,1848},1856,1887,1888,1896,{1961,1969},1981,{2010,2016},2039,2055,2056,2108,2124,{2129,2132},{2178,2184},{2269,2278},{2280,2289},{2291,2301},{2346,2352},{2514,2520},{2541,2553},{2565,2569},2303,2304,2559,{2766,2772},2886,{2934,2940},2974,3063,{3102,3108},{3118,3134},3228,3232,{3270,3276},{3285,3302},{3315,3318},{3438,3444},{3450,3470},{3606,3612},{3613,3638},{3774,3780},{3781,3806},{3944,3948},{4110,4116}},
	["smallrock"] = {2279,2470,3858,4326,4427,4585,4609,4651,{4682,4685}},
	["shrub"] = {2109,{2134,2137}, 2221, 2373, 2392, 2473, 2474, 2476,{2560, 2564},{2639,2643},{4008,4015}},
	["log"] = {1858,2116,2472,2964,3943},
	["stump"] = {}
}

for objType, tiles in pairs(ranges) do
	for key, index in pairs(tiles) do
		if type(index) == "table" then
			local low = index[1]
			local high = index[2]
			while low <= high do
				if not data[low] then data[low] = {} end
				if objType == "tree" then 
					data[low - 84] = data[low - 84] or {}
					data[low].img = objType .. "bottom"
					data[low - 84].img = objType .. "top"
					data[low - 84].canWalk = false
					data[low].canWalk = false
				elseif objType == "log" then
					data[index - 1] = data[index - 1] or {}
					data[index].img = "tree" .. objType .. "right"
					data[index - 1].img = "tree" .. objType .. "left"
					data[index].canWalk = false
					data[index - 1].canWalk = false
				else
					data[low].img = objType
				end
				
				data[low].canWalk = false
				low = low + 1
			end
		else
			if not data[index] then data[index] = {} end
			if objType == "tree" then
				data[index - 84] = data[index - 84] or {}
				data[index].img = objType .. "bottom"
				data[index - 84].img = objType .. "top"
				data[index - 84].canWalk = false
				data[index].canWalk = false
			elseif objType == "log" then
				data[index - 1] = data[index - 1] or {}
				data[index].img = "tree" .. objType .. "right"
				data[index - 1].img = "tree" .. objType .. "left"
				data[index].canWalk = false
				data[index - 1].canWalk = false
			else
				data[index].img = objType
			end
			
			data[index].canWalk = false
		end
	end
end

local towns = {
	{1625, 18, 15}
}

for key, town in ipairs(towns) do
	local y = 1
	local block = town[1]
	while y <= town[3] do
		local x = 0
		while x < town[2] do
			data[block] = data[block] or {}
			data[block].inTown = true
			block = block + 1
			x = x + 1
		end
		block = town[1] + (y * 84)
		y = y + 1
	end
end

local water = {
	{1093,1097},{1177,1181},{1261,1264},{1412,1414},{1495,1500},{1578,1584},{1660,1669},{1743,1753},{1826,1837},{1907,1921},{1988,2005},{2066,2089},{2150,2173},{2233,2257},{2317,2341},{2401,2425},{2485,2509},{2569,2593},{2654,2677},{2737,2762},{2821,2846},{2905,2930},{2989,3014},{3073,3098},{3158,3182},{3243,3266},{3328,3351},{3413,3434},{3500,3518},{3583,3602},{3669,3685},{3754,3769},{3840,3851},{3925,3933}
}

for key, val in ipairs(water) do
	if type(val) == "table" then
		local low = val[1]
		local high = val[2]
		while low <= high do
			data[low] = data[low] or {}
			data[low].canWalk = false
			low = low + 1
		end
	else
		data[key] = data[key] or {}
		data[key].canWalk = false
	end
end

return data