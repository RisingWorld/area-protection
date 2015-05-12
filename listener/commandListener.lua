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
  local helpContext = string.lower(args[1] or "");

  if helpContext == "show" then
    event.player:sendTextMessage("[#33FF33]/area show");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.show.usage"));
  elseif helpContext == "hide" then
    event.player:sendTextMessage("[#33FF33]/area hide");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.hide.usage"));
  --elseif helpContext == "info" then
  --  event.player:sendTextMessage("[#33FF33]/area info [areaname]");
  --  event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.info.usage"));
  elseif helpContext == "select" then
    event.player:sendTextMessage("[#33FF33]/area select");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.select.usage"));
  elseif helpContext == "cancel" then
    event.player:sendTextMessage("[#33FF33]/area cancel");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.cancel.usage"));
  elseif helpContext == "create" then
    event.player:sendTextMessage("[#33FF33]/area create <areaname>");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.create.usage"));
  elseif helpContext == "remove" then
    event.player:sendTextMessage("[#33FF33]/area remove");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.remove.usage"));
  elseif helpContext == "grant" then
    event.player:sendTextMessage("[#33FF33]/area grant <".. table.concat(table.pluck(groups, "name"), '|') .."> [playername]");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.grant.usage"));
  elseif helpContext == "revoke" then
    event.player:sendTextMessage("[#33FF33]/area revoke [playername]");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.revoke.usage"));
  else
  	-- TODO: insert "info" once areaInfo is working...
    event.player:sendTextMessage("[#33FF33]/area help|show|hide|select|cancel|create|remove|grant|revoke [args]");
    event.player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "help.usage", "/area help create"));
  end
end


local function areaSelect(event)
	event.player:enableMarkingSelector(function()
    showStateLabel(event.player, "select.start");
	end);
end


local function areaCancel(event)
	event.player:disableMarkingSelector(function (markingEvent)
		showStateLabel();
	end);
end


local function areaInfo(event, args)

	-- TODO : args[1] may specify the area name to show info for

	local areaId = event.player:getAttribute("areaId");
	local area = areaId and areas[areaId];

	if area then
		print("Showing info for area ".. area["name"].. " to ".. event.player:getName());

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

				  print(event.player:getName() .." created area \"".. area["name"] .."\"");

				  for key,player in pairs(server:getPlayers()) do
				  	showAreaBoundaries(player, area);
				  end

					event.player:sendTextMessage("[#00FF00]"..i18n.t(event.player, "create.success"));

					event.player:disableMarkingSelector(function (markingEvent)
						showStateLabel();
					end);
				else
					event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "create.error"));
				end
  		end
		end);
	else
		event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.missing.arg", "<areaname>"));
	end
end


local function areaRemove(event)
	local areaId = event.player:getAttribute("areaId");
	if areaId then
		local areaName = areas[areaId]["name"];

		if removeArea(areaId) == true then
			print(event.player:getName() .." removed area \"".. area["name"] .."\"");

		  for key,player in pairs(server:getPlayers()) do
		  	hideAreaBoundaries(player, areaId);
		  	updateCurrentArea(player);
		  end

		  event.player:sendTextMessage("[#00FF00]"..i18n.t(event.player, "remove.success"));
		else
			event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "remove.error"));
		end
	else
		event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.notinarea"));
	end
end



local function areaGrant(event, args, flags)
	if #args == 1 or #args == 2 then
		local areaId = event.player:getAttribute("areaId");

		if areaId then
			local group = getGroupByName(args[1]);
			local player = args[2] and server:findPlayerByName(args[2]) or event.player;

			if not group then
				event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.unknown.group"));
			elseif not player then
				event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.unknown.player"));
			elseif grantPlayerRights(event.player, areas[areaId], player, group) then
				print(event.player:getName() .." granted ".. group["name"] .." to area \"".. areas[areaId]["name"] .."\"");

				showAreaBoundaries(player, areas[areaId]);
				updateAreaLabel(player);

				if player:getDBID() == event.player:getDBID() then
					event.player:sendTextMessage("[#00FF00]"..i18n.t(event.player, "grant.success.self"));
				else
					player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "grant.success.other", "[#8888FF]"..areas[areaId]["name"].."[#FFFF00]", "[#8888FF]"..group["name"].."[#FFFF00]", "[#FFFFFF]"..event.player:getName()));
					player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "grant.success"));
				end
			else
				event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "grant.error"));
			end
		else
			event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.notinarea"));
		end
	else
		event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.usage", "grant", "<group> [playername]"));
	end
end


local function areaRevoke(event, args, flags)
	if #args < 2 then
		local areaId = event.player:getAttribute("areaId");

		if areaId then
			local player = args[1] and server:findPlayerByName(args[1]) or event.player;

			if not player then
				event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.unknown.player"));
			elseif revokePlayerRights(event.player, areas[areaId], player) then
				print(event.player:getName() .." revoked \"".. areas[areaId]["name"] .."\" from area");

				hideAreaBoundaries(player, areaId);
				updateAreaLabel(player);

				if player:getDBID() == event.player:getDBID() then
					event.player:sendTextMessage("[#00FF00]"..i18n.t(event.player, "revoke.success.self"));
				else
					player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "revoke.success.other", "[#8888FF]"..areas[areaId]["name"].."[#FFFF00]", "[#FFFFFF]"..event.player:getName()));
					player:sendTextMessage("[#FFFF00]"..i18n.t(event.player, "revoke.success"));
				end
			else

			end
		else
			event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.notinarea"));
		end
	else
		event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.usage", "revoke", "[playername]"));
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

  if #args >= 1 then

    if string.lower(args[1]) == "/area" then
      -- command handled
      event:setCancel(true);

      local cmd = string.lower(args[2] or "");

      if cmd == "help" then
      	areaHelp(event, table.slice(args, 3));
			elseif cmd == "show" then
				showAllAreaBoundaries(event.player);
			elseif cmd == "hide" then
				hideAllAreaBoundaries(event.player);
			--- Note working right now, missing some API...
			--elseif cmd == "info" then
			--	if checkPlayerAccess(event.player, "info") then areaInfo(event, table.slice(args, 3)); end;
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
				event.player:sendTextMessage("[#FF0000]"..i18n.t(event.player, "error.unknown.command"));
			end
		end
	end
end
addEvent("PlayerCommand", onPlayerCommand);
