
--- Player command event.
-- This event is triggered the the player sends a command.
-- A command is defined as input into the chat beginning with "/".
-- Commands are not shown in global chat, but triggers this event.
-- @param event The event object
-- @usage The whole command string is stored in the event object (event.command) 
-- as well as the player (event.player).
function onPlayerCommand(event)
	-- Split the command string
	local cmd = StringUtils:explode(event.command, " ");
	
	if #cmd >= 1 then
		cmd[1] = string.lower(cmd[1]);
		
		-- Command /showareas to visualize all existing areas
		if cmd[1] == "/showareas" then
			local world = getWorld();
			local playerAreas = {};
			for key,value in pairs(areas) do
				local area = {};
				area[1] = value["areaID"];
				area[2] = value["startChunkpositionX"];
				area[3] = value["startChunkpositionY"];
				area[4] = value["startChunkpositionZ"];
				area[5] = value["startBlockpositionX"];
				area[6] = value["startBlockpositionY"];
				area[7] = value["startBlockpositionZ"];
				area[8] = value["endChunkpositionX"];
				area[9] = value["endChunkpositionY"];
				area[10] = value["endChunkpositionZ"];
				area[11] = value["endBlockpositionX"];
				area[12] = value["endBlockpositionY"];
				area[13] = value["endBlockpositionZ"];
				area[14] = colors[math.random(#colors)];
				table.insert(playerAreas, area);
			end
			event.player:setAttribute("areasVisible", true);
			event.player:createAreas(playerAreas);
			event.player:showAllAreas();
			
		-- Command /hideareas to hide all visualized areas
		elseif cmd[1] == "/hideareas" then
			local areaIds = {};
			for key,value in pairs(areas) do
				table.insert(areaIds, value["areaID"]);
			end
			event.player:destroyAreas(areaIds);
			event.player:setAttribute("areasVisible", false);
		end

		-- All following commands are only usable when the player is an admin!
		if event.player:isAdmin() == false then
			event.player:sendTextMessage("[#FF0000]You are not an admin");
			return;
		end
		
		-- Command /selectarea to visualize all existing areas
		if cmd[1] == "/selectarea" then
			-- This is a Callback function, so we have to provide a function as parameter
			-- which is called when the callback is done
			event.player:enableMarkingSelector(function()
			
			end);
			
			event.player:sendYellMessage("Select the area and type \"/createarea\" to save it");
			
		-- Command /createarea to save the area you have defined previously
		elseif cmd[1] == "/createarea" then
			if #cmd >= 2 then
				-- Provide a Callback-function, since it can't be triggered immediately, only after we receive the response from the player
				event.player:disableMarkingSelector(function(markingEvent)
					if markingEvent ~= false then
						local area = {};
						area["playerID"] = markingEvent.player:getDBID();
						area["areaName"] = string.sub(event.command, 13);
						area["startChunkpositionX"] = markingEvent.startChunkpositionX;
						area["startChunkpositionY"] = markingEvent.startChunkpositionY;
						area["startChunkpositionZ"] = markingEvent.startChunkpositionZ;
						area["startBlockpositionX"] = markingEvent.startBlockpositionX;
						area["startBlockpositionY"] = markingEvent.startBlockpositionY;
						area["startBlockpositionZ"] = markingEvent.startBlockpositionZ;
						
						area["endChunkpositionX"] = markingEvent.endChunkpositionX;
						area["endChunkpositionY"] = markingEvent.endChunkpositionY;
						area["endChunkpositionZ"] = markingEvent.endChunkpositionZ;
						area["endBlockpositionX"] = markingEvent.endBlockpositionX;
						area["endBlockpositionY"] = markingEvent.endBlockpositionY;
						area["endBlockpositionZ"] = markingEvent.endBlockpositionZ;
						area["rights"] = {};
						
						adjustAreaPositions(area);
						calculateGlobalAreaPosition(area);
						
						database:queryupdate("INSERT INTO areas(name, startChunkpositionX, startChunkpositionY, startChunkpositionZ, startBlockpositionX, startBlockpositionY, startBlockpositionZ, endChunkpositionX, endChunkpositionY, endChunkpositionZ, endBlockpositionX, endBlockpositionY, endBlockpositionZ, playerID) VALUES ('".. string.sub(event.command, 13) .."', '".. area["startChunkpositionX"] .."', '".. area["startChunkpositionY"] .."', '".. area["startChunkpositionZ"] .."', '".. area["startBlockpositionX"] .."', '".. area["startBlockpositionY"] .."', '".. area["startBlockpositionZ"] .."', '".. area["endChunkpositionX"] .."', '".. area["endChunkpositionY"] .."', '".. area["endChunkpositionZ"] .."', '".. area["endBlockpositionX"] .."', '".. area["endBlockpositionY"] .."', '".. area["endBlockpositionZ"] .."', '".. markingEvent.player:getDBID() .."')");
						local insertID = database:getLastInsertID();
						area["areaID"] = insertID;
						areas[insertID] = area;
						
						if event.player:getAttribute("areasVisible") == true then
							event.player:createArea(insertID, area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"], colors[math.random(#colors)]);
							event.player:showArea(insertID);
						end
						event.player:sendTextMessage("[#00FF00]Area successfully created!");
					end
				end);
			else
				event.player:sendTextMessage("[#FF0000]Use /createarea [AreaName]");
			end
			
		--Command /removearea to delete the area you're currently inside
		elseif cmd[1] == "/removearea" then
			local areaID = event.player:getAttribute("areaID");
			if areaID ~= nil then
				database:queryupdate("DELETE FROM areas WHERE ID= '" .. areas[areaID]["areaID"] .. "'");
				database:queryupdate("DELETE FROM rights WHERE areaID= '" .. areas[areaID]["areaID"] .. "'");
				areas[areaID] = nil;
				event.player:setAttribute("areaID", nil);
				event.player:setAttribute("areaGroup", nil);
				event.player:destroyArea(areaID);
				event.player:sendTextMessage("[#00FF00]Area successfully removed!");
				if event.player:getAttribute("areasVisible") == true then
					event.player:destroyArea(areaID);
				end
			else
				event.player:sendTextMessage("[#FF0000]You must enter an area first!");
			end
			
		-- Command /addplayertoarea to add a player to the provided group inside the area you currently are
		elseif cmd[1] == "/addplayertoarea" then
			if #cmd >= 3 then
				local areaID = event.player:getAttribute("areaID");
				if areaID ~= nil then
					local group = getGroupByName(cmd[2]);
					local player = server:getPlayerInformationFromDB(cmd[3]);
					if group ~= nil then
						if player ~= nil then
							if areas[areaID]["rights"][player.dbID] == nil then
								database:queryupdate("INSERT INTO rights ('areaID', 'playerID', 'group') VALUES ('".. areas[areaID]["areaID"] .."', '".. player.dbID .. "', '".. cmd[2] .. "')");
							else
								database:queryupdate("UPDATE rights SET 'group'='".. cmd[2] .."'");
							end
							areas[areaID]["rights"][player.dbID] = group;
							
							event.player:sendTextMessage("[#00FF00]Player \"" .. cmd[3] .. "\" successfully added to area (".. cmd[2] ..")!");
						else
							event.player:sendTextMessage("[#FF0000]Player \"" .. cmd[3] .. "\" not found!");
						end
					else
						event.player:sendTextMessage("[#FF0000]Group \"" .. cmd[2] .. "\" not found!");
					end
				else
					event.player:sendTextMessage("[#FF0000]You must enter an area first!");
				end
			else
				event.player:sendTextMessage("[#FF0000]Use /addplayertoarea [GroupName] [PlayerName]");
			end
			
		-- Command /removeplayerfromarea to unregister a player from the area you're standing in
		elseif cmd[1] == "/removeplayerfromarea" then
			if #cmd >= 2 then
				local areaID = event.player:getAttribute("areaID");
				if areaID ~= nil then
					local player = server:getPlayerInformationFromDB(cmd[2]);
					if player ~= nil then
						areas[areaID]["rights"][player.dbID] = nil;
						database:queryupdate("DELETE FROM rights WHERE playerID= '" .. player.dbID .. "' AND areaID='" .. areaID .. "'");
						event.player:sendTextMessage("[#00FF00]Player \"" .. cmd[2] .. "\" successfully removed from area!");
					else
						event.player:sendTextMessage("[#FF0000]Player \"" .. cmd[2] .. "\" not found!");
					end
				else
					event.player:sendTextMessage("[#FF0000]You must enter an area first!");
				end
			else
				event.player:sendTextMessage("[#FF0000]Use /removeplayerfromarea [PlayerName]");
			end
			
		-- Command /reloadgroups to reload all group propertyfiles
		elseif cmd[1] == "/reloadgroups" then
			loadGroups();
			
		-- Command /cleanuparea to remove all objects, constructions, vegetations and blocks from an area
		elseif cmd[1] == "/cleanuparea" then
			local area = nil;
			
			-- Find the area, if the player provided the area name, you can search for the particular area...
			if #cmd >= 2 then
				for key,value in pairs(areas) do
					if value["areaName"] == cmd[2] then
						area = value;
						break;
					end
				end
			-- ...otherwise we check if the player is currently inside an area
			else
				local areaID = event.player:getAttribute("areaID");
				if areaID ~= nil then
					area = areas[areaID];
				end
			end
			
			if area ~= nil then
				print("Cleanup area "..area["areaName"]);
				-- Removes all objects inside the area
				world:removeAllObjectsInArea(area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"]);
				-- Removes all constructions inside the area
				world:removeAllConstructionsInArea(area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"]);
				-- Removes all vegetations inside the area
				world:removeAllVegetationsInArea(area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"]);
				-- Removes all blocks inside the area, slightly different function, since it also requires the new BlockID at the end (we use 0 for AIR in this case)
				world:setBlockDataInArea(area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"], 0);
				-- Send success message to player
				event.player:sendTextMessage("[#00FF00]Area "..area["areaName"].." successfully cleaned up!");
			else
				event.player:sendTextMessage("[#FF0000]You must enter an area first or provide the areaname!");
			end
			
		-- Command /fillarea to fill up an area with terrain or air
		elseif cmd[1] == "/fillarea" then
			if #cmd >= 3 then
				local area = nil;
				
				-- Find the area
				for key,value in pairs(areas) do
					if value["areaName"] == cmd[2] then
						area = value;
						break;
					end
				end
				
				if StringUtils:isInteger(cmd[3]) then
					local terraintype = tonumber(cmd[3]);
					if area ~= nil then
						world:setTerrainDataInArea(area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"], terraintype);
						event.player:sendTextMessage("[#00FF00]Area "..area["areaName"].." successfully filled up with "..terraintype);
					else
						event.player:sendTextMessage("[#FF0000]Area "..cmd[2].." not found!");
					end
				else
					event.player:sendTextMessage("[#FF0000]You must provide a numeric terraintype id");
				end
			else
				event.player:sendTextMessage("[#FF0000]Use /fillarea [AreaName] [TerrainType] [#B0B0B0](use 0 for AIR)");
			end
		
		-- If command was not found, send a notification to the player. Eventually you want to
		-- remove this line when you are using more than 1 scripts (with different command listeners)
		else
			event.player:sendTextMessage("[#B0B0B0]Unknown command");
		end
	end
end
addEvent("PlayerCommand", onPlayerCommand);
