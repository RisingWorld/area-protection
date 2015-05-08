include("command-parser/parse-args.lua");


local function showStateLabel(player, msg)
	local label = player:getAttribute("areaStateLabel");

	if msg then
    label:setText(i18n.t(player, msg));
    label:setVisible(true);
	else
    label:setText("");
    label:setVisible(false);
	end
end


local function areaHelp(event, args)
	print("Show help");

	-- TODO

end


local function areaSelect(event)
	--print("Selecting area");
	event.player:enableMarkingSelector(function()
    showStateLabel(event.player, "select.start");
	end);
end


local function areaCancel(event)
	--print("Canceling selection");
	event.player:disableMarkingSelector(function (markingEvent)
		showStateLabel();
	end);
end


local function areaInfo(event, args)

	-- TODO : args[1] may specify the area name to show info for

	local areaId = event.player:getAttribute("areaId");
	local area = areaId and areas[areaId];

	if area then
		print("Showing info for area ".. area["name"]);

		for k,line in pairs(getAreaInfo(event.player, area)) do
			event.player:sendTextMessage("[#8888FF]* ".. line);
		end
	end
end


local function areaCreate(event, args, flags)
	if #args >= 1 then
		event.player:getMarkingSelectorStatus(function(markingEvent)
			if markingEvent ~= false then
				local createdAreaId = createArea(markingEvent, args[1]);

				if createdAreaId then
				  local area = areas[createdAreaId];

				  for key,player in pairs(server:getPlayers()) do
				  	showAreaBoundaries(player, area);
				  end

					event.player:sendTextMessage("[#00FF00]Area created successfully!");

					event.player:disableMarkingSelector(function (markingEvent)
						showStateLabel();
					end);
				else
					event.player:sendTextMessage("[#FF0000]Could not create area");
				end
  		end
		end);
	else
		event.player:sendTextMessage("[#FF0000]Missing <name> argument");
	end

end


local function areaRemove(event)
	local areaId = event.player:getAttribute("areaId");
	if areaId then
		if removeArea(areaId) == true then

		  for key,player in pairs(server:getPlayers()) do
		  	hideAreaBoundaries(player, areaId);
		  	updateCurrentArea(player);
		  end

		  event.player:sendTextMessage("[#00FF00]Area successfully removed!");
		else
			event.player:sendTextMessage("[#FF0000]Could not remove area");
		end
	else
		event.player:sendTextMessage("[#FF0000]You must enter an area first!");
	end
end



local function areaGrant(event, args, flags)
	if #args == 1 or #args == 2 then
		local areaId = event.player:getAttribute("areaId");

		if areaId then
			local group = getGroupByName(args[1]);
			local player = args[2] and server:findPlayerByName(args[2]) or event.player;

			if not group then
				event.player:sendTextMessage("[#FF0000]Unknown group");
			elseif not player then
				event.player:sendTextMessage("[#FF0000]Unknown player");
			elseif grantPlayerRights(event.player, areas[areaId], player, group) then
				showAreaBoundaries(player, areas[areaId]);
				updateAreaLabel(player);

				if player:getDBID() == event.player:getDBID() then
					event.player:sendTextMessage("[#00FF00]You have been granted successfully!");
				else
					player:sendTextMessage("[#FFFF00]You have been granted access to [#8888FF]"..areas[areaId]["name"].."[#FFFF00] as [#8888FF]"..group["name"].."[#FFFF00] by [#FFFFFF]"..event.player.getName().."!");
					event.player:sendTextMessage("[#00FF00]Player has been granted successfully!");
				end
			else
				event.player:sendTextMessage("[#FF0000]Could not grant player to the area");
			end
		else
			event.player:sendTextMessage("[#FF0000]You must enter an area first!");
		end
	else
		event.player:sendTextMessage("[#FF0000]Usage: /area grant <group> [playername]");
	end
end


local function areaRevoke(event, args, flags)
	if #args < 2 then
		local areaId = event.player:getAttribute("areaId");

		if areaId then
			local player = args[1] and server:findPlayerByName(args[1]) or event.player;

			if not player then
				event.player:sendTextMessage("[#FF0000]Unknown player");
			elseif revokePlayerRights(event.player, areas[areaId], player) then
				showAreaBoundaries(player, areas[areaId]);
				updateAreaLabel(player);

				if player:getDBID() == event.player:getDBID() then
					event.player:sendTextMessage("[#00FF00]You have been revoked successfully!");
				else
					player:sendTextMessage("[#FFFF00]You have been revoked access to [#8888FF]"..areas[areaId]["name"].."[#FFFF00] as [#8888FF]"..group["name"].."[#FFFF00]!");
					event.player:sendTextMessage("[#00FF00]Player has been granted successfully!");
				end
			else

			end
		else
			event.player:sendTextMessage("[#FF0000]You must enter an area first!");
		end
	else
		event.player:sendTextMessage("[#FF0000]Usage: /area revoke <playername>|me");
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
				showAllAreaBoundaries(event.player);
			elseif cmd == "hide" then
				hideAllAreaBoundaries(event.player);
			elseif cmd == "info" then
				if checkPlayerAccess(event.player, "info") then areaInfo(event, table.slice(args, 3)); end;
			elseif cmd == "select" then
				if checkPlayerAccess(event.player, "select") then areaSelect(event); end;
			elseif cmd == "cancel" then
				areaCancel(event);
			elseif cmd == "create" then
				if checkPlayerAccess(event.player, "create") then areaCreate(event, table.slice(args, 3), flags); end;
			elseif cmd == "remove" then
				if checkPlayerAccess(event.player, "remove") then areaRemove(event, table.slice(args, 3)); end;
			elseif cmd == "grant" then
				if checkPlayerAccess(event.player, "grant") then areaGrant(event, table.slice(args, 3), flags); end;
			elseif cmd == "revoke" then
				if checkPlayerAccess(event.player, "revoke") then areaRevoke(event, table.slice(args, 3), flags); end;
			else
				event.player:sendTextMessage("[#FF0000]Unknown command");
			end
		end
	end
end
addEvent("PlayerCommand", onPlayerCommand);
