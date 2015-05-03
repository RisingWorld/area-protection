-- Includes
include("listener/playerListener.lua");
include("listener/commandListener.lua");

-- Global variables
database = getDatabase();
server = getServer();
world = getWorld();
properties = getProperty("config.properties");
areas = {};
chests = {};
groups = {};
defaultGroup = nil;
areaLoaded = false;
groupLoaded = false;

-- Some color definitions
colors = {0xFFFF00AA, 0xAA00AAAA, 0x1111FFAA, 0xCCCCDDAA, 0x34DD54AA, 0xFF5555AA};

--- Script enable event.
-- This event is triggered when the script is loaded.
-- From this point on, the script gets notified about
-- all events and is able to call serverside functions.
function onEnable()
	print("AREA PROTECTION script started!");
	
	-- Create database tables "areas" and "rights" if they don't exist already
	database:queryupdate("CREATE TABLE IF NOT EXISTS 'areas' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , 'name' VARCHAR, 'startChunkpositionX' INTEGER, 'startChunkpositionY' INTEGER, 'startChunkpositionZ' INTEGER, 'startBlockpositionX' INTEGER, 'startBlockpositionY' INTEGER, 'startBlockpositionZ' INTEGER,'endChunkpositionX' INTEGER, 'endChunkpositionY' INTEGER, 'endChunkpositionZ' INTEGER, 'endBlockpositionX' INTEGER, 'endBlockpositionY' INTEGER, 'endBlockpositionZ' INTEGER, 'playerID' INTEGER);");
	database:queryupdate("CREATE TABLE IF NOT EXISTS 'rights' ('ID' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , 'areaID' INTEGER, 'playerID' INTEGER, 'group' VARCHAR);");
	database:queryupdate("CREATE TABLE IF NOT EXISTS 'chests' ('ID' INTEGER , 'chunkOffsetX' INTEGER, 'chunkOffsetY' INTEGER, 'chunkOffsetZ' INTEGER, 'positionX' INTEGER, 'positionY' INTEGER, 'positionZ' INTEGER);");
	-- Load all groups from property-files
	loadGroups();
	
	-- Receive all saved areas from database and store them in a global table
	local result = database:query("SELECT * FROM areas;");
	while result:next() do
		local area = {};
		area["areaID"] = result:getInt("ID"); 
		area["playerID"] = result:getInt("playerID");
		area["areaName"] = result:getString("name");
		area["startChunkpositionX"] = result:getInt("startChunkpositionX");
		area["startChunkpositionY"] = result:getInt("startChunkpositionY");
		area["startChunkpositionZ"] = result:getInt("startChunkpositionZ");
		area["startBlockpositionX"] = result:getInt("startBlockpositionX");
		area["startBlockpositionY"] = result:getInt("startBlockpositionY");
		area["startBlockpositionZ"] = result:getInt("startBlockpositionZ");
		
		area["endChunkpositionX"] = result:getInt("endChunkpositionX");
		area["endChunkpositionY"] = result:getInt("endChunkpositionY");
		area["endChunkpositionZ"] = result:getInt("endChunkpositionZ");
		area["endBlockpositionX"] = result:getInt("endBlockpositionX");
		area["endBlockpositionY"] = result:getInt("endBlockpositionY");
		area["endBlockpositionZ"] = result:getInt("endBlockpositionZ");
		
		area["rights"] = {};
		
		calculateGlobalAreaPosition(area);	
		areas[result:getInt("ID")] = area;
		--table.insert(areas, result:getInt("ID"), area);
	end
	
	-- Receive all saved chests from database and store them in a global table
	local result = database:query("SELECT * FROM chests;");
	while result:next() do
		local chest = {};
		chest["chunkOffsetX"] = result:getInt("chunkOffsetX");
		chest["chunkOffsetY"] = result:getInt("chunkOffsetY");
		chest["chunkOffsetZ"] = result:getInt("chunkOffsetZ");
		chest["positionX"] = result:getFloat("positionX");
		chest["positionY"] = result:getFloat("positionY");
		chest["positionZ"] = result:getFloat("positionZ");
		
		chests[result:getInt("ID")] = chest;
		print("Load Chest ID:" .. result:getInt("ID"));
	end
	
	-- Iterate the table "areas" and assign all related grouprights
	for key,value in pairs(areas) do
		result = database:query("SELECT * FROM rights WHERE areaID='".. value["areaID"] .. "';");
		while result:next() do
			local group = getGroupByName(result:getString("Group"));
			if group ~= nil then
				value["rights"][result:getInt("playerID")] = group;
			end
		end
		print("Loaded area \"".. value["areaName"] .."\" successfully");
	end
	
	-- Set a flag indicating that all areas are loaded
	areaLoaded = true;
end

--- Script disable event.
-- This event is triggered when the script is unloaded
-- which causes the script to stop.
function onDisable()
	print("AREA PROTECTION script stopped!");
end

--- Update tick event (frequently called event!)
-- This event is triggered every tick. Use this event
-- to update your script environment, as long as it requires frequent updates.
-- @param event The update event object
-- You can get the current tpf (event:getTpf()) or runningtime from it
function onUpdate(event)
	--print(server:getGameTimestamp());
	--print("TPF:" .. event:getTpf());
	--print("RUNNINGTIME:" .. event:getRunningTime());
end
addEvent("Update", onUpdate);

----------------------------------------------------------

--- Custom function to load all groups from a property-file. 
-- This function is also used to reload all groups
-- (useful when changing the files during runtime).
function loadGroups()
	groupLoaded = false;
	groups = {};
	local groupDir = properties:getProperty("GroupDir");
	local defaultGroupProperty = properties:getProperty("DefaultGroup");
	local groupFiles = StringUtils:explode(properties:getProperty("Groups"), ",");
	for i = 1, #groupFiles, 1 do
		local groupProperty = getProperty(groupDir .. "/" .. groupFiles[i]);
		local group = {};
		group["name"] = groupProperty:getProperty("GroupName");
		group["PlaceObjects"] = StringUtils:getBoolean(groupProperty:getProperty("PlaceObjects"));
		group["DestroyObjects"] = StringUtils:getBoolean(groupProperty:getProperty("DestroyObjects"));
		group["RemoveObjects"] = StringUtils:getBoolean(groupProperty:getProperty("RemoveObjects"));
		group["PickupObject"] = StringUtils:getBoolean(groupProperty:getProperty("PickupObject"));	
		group["ChangeObjectStatus"] = StringUtils:getBoolean(groupProperty:getProperty("ChangeObjectStatus"));
		group["PlaceConstructions"] = StringUtils:getBoolean(groupProperty:getProperty("PlaceConstructions"));
		group["DestroyConstructions"] = StringUtils:getBoolean(groupProperty:getProperty("DestroyConstructions"));
		group["RemoveConstructions"] = StringUtils:getBoolean(groupProperty:getProperty("RemoveConstructions"));
		group["PlaceBlock"] = StringUtils:getBoolean(groupProperty:getProperty("PlaceBlock"));
		group["DestroyBlock"] = StringUtils:getBoolean(groupProperty:getProperty("DestroyBlock"));
		group["DestroyWorld"] = StringUtils:getBoolean(groupProperty:getProperty("DestroyWorld"));
		group["FillWorld"] = StringUtils:getBoolean(groupProperty:getProperty("FillWorld"));
		group["CanEnter"] = StringUtils:getBoolean(groupProperty:getProperty("CanEnter"));
		group["CanLeave"] = StringUtils:getBoolean(groupProperty:getProperty("CanLeave"));
		group["InventoryToChest"] = StringUtils:getBoolean(groupProperty:getProperty("InventoryToChest"));
		group["ChestToInventory"] = StringUtils:getBoolean(groupProperty:getProperty("ChestToInventory"));
		group["ChestDrop"] = StringUtils:getBoolean(groupProperty:getProperty("ChestDrop"));
		group["RemoveVegetation"] = StringUtils:getBoolean(groupProperty:getProperty("RemoveVegetation"));
		group["PlaceVegetation"] = StringUtils:getBoolean(groupProperty:getProperty("PlaceVegetation"));
		group["CutGrass"] = StringUtils:getBoolean(groupProperty:getProperty("CutGrass"));
		group["PickupVegetation"] = StringUtils:getBoolean(groupProperty:getProperty("PickupVegetation"));
		
		--Load different filters (for example to determine which blocks are affected by any rules etc.)
		group["ObjectsPlaceFilter"] = StringUtils:explode(groupProperty:getProperty("ObjectsPlaceFilter"), ",");
		group["ObjectsRemoveDestroyFilter"] = StringUtils:explode(groupProperty:getProperty("ObjectsRemoveDestroyFilter"), ",");
		group["ConstructionsFilter"] = StringUtils:explode(groupProperty:getProperty("ConstructionsFilter"), ",");
		group["BlockFilter"] = StringUtils:explode(groupProperty:getProperty("BlockFilter"), ",");
		
		--Insert the group into the global groups table
		table.insert(groups, group);
		if group["name"] == defaultGroupProperty then
			defaultGroup = group;
			print("Default Group found \""..defaultGroup["name"].."\"");
		end
		print("Loaded group:\"".. group["name"] .. "\" successfully");
	end
	groupLoaded = true;
end

--- Returns the group according to a groupname.
-- @param name The name of the group
-- @return The group according to the provided groupname, 
-- or nil if no group was found
function getGroupByName(name)
	for i = 1, #groups, 1 do
		if groups[i]["name"] == name then
			return groups[i];
		end
	end
	return nil;
end

--- Returns the player group of a specified area.
-- @param player The player object
-- @param area The area object
-- @return The group of the player in the specified area
function getPlayerGroupInArea(player, area)
	local group = area["rights"][player:getDBID()];
	if group == nil then
		group = defaultGroup;
	end
	return group;	
end

--- Adjusts the position values of an area.
-- I.e. the start- and endposition will be swapped, if the
-- endposition is smaller than the startposition.
-- @param area The area object
function adjustAreaPositions(area)
	local sx = ChunkUtils:getGlobalBlockPositionX(area["startChunkpositionX"], area["startBlockpositionX"]);
	local sy = ChunkUtils:getGlobalBlockPositionY(area["startChunkpositionY"], area["startBlockpositionY"]);
	local sz = ChunkUtils:getGlobalBlockPositionZ(area["startChunkpositionZ"], area["startBlockpositionZ"]);
	local ex = ChunkUtils:getGlobalBlockPositionX(area["endChunkpositionX"], area["endBlockpositionX"]);
	local ey = ChunkUtils:getGlobalBlockPositionY(area["endChunkpositionY"], area["endBlockpositionY"]);
	local ez = ChunkUtils:getGlobalBlockPositionZ(area["endChunkpositionZ"], area["endBlockpositionZ"]);
	if sx > ex then
		local t = area["startChunkpositionX"];
		area["startChunkpositionX"] = area["endChunkpositionX"];
		area["endChunkpositionX"] = t;
		t = area["startBlockpositionX"];
		area["startBlockpositionX"] = area["endBlockpositionX"];
		area["endBlockpositionX"] = t;
	end
	if sy > ey then
		local t = area["startChunkpositionY"];
		area["startChunkpositionY"] = area["endChunkpositionY"];
		area["endChunkpositionY"] = t;
		t = area["startBlockpositionY"];
		area["startBlockpositionY"] = area["endBlockpositionY"];
		area["endBlockpositionY"] = t;
	end
	if sz > ez then
		local t = area["startChunkpositionZ"];
		area["startChunkpositionZ"] = area["endChunkpositionZ"];
		area["endChunkpositionZ"] = t;
		t = area["startBlockpositionZ"];
		area["startBlockpositionZ"] = area["endBlockpositionZ"];
		area["endBlockpositionZ"] = t;
	end
end

--- Calculates the "global" start- and endposition of an area.
-- @param area The area object
function calculateGlobalAreaPosition(area)
	area["globalStartPositionX"] = ChunkUtils:getGlobalBlockPositionX(area["startChunkpositionX"], area["startBlockpositionX"]);
	area["globalStartPositionY"] = ChunkUtils:getGlobalBlockPositionY(area["startChunkpositionY"], area["startBlockpositionY"]);
	area["globalStartPositionZ"] = ChunkUtils:getGlobalBlockPositionZ(area["startChunkpositionZ"], area["startBlockpositionZ"]);
	area["globalEndPositionX"] = ChunkUtils:getGlobalBlockPositionX(area["endChunkpositionX"], area["endBlockpositionX"]);
	area["globalEndPositionY"] = ChunkUtils:getGlobalBlockPositionY(area["endChunkpositionY"], area["endBlockpositionY"]);
	area["globalEndPositionZ"] = ChunkUtils:getGlobalBlockPositionZ(area["endChunkpositionZ"], area["endBlockpositionZ"]);
end

--- Returns the area at the provided position.
-- @param chunkoffsetx The X offset position of the chunk
-- @param chunkoffsety The Y offset position of the chunk
-- @param chunkoffsetz The Z offset position of the chunk
-- @param blockpositionx The X blockposition within the chunk
-- @param blockpositiony The Y blockposition within the chunk
-- @param blockpositionz The Z blockposition within the chunk
-- @return The area at the provided position, or nil if no area was found
function getCurrentArea(chunkoffsetx, chunkoffsety, chunkoffsetz, blockpositionx, blockpositiony, blockpositionz)
	local area = nil;
	for key,value in pairs(areas) do
		if AreaUtils:isPointInArea3D(chunkoffsetx, chunkoffsety, chunkoffsetz, blockpositionx, blockpositiony, blockpositionz, value["startChunkpositionX"], value["startChunkpositionY"], value["startChunkpositionZ"], value["startBlockpositionX"], value["startBlockpositionY"], value["startBlockpositionZ"], value["endChunkpositionX"], value["endChunkpositionY"], value["endChunkpositionZ"], value["endBlockpositionX"], value["endBlockpositionY"], value["endBlockpositionZ"]) then
			if area == nil then
				area = value;
			else
				if value["globalStartPositionX"] >= area["globalStartPositionX"] and value["globalStartPositionY"] >= area["globalStartPositionY"] and value["globalStartPositionZ"] >= area["globalStartPositionZ"] and value["globalEndPositionX"] <= area["globalEndPositionX"] and value["globalEndPositionY"] <= area["globalEndPositionY"] and value["globalEndPositionZ"] <= area["globalEndPositionZ"] then
					area = value;
				end
			end
		end
	end
	return area;
end

----------------------------------------------------------

--- Used to find out if the provided table
-- contains the specified value.
-- @param tab The table
-- @param value The value you're looking for
-- @return True if the value exists in the table, false if not
function tableContains(tab, value)
	for i = 1, #tab, 1 do
		if tab[i] == value then
			return true;
		end
	end
	return false;
end

--- Used to remove a value from the provided table.
-- @param tab The table
-- @param value The value you want to remove
function tableRemove(tab, value)
	for i = 1, #tab, 1 do
		if tab[i] == value then
			table.remove(tab, i);
		end
	end
end