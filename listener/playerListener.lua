
--- Player connect event.
-- This event is triggered when a player connects to the server. Note that the
-- player is currently in the loadingscreen at the moment this event is triggered,
-- so it's useless to display anything on the players screen.
-- @param event The event object. Cancel the event to prevent the player to connect
function onPlayerConnect(event)
	local label = Gui:createLabel("", 0.05, 0.135);
	label:setFontsize(19);
	event.player:setAttribute("areas", {});
	event.player:setAttribute("areasVisible", false);
	event.player:setAttribute("areaLabel", label);
	event.player:addGuiElement(label);
end
addEvent("PlayerConnect", onPlayerConnect);

--- Player spawn event.
-- This event is triggered when a player spawns the first (!) time. It is triggered
-- after the loadingscreen of the player disappears, so this is the right moment to
-- display some information on the player screen for example.
-- @param event The event object
function onPlayerSpawn(event)
	-- Creates a new GUI element (label) displaying the servername on the player's screen
	local label = Gui:createLabel("Welcome to ".. server:getServerName(), 0.98, 0.135);
	label:setFontColor(0x0066FFFF);
	label:setFontsize(26);
	label:setPivot(1);
	event.player:addGuiElement(label);
	-- Creates a new timer which triggers the provided function after the given amount of time
	setTimer(function()
		event.player:removeGuiElement(label);
		Gui:destroyElement(label);
	end, 5, 1);
end
addEvent("PlayerSpawn", onPlayerSpawn);

--- Player change position event (frequently called event!)
-- This event is called everytime the player changes his position.
-- @param event The event object. Cancel the event to teleport the player back to his old position
function onPlayerChangePosition(event)
	if areaLoaded ~= true or groupLoaded ~= true then 
		return; 
	end
	
	local areaID = event.player:getAttribute("areaID");
	local playerAreas = event.player:getAttribute("areas");
	if areaID ~= nil then
		if areas[areaID] == nil then
			event.player:setAttribute("areaID", nil);
			return;
		end
		
		if AreaUtils:isPointInArea3D(event.player:getPosition(), areas[areaID]["startChunkpositionX"], areas[areaID]["startChunkpositionY"], areas[areaID]["startChunkpositionZ"], areas[areaID]["startBlockpositionX"], areas[areaID]["startBlockpositionY"], areas[areaID]["startBlockpositionZ"], areas[areaID]["endChunkpositionX"], areas[areaID]["endChunkpositionY"], areas[areaID]["endChunkpositionZ"], areas[areaID]["endBlockpositionX"], areas[areaID]["endBlockpositionY"], areas[areaID]["endBlockpositionZ"]) == false	then
			local group = event.player:getAttribute("areaGroup");
			if group["CanLeave"] == false then
				event:setCancel(true);
			else
				tableRemove(playerAreas, areaID);
				--event.player:sendYellMessage("LEAVE AREA " .. areas[areaID]["areaName"]);
				local label = event.player:getAttribute("areaLabel");
				local stop = false;
				while stop ~= true do
					if #playerAreas ~= 0 then
						if areas[playerAreas[#playerAreas]] ~= nil then
							event.player:setAttribute("areaID", playerAreas[#playerAreas]);
							local group = areas[playerAreas[#playerAreas]]["rights"][event.player:getDBID()];
							if group == nil then
								group = defaultGroup;
							end
							event.player:setAttribute("areaGroup", group);
							label:setText(areas[playerAreas[#playerAreas]]["areaName"]);
							stop = true;
						else
							table.remove(playerAreas);
						end
					else
						event.player:setAttribute("areaID", nil);
						event.player:setAttribute("areaGroup", nil);
						label:setVisible(false);
						stop = true;
					end
				end
			end
		else
			local group = areas[areaID]["rights"][event.player:getDBID()];
			if group == nil then
				group = defaultGroup;
			end
			event.player:setAttribute("areaGroup", group);	
		end	
	end
	for key,value in pairs(areas) do
		if AreaUtils:isPointInArea3D(event.player:getPosition(), value["startChunkpositionX"], value["startChunkpositionY"], value["startChunkpositionZ"], value["startBlockpositionX"], value["startBlockpositionY"], value["startBlockpositionZ"], value["endChunkpositionX"], value["endChunkpositionY"], value["endChunkpositionZ"], value["endBlockpositionX"], value["endBlockpositionY"], value["endBlockpositionZ"]) then
			local group = value["rights"][event.player:getDBID()];
			if group == nil then
				group = defaultGroup;
			end
			
			if group["CanEnter"] == false then
				event:setCancel(true);
				return;
			else
				if tableContains(playerAreas, key) == false then
					--event.player:sendYellMessage("ENTER AREA " .. value["areaName"]);
					local label = event.player:getAttribute("areaLabel");
					label:setText(value["areaName"]);
					label:setVisible(true);
					event.player:setAttribute("areaGroup", group);
					event.player:setAttribute("areaID", key);
					table.insert(playerAreas, key);
				end
			end
		end
	end
	event.player:setAttribute("areas", playerAreas);
end
addEvent("PlayerChangePosition", onPlayerChangePosition);

--- Player enter worldpart event.
-- This event is triggered when the player enters a new worldpart (a worldpart is defined by 64x64 chunks).
-- If worldpartwise precision is sufficient, prefer this event over the PlayerChangePosition or PlayerEnterChunk-
-- event to save performance. Useful for example when you want to restrict the world.
-- @param event The event object. Cancel the event to teleport the player back to his old position
function onPlayerEnterWorldpart(event)
	-- Example how to restrict the worldsize to a single worldpart
	--if event.newWorldpart.x ~= 0 or event.newWorldpart.z ~= 0 then
	--	event:setCancel(true);
	--end
end
addEvent("PlayerEnterWorldpart", onPlayerEnterWorldpart);

--- Player block place event.
-- This event is triggered when the player places a block.
-- @param event The event object. Cancel the event to prevent to block to be placed
function onPlayerBlockPlace(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PlaceBlock"] == false and tableContains(group["BlockFilter"], tostring(event.newBlockID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerBlockPlace", onPlayerBlockPlace);

--- Player destroy block event.
-- This event is triggered when the player destroys a block.
-- @param event The event object. Cancel the event to prevent the block to be destroyed
function onPlayerBlockDestroy(event)
	print("PlayerBlockDestroy: ".. event.oldBlockID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["DestroyBlock"] == false and tableContains(group["BlockFilter"], tostring(event.oldBlockID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerBlockDestroy", onPlayerBlockDestroy);

--- Player place construction event.
-- This event is triggered when the player places an construction element (e.g. wooden plank).
-- @param event The event object. Cancel the event to prevent the element to be placed
function onPlayerConstructionPlace(event)
	print("PlayerConstructionPlace: ".. event.constructionID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PlaceConstructions"] == false and tableContains(group["ConstructionsFilter"], tostring(event.constructionID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerConstructionPlace", onPlayerConstructionPlace);

--- Player remove construction event.
-- This event is triggered when the player deconstructs a construction element (e.g. wooden plank).
-- @param event The event object. Cancel the event to prevent the element to be deconstructed
function onPlayerConstructionRemove(event)
	print("PlayerConstructionRemove: ".. event.constructionID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["RemoveConstructions"] == false and tableContains(group["ConstructionsFilter"], tostring(event.constructionId)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerConstructionRemove", onPlayerConstructionRemove);

--- Player destroy construction event.
-- This event is triggered when the player destroys a construction element (e.g. wooden plank).
-- @param event The event object. Cancel the event to prevent the element to be destroyed
function onPlayerConstructionDestroy(event)
	print("PlayerConstructionDestroy: ".. event.constructionID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["DestroyConstructions"] == false and tableContains(group["ConstructionsFilter"], tostring(event.constructionID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerConstructionDestroy", onPlayerConstructionDestroy);

--- Player place object event.
-- This event is triggered when the player places an object (e.g. furniture).
-- @param event The event object. Cancel the event to prevent the element to be placed
function onPlayerObjectPlace(event)
	print("PlayerObjectPlace: ".. event.objectTypeID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PlaceObjects"] == false and tableContains(group["ObjectsPlaceFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerObjectPlace", onPlayerObjectPlace);

--- Player remove object event.
-- This event is triggered when the player deconstructs an object (e.g. furniture).
-- @param event The event object. Cancel the event to prevent the element to be deconstructed
function onPlayerObjectRemove(event)
	print("PlayerObjectRemove: ".. event.objectTypeID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["RemoveObjects"] == false and tableContains(group["ObjectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerObjectRemove", onPlayerObjectRemove);

--- Player destroy object event.
-- This event is triggered when the player destroys an object (e.g. furniture).
-- @param event The event object. Cancel the event to prevent the element to be destroyed
function onPlayerObjectDestroy(event)
	print("PlayerObjectDestroy: ".. event.objectTypeID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["DestroyObjects"] == false and tableContains(group["ObjectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerObjectDestroy", onPlayerObjectDestroy);

--- Player change objectstatus event.
-- This event is triggered when the status of an object changes - e.g. when a door is opened.
-- @param event The event object. Cancel the event to prevent the status to be changed (e.g. prevents a door from opening)
function onPlayerObjectStatusChange(event)
	print("PlayerObjectStatusChange: ".. event.objectTypeID);
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["ChangeObjectStatus"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerObjectStatusChange", onPlayerObjectStatusChange);

--- Player object pickup event.
-- This event is triggered when the player picks up an object - e.g. a torch.
-- @param event The event object. Cancel the event to prevent the player from picking up the object
function onPlayerObjectPickup(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PickupObject"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerObjectPickup", onPlayerObjectPickup);

--- Player terrain fill up event.
-- This event is triggered when the player fills up the terrain - i.e. when he places dirt etc.
-- @param event The event object. Cancel the event to prevent the player to fill up the terrain
function onPlayerTerrainFill(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["FillWorld"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerTerrainFill", onPlayerTerrainFill);

--- Player terrain destroy event.
-- This event is triggered when the player destroys the terrain - i.e. when he is digging
-- @param event The event object. Cancel the event to prevent the player to remove the terrain
function onPlayerTerrainDestroy(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["DestroyWorld"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerTerrainDestroy", onPlayerTerrainDestroy);

--- Player chest place event.
-- This event is triggered when the player places a chest (every object with storage [e.g. also kitchenettes] is considered as a chest).
-- @param event The event object. Cancel the event to prevent the player to place the chest object
function onPlayerChestPlace(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PlaceObjects"] == false and tableContains(group["ObjectsPlaceFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		else
			local chest = {};
			
			chest["chunkOffsetX"] = event.chunkOffsetX;
			chest["chunkOffsetY"] = event.chunkOffsetY;
			chest["chunkOffsetZ"] = event.chunkOffsetZ;
			chest["positionX"] = event.position.x;
			chest["positionY"] = event.position.y;
			chest["positionZ"] = event.position.z;
			
			chests[event.chestID] = chest;
			
			database:queryupdate("INSERT INTO chests(ID, chunkOffsetX, chunkOffsetY, chunkOffsetZ, positionX, positionY, positionZ) VALUES ('".. event.chestID .. "', '".. chest["chunkOffsetX"] .."', '".. chest["chunkOffsetY"] .."', '".. chest["chunkOffsetZ"] .."', '".. chest["positionX"] .."', '".. chest["positionY"] .."', '".. chest["positionZ"] .."')");
		end
	end
end
addEvent("PlayerChestPlace", onPlayerChestPlace);

--- Player chest remove event.
-- This event is triggered when the player deconstructs a chest (every object with storage [e.g. also kitchenettes] is considered as a chest).
-- @param event The event object. Cancel the event to prevent the player from removing the chest
function onPlayerChestRemove(event)
	local chest = chests[event.chestID];
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["RemoveObjects"] == false and tableContains(group["ObjectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		else
			chests[event.chestID] = nil;
			database:queryupdate("DELETE FROM chests WHERE ID= '" .. event.chestID .. "'");
		end
	end
end
addEvent("PlayerChestRemove", onPlayerChestRemove);

--- Player chest destroy event.
-- This event is triggered when the player destroys a chest (every object with storage [e.g. also kitchenettes] is considered as a chest).
-- @param event The event object. Cancel the event to prevent the player from destroying the chest
function onPlayerChestDestroy(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["RemoveObjects"] == false and tableContains(group["ObjectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		else
			chests[event.chestID] = nil;
			database:queryupdate("DELETE FROM chests WHERE ID= '" .. event.chestID .. "'");
		end
	end
end
addEvent("PlayerChestDestroy", onPlayerChestDestroy);

--- Player vegetation place event.
-- This event is triggered when the player places a vegetation (e.g. a sapling)
-- @param event The event object. Cancel the event to prevent the player from placing vegetations
function onPlayerVegetationPlace(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PlaceVegetation"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerVegetationPlace", onPlayerVegetationPlace);

--- Player vegetation destroy event.
-- This event is triggered when the player destroys vegetation (e.g. cut a tree).
-- @param event The event object. Cancel the event to prevent the player from destroying vegetations
function onPlayerVegetationDestroy(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["RemoveVegetation"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerVegetationDestroy", onPlayerVegetationDestroy);

--- Player vegetation pickup event.
-- This event is triggered when the player picks up vegetation (e.g. flowers).
-- @param event The event object. Cancel the event to prevent the player from picking up vegetations
function onPlayerVegetationPickup(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["PickupVegetation"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerVegetationPickup", onPlayerVegetationPickup);

--- Player grass remove event.
-- This event is triggered when the player cuts grass.
-- @param event The event object. Cancel the event to prevent the player from cutting grass
function onPlayerGrassRemove(event)
	local area = getCurrentArea(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["CutGrass"] == false then
			event:setCancel(true);
		end
	end
end
addEvent("PlayerGrassRemove", onPlayerGrassRemove);

--- Move item from inventory to chest event.
-- This event is triggered when an item is moved from the inventory into a chest.
-- @param event The event object. Cancel the event to prevent the item to be moved
function onInventoryToChest(event)
	local chest = chests[event.chestID];
	if chest ~= nil then
		local area = getCurrentArea(chest["chunkOffsetX"], chest["chunkOffsetY"], chest["chunkOffsetZ"], chest["positionX"], chest["positionY"], chest["positionZ"]);
		if area ~= nil then
			local group = getPlayerGroupInArea(event.player, area);
			if group["InventoryToChest"] == false then
				event:setCancel(true);
			elseif group["ChestToInventory"] == false then
				local serverchest = server:getChest(event.chestID);
				if serverchest ~= nil then
					local chestitem = serverchest:getItem(event.chestslot);
					if(chestitem ~= nil) then
						event:setCancel(true);
					end
				end
			end
		end
	end
end
addEvent("InventoryToChest", onInventoryToChest);

--- Move item from chest to inventory event.
-- This event is triggered when an item is moved from the chest into the players inventory.
-- @param event The event object. Cancel the event to prevent the item to be moved
function onChestToInventory(event)
	print("CHEST:" .. event.chestID);
	local chest = chests[event.chestID];
	if chest ~= nil then
		local area = getCurrentArea(chest["chunkOffsetX"], chest["chunkOffsetY"], chest["chunkOffsetZ"], chest["positionX"], chest["positionY"], chest["positionZ"]);
		if area ~= nil then
			local group = getPlayerGroupInArea(event.player, area);
			if group["ChestToInventory"] == false then
				event:setCancel(true);
			end
		end
	end
end
addEvent("ChestToInventory", onChestToInventory);

--- Drop item out of a chest.
-- This event is triggered when an item is dropped out of a chest (i.e. drop a chest item).
-- @param event The event object. Cancel the event to prevent the item to be dropped
function onChestItemDrop(event)
	local chest = chests[event.chestID];
	if chest ~= nil then
		local area = getCurrentArea(chest["chunkOffsetX"], chest["chunkOffsetY"], chest["chunkOffsetZ"], chest["positionX"], chest["positionY"], chest["positionZ"]);
		if area ~= nil then
			local group = getPlayerGroupInArea(event.player, area);
			if group["ChestDrop"] == false then
				event:setCancel(true);
			end
		end
	end
end
addEvent("ChestItemDrop", onChestItemDrop);

--- Player respawn event.
-- This event is called when a player requests to respawn (when pressing the "respawn"-button
-- in the gameover screen).
-- @param event The event object. Cancel the event to prevent the player from respawning
function onPlayerRespawn(event)
	
end
addEvent("PlayerRespawn", onPlayerRespawn);

--- Player damage event.
-- This event is triggered when the player receives damage.
-- @param event The event object. Cancel the event to prevent the player to receive damage
function onPlayerDamage(event)
	-- This is an example how to make an admin invulnerable
	--if event.player:isAdmin() then
	--	event:setCancel(true);
	--end
end
addEvent("PlayerDamage", onPlayerDamage);
