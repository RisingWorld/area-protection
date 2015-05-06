
--- Player connect event.
-- This event is triggered when a player connects to the server. Note that the
-- player is currently in the loadingscreen at the moment this event is triggered,
-- so it's useless to display anything on the players screen.
-- @param event The event object. Cancel the event to prevent the player to connect
function onPlayerConnect(event)
	local label;

	-- current area label
	label = Gui:createLabel("", 0.05, 0.135);
	label:setFontsize(19);
	label:setFontColor(0xFFCE3EFF); -- orange, opaque
	label:setPivot(0);  -- left aligned
	label:setVisible(false);
	event.player:addGuiElement(label);
	event.player:setAttribute("areaLabel", label);
	event.player:setAttribute("areas", {});
	event.player:setAttribute("areasVisible", false);

	-- selection status label
	label = Gui:createLabel("", 0.05, 0.20);
	label:setFontsize(19);
	label:setFontColor(0xFFFF00FF); -- yellow, opaque
	label:setPivot(0);  -- left aligned
	label:setVisible(false);
	event.player:addGuiElement(label);
	event.player:setAttribute("areaStateLabel", label);

end
addEvent("PlayerConnect", onPlayerConnect);


--- Player spawn event.
-- This event is triggered when a player spawns the first (!) time. It is triggered
-- after the loadingscreen of the player disappears, so this is the right moment to
-- display some information on the player screen for example.
-- @param event The event object
--function onPlayerSpawn(event)
--end
--addEvent("PlayerSpawn", onPlayerSpawn);


--- Player respawn event.
-- This event is called when a player requests to respawn (when pressing the "respawn"-button
-- in the gameover screen).
-- @param event The event object. Cancel the event to prevent the player from respawning
--function onPlayerRespawn(event)
--end
--addEvent("PlayerRespawn", onPlayerRespawn);


--- Player change position event (frequently called event!)
-- This event is called everytime the player changes his position.
-- @param event The event object. Cancel the event to teleport the player back to his old position
function onPlayerChangePosition(event)
	if updateCurrentArea(event.player) == false then
		event:setCancel(true);
	end
end
addEvent("PlayerChangePosition", onPlayerChangePosition);

--- Player enter worldpart event.
-- This event is triggered when the player enters a new worldpart (a worldpart is defined by 64x64 chunks).
-- If worldpartwise precision is sufficient, prefer this event over the PlayerChangePosition or PlayerEnterChunk-
-- event to save performance. Useful for example when you want to restrict the world.
-- @param event The event object. Cancel the event to teleport the player back to his old position
--function onPlayerEnterWorldpart(event)
	-- Example how to restrict the worldsize to a single worldpart
	--if event.newWorldpart.x ~= 0 or event.newWorldpart.z ~= 0 then
	--	event:setCancel(true);
	--end
--end
--addEvent("PlayerEnterWorldpart", onPlayerEnterWorldpart);

--- Player block place event.
-- This event is triggered when the player places a block.
-- @param event The event object. Cancel the event to prevent to block to be placed
function onPlayerBlockPlace(event)
	print("PlayerBlockBlace: ".. event.newBlockID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["placeBlock"] == false and table.contains(group["blockFilter"], tostring(event.newBlockID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerBlockPlace", onPlayerBlockPlace);

--- Player destroy block event.
-- This event is triggered when the player destroys a block.
-- @param event The event object. Cancel the event to prevent the block to be destroyed
function onPlayerBlockDestroy(event)
	print("PlayerBlockDestroy: ".. event.oldBlockID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["destroyBlock"] == false and table.contains(group["blockFilter"], tostring(event.oldBlockID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerBlockDestroy", onPlayerBlockDestroy);

--- Player place construction event.
-- This event is triggered when the player places an construction element (e.g. wooden plank).
-- @param event The event object. Cancel the event to prevent the element to be placed
function onPlayerConstructionPlace(event)
	print("PlayerConstructionPlace: ".. event.constructionID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["placeConstructions"] == false and table.contains(group["constructionsFilter"], tostring(event.constructionID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerConstructionPlace", onPlayerConstructionPlace);

--- Player remove construction event.
-- This event is triggered when the player deconstructs a construction element (e.g. wooden plank).
-- @param event The event object. Cancel the event to prevent the element to be deconstructed
function onPlayerConstructionRemove(event)
	print("PlayerConstructionRemove: ".. event.constructionID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["removeConstructions"] == false and table.contains(group["constructionsFilter"], tostring(event.constructionId)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerConstructionRemove", onPlayerConstructionRemove);

--- Player destroy construction event.
-- This event is triggered when the player destroys a construction element (e.g. wooden plank).
-- @param event The event object. Cancel the event to prevent the element to be destroyed
function onPlayerConstructionDestroy(event)
	print("PlayerConstructionDestroy: ".. event.constructionID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["destroyConstructions"] == false and table.contains(group["constructionsFilter"], tostring(event.constructionID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerConstructionDestroy", onPlayerConstructionDestroy);

--- Player place object event.
-- This event is triggered when the player places an object (e.g. furniture).
-- @param event The event object. Cancel the event to prevent the element to be placed
function onPlayerObjectPlace(event)
	print("PlayerObjectPlace: ".. event.objectTypeID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["placeObjects"] == false and table.contains(group["objectsPlaceFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerObjectPlace", onPlayerObjectPlace);

--- Player remove object event.
-- This event is triggered when the player deconstructs an object (e.g. furniture).
-- @param event The event object. Cancel the event to prevent the element to be deconstructed
function onPlayerObjectRemove(event)
	print("PlayerObjectRemove: ".. event.objectTypeID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["removeObjects"] == false and table.contains(group["objectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerObjectRemove", onPlayerObjectRemove);

--- Player destroy object event.
-- This event is triggered when the player destroys an object (e.g. furniture).
-- @param event The event object. Cancel the event to prevent the element to be destroyed
function onPlayerObjectDestroy(event)
	print("PlayerObjectDestroy: ".. event.objectTypeID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["destroyObjects"] == false and table.contains(group["objectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerObjectDestroy", onPlayerObjectDestroy);

--- Player change objectstatus event.
-- This event is triggered when the status of an object changes - e.g. when a door is opened.
-- @param event The event object. Cancel the event to prevent the status to be changed (e.g. prevents a door from opening)
function onPlayerObjectStatusChange(event)
	print("PlayerObjectStatusChange: ".. event.objectTypeID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["changeObjectStatus"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerObjectStatusChange", onPlayerObjectStatusChange);

--- Player object pickup event.
-- This event is triggered when the player picks up an object - e.g. a torch.
-- @param event The event object. Cancel the event to prevent the player from picking up the object
function onPlayerObjectPickup(event)
	print("PlayerObjectPickup: ".. event.objectTypeID);
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["pickupObject"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerObjectPickup", onPlayerObjectPickup);

--- Player terrain fill up event.
-- This event is triggered when the player fills up the terrain - i.e. when he places dirt etc.
-- @param event The event object. Cancel the event to prevent the player to fill up the terrain
function onPlayerTerrainFill(event)
	print("PlayerTerrainFill");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["fillTerrain"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerTerrainFill", onPlayerTerrainFill);

--- Player terrain destroy event.
-- This event is triggered when the player destroys the terrain - i.e. when he is digging
-- @param event The event object. Cancel the event to prevent the player to remove the terrain
function onPlayerTerrainDestroy(event)
	print("PlayerTerrainDestroy");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["destroyTerrain"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerTerrainDestroy", onPlayerTerrainDestroy);

--- Player chest place event.
-- This event is triggered when the player places a chest (every object with storage [e.g. also kitchenettes] is considered as a chest).
-- @param event The event object. Cancel the event to prevent the player to place the chest object
function onPlayerChestPlace(event)
	print("PlayerChestPlace");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["placeObjects"] == false and tableContains(group["objectsPlaceFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerChestPlace", onPlayerChestPlace);

--- Player chest remove event.
--- Player chest destroy event.
-- This event is triggered when the player destroys or deconstructs a chest (every object with storage [e.g. also kitchenettes] is considered as a chest).
-- @param event The event object. Cancel the event to prevent the player from destroying the chest
function onPlayerChestRemove(event)
	print("PlayerChestRemove");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["removeObjects"] == false and table.contains(group["objectsRemoveDestroyFilter"], tostring(event.objectTypeID)) == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerChestRemove", onPlayerChestRemove);
--addEvent("PlayerChestDestroy", onPlayerChestDestroy);

--- Player vegetation place event.
-- This event is triggered when the player places a vegetation (e.g. a sapling)
-- @param event The event object. Cancel the event to prevent the player from placing vegetations
function onPlayerVegetationPlace(event)
	print("PlayerVegetationPlace");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["placeVegetation"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerVegetationPlace", onPlayerVegetationPlace);

--- Player vegetation destroy event.
-- This event is triggered when the player destroys vegetation (e.g. cut a tree).
-- @param event The event object. Cancel the event to prevent the player from destroying vegetations
function onPlayerVegetationDestroy(event)
	print("PlayerVegetationDestroy");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["removeVegetation"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerVegetationDestroy", onPlayerVegetationDestroy);

--- Player vegetation pickup event.
-- This event is triggered when the player picks up vegetation (e.g. flowers).
-- @param event The event object. Cancel the event to prevent the player from picking up vegetations
function onPlayerVegetationPickup(event)
	print("PlayerVegetationPickup");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.position.x, event.position.y, event.position.z);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["pickupVegetation"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerVegetationPickup", onPlayerVegetationPickup);

--- Player grass remove event.
-- This event is triggered when the player cuts grass.
-- @param event The event object. Cancel the event to prevent the player from cutting grass
function onPlayerGrassRemove(event)
	print("PlayerGrassRemove");
	local area = getAreaAtPosition(event.chunkOffsetX, event.chunkOffsetY, event.chunkOffsetZ, event.blockPositionX, event.blockPositionY, event.blockPositionZ);
	if area ~= nil then
		local group = getPlayerGroupInArea(event.player, area);
		if group["cutGrass"] == false then
			event:setCancel(true);
		end
	end
end
--addEvent("PlayerGrassRemove", onPlayerGrassRemove);

--- Move item from inventory to chest event.
-- This event is triggered when an item is moved from the inventory into a chest.
-- @param event The event object. Cancel the event to prevent the item to be moved
function onInventoryToChest(event)
	local chest = chests[event.chestID];
	if chest ~= nil then
		local area = getAreaAtPosition(chest["chunkOffsetX"], chest["chunkOffsetY"], chest["chunkOffsetZ"], chest["positionX"], chest["positionY"], chest["positionZ"]);
		if area ~= nil then
			local group = getPlayerGroupInArea(event.player, area);
			if group["inventoryToChest"] == false then
				event:setCancel(true);
			elseif group["chestToInventory"] == false then
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
--addEvent("InventoryToChest", onInventoryToChest);

--- Move item from chest to inventory event.
-- This event is triggered when an item is moved from the chest into the players inventory.
-- @param event The event object. Cancel the event to prevent the item to be moved
function onChestToInventory(event)
	print("CHEST:" .. event.chestID);
	local chest = chests[event.chestID];
	if chest ~= nil then
		local area = getAreaAtPosition(chest["chunkOffsetX"], chest["chunkOffsetY"], chest["chunkOffsetZ"], chest["positionX"], chest["positionY"], chest["positionZ"]);
		if area ~= nil then
			local group = getPlayerGroupInArea(event.player, area);
			if group["chestToInventory"] == false then
				event:setCancel(true);
			end
		end
	end
end
--addEvent("ChestToInventory", onChestToInventory);

--- Drop item out of a chest.
-- This event is triggered when an item is dropped out of a chest (i.e. drop a chest item).
-- @param event The event object. Cancel the event to prevent the item to be dropped
function onChestItemDrop(event)
	local chest = chests[event.chestID];
	if chest ~= nil then
		local area = getAreaAtPosition(chest["chunkOffsetX"], chest["chunkOffsetY"], chest["chunkOffsetZ"], chest["positionX"], chest["positionY"], chest["positionZ"]);
		if area ~= nil then
			local group = getPlayerGroupInArea(event.player, area);
			if group["chestDrop"] == false then
				event:setCancel(true);
			end
		end
	end
end
--addEvent("ChestItemDrop", onChestItemDrop);

--- Player damage event.
-- This event is triggered when the player receives damage.
-- @param event The event object. Cancel the event to prevent the player to receive damage
--function onPlayerDamage(event)
	-- This is an example how to make an admin invulnerable
	--if event.player:isAdmin() then
	--	event:setCancel(true);
	--end
--end
--addEvent("PlayerDamage", onPlayerDamage);
