include("command-parser/parse-args.lua");

local baseAreaId = 1000000;


local function areaHelp(event, args)

	-- TODO

end


--- Show all areas to the player
-- @param event  the event
local function areaShow(event)
	local playerAreas = {};
	local areasVisible = event.player:getAttribute("areasVisible");

	if areasVisible ~= true then
		areasVisible = {};

		for key,area in pairs(areas) do
			local areaId = baseAreaId + area["areaId"];

			table.insert(areasVisible, areaId);
			table.insert(playerAreas, {
				areaId,

				area["startChunkpositionX"],
				area["startChunkpositionY"],
			  area["startChunkpositionZ"],

				area["startBlockpositionX"],
				area["startBlockpositionY"],
				area["startBlockpositionZ"],

				area["endChunkpositionX"],
				area["endChunkpositionY"],
				area["endChunkpositionZ"],

				area["endBlockpositionX"],
				area["endBlockpositionY"],
				area["endBlockpositionZ"],

				0x0000ff77
			});
		end

		event.player:setAttribute("areasVisible", true);
		event.player:createAreas(playerAreas);
		event.player:showAreas(areasVisible);

	end
end


--- Hide all areas to the player
-- @param event  the event
local function areaHide(event)
	local areaIds = {};

	for key,area in pairs(areas) do
		table.insert(areaIds, baseAreaId + area["areaId"]);
	end

	event.player:destroyAreas(areaIds);
	event.player:setAttribute("areasVisible", false);
end


local function areaSelect(event, args, flags)
	-- This is a Callback function, so we have to provide a function as parameter
	-- which is called when the callback is done
	event.player:enableMarkingSelector(function()
		event.player:sendYellMessage("Select the area and type \"/createarea\" to save it");
	end);

end


local function areaInfo(event, args, flags)

	-- TODO

end


local function areaCreate(event, args, flags)
	if #args >= 1 then
		-- Provide a Callback-function, since it can't be triggered immediately, only after we receive the response from the player
		event.player:disableMarkingSelector(function(markingEvent)
			if markingEvent ~= false then
				local area = {};
				area["name"] = args[1];
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

				area["createdBy"] = markingEvent.player:getPlayerDBID();
				area["createdAt"] = nil;  -- ???

				adjustAreaPositions(area);
				calculateGlobalAreaPosition(area);

				database:queryupdate("INSERT INTO areas(name, startChunkpositionX, startChunkpositionY, startChunkpositionZ, startBlockpositionX, startBlockpositionY, startBlockpositionZ, endChunkpositionX, endChunkpositionY, endChunkpositionZ, endBlockpositionX, endBlockpositionY, endBlockpositionZ, playerID) VALUES ('".. string.sub(event.command, 13) .."', '".. area["startChunkpositionX"] .."', '".. area["startChunkpositionY"] .."', '".. area["startChunkpositionZ"] .."', '".. area["startBlockpositionX"] .."', '".. area["startBlockpositionY"] .."', '".. area["startBlockpositionZ"] .."', '".. area["endChunkpositionX"] .."', '".. area["endChunkpositionY"] .."', '".. area["endChunkpositionZ"] .."', '".. area["endBlockpositionX"] .."', '".. area["endBlockpositionY"] .."', '".. area["endBlockpositionZ"] .."', '".. markingEvent.player:getPlayerDBID() .."')");
				local insertID = database:getLastInsertID();
				area["id"] = insertID;
				areas[insertID] = area;

				if event.player:getAttribute("areasVisible") == true then
					event.player:createArea(baseAreaId + insertID, area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"], 0x0000ff77);
					event.player:showArea(baseAreaId + insertID);
				end
				event.player:sendTextMessage("[#00FF00]Area successfully created!");
			end
		end);
	else
		event.player:sendTextMessage("[#FF0000]Use /area create [AreaName]");
	end

end


local function areaRemove(event, args, flags)
	local areaId = event.player:getAttribute("areaId");
	if areaId ~= nil then
		database:queryupdate("DELETE FROM areas WHERE id= '" .. areaId .. "'");
		database:queryupdate("DELETE FROM rights WHERE areaId= '" .. areaID .. "'");

		areas[areaId] = nil;
		event.player:setAttribute("areaId", nil);
		event.player:setAttribute("areaGroup", nil);
		event.player:destroyArea(areaId);
		event.player:sendTextMessage("[#00FF00]Area successfully removed!");
		if event.player:getAttribute("areasVisible") == true then
			event.player:destroyArea(baseAreaId + areaId);
		end
	else
		event.player:sendTextMessage("[#FF0000]You must enter an area first!");
	end
end



local function areaGrant(event, args, flags)
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
end


local function areaRevoke(event, args, flags)
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
end



--- Player command event.
-- This event is triggered the the player sends a command.
-- A command is defined as input into the chat beginning with "/".
-- Commands are not shown in global chat, but triggers this event.
-- @param event The event object
-- @usage The whole command string is stored in the event object (event.command)
-- as well as the player (event.player).
function onPlayerCommand(event)
	local args, flags = parseArgs(event.command);
	local cmd;

  if #args >= 1 then

    if string.lower(args[1]) == "/area" then
      -- command handled
      event:setCancel(true);

      cmd = string.lower(args[2] or "");

      if cmd == "help" then
      	areaHelp(event, table.slice(args, 3));
			elseif cmd == "show" then
				areaShow(event);
			elseif cmd == "hide" then
				areaHide(event);
			elseif cmd == "info" then
				if checkPlayerAccess(event.player, "info") then areaInfo(event, table.slice(args, 3), flags); end;
			elseif cmd == "select" then
				if checkPlayerAccess(event.player, "select") then areaSelect(event, table.slice(args, 3), flags); end;
			elseif cmd == "create" then
				if checkPlayerAccess(event.player, "create") then areaCreate(event, table.slice(args, 3), flags); end;
			elseif cmd == "remove" then
				if checkPlayerAccess(event.player, "remove") then areaRemove(event, table.slice(args, 3), flags); end;
			elseif cmd == "grant" then
				if checkPlayerAccess(event.player, "grant") then areaGrant(event, table.slice(args, 3), flags); end;
			elseif cmd == "remoke" then
				if checkPlayerAccess(event.player, "revoke") then areaRevoke(event, table.slice(args, 3), flags); end;
			else
				event.player:sendTextMessage("[#B0B0B0]Unknown command");
			end
		end
	end
end
addEvent("PlayerCommand", onPlayerCommand);
