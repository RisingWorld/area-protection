
areas = {};

-- The base area id value when calling player:createArea
local baseAreaId = 1000000;

local DEFAULT_AREA_COLOR = Color.new(0, 0.1, 0.5); -- grey



--- Return the color of an area for the given group. The color returned will be
--- a variant of the color defined for the player's group.
-- @param group   the group to return the color for
-- @return The color as a number (0xRRGGBBAA)
local function getAreaColor(player, area)
  local group = getPlayerGroupInArea(player, area);
  local hueOffset = math.random(-20, 20);  -- delta angle in degrees
  local lightness = 0.7 + (math.random() * 0.6); -- multiplier (pivot = 1.0)
  local a = math.random(90, 190);   -- 0 .. 255

  --local r1, g1, b1 = group["areaColor"]:toRGB();
  local color = (group and group["areaColor"] or DEFAULT_AREA_COLOR):hueOffset(hueOffset):lightenBy(lightness);
  local r, g, b = color:toRGB();

  --print("Get area color "..
  --  group["areaColor"].H ..",".. group["areaColor"].S ..",".. group["areaColor"].L .." ("..
  --    math.floor(r1*255) ..",".. math.floor(g1*255) ..",".. math.floor(b1*255) ..",".. a ..")"..
  --  " to Hue:".. hueOffset .." and Lightness:".. lightness .." = "..
  --  color.H ..",".. color.S ..",".. color.L .." ("..
  --    math.floor(r*255) ..",".. math.floor(g*255) ..",".. math.floor(b*255) ..",".. a .. ")");

  -- 32-bit integer : rrrrrrrr gggggggg bbbbbbbb aaaaaaaa
  return (math.floor(r*255) * 16777216) + (math.floor(g*255) * 65536) + (math.floor(b*255) * 256) + a;
end


--- Calculates the "global" start- and endposition of an area.
-- @param area The area object
local function calculateGlobalAreaPosition(area)
  area["globalStartPositionX"] = ChunkUtils:getGlobalBlockPositionX(area["startChunkpositionX"], area["startBlockpositionX"]);
  area["globalStartPositionY"] = ChunkUtils:getGlobalBlockPositionY(area["startChunkpositionY"], area["startBlockpositionY"]);
  area["globalStartPositionZ"] = ChunkUtils:getGlobalBlockPositionZ(area["startChunkpositionZ"], area["startBlockpositionZ"]);
  area["globalEndPositionX"]   = ChunkUtils:getGlobalBlockPositionX(area["endChunkpositionX"], area["endBlockpositionX"]);
  area["globalEndPositionY"]   = ChunkUtils:getGlobalBlockPositionY(area["endChunkpositionY"], area["endBlockpositionY"]);
  area["globalEndPositionZ"]   = ChunkUtils:getGlobalBlockPositionZ(area["endChunkpositionZ"], area["endBlockpositionZ"]);
end


--- Adjusts the position values of an area.
--- I.e. the start- and endposition will be swapped, if the
--- endposition is smaller than the startposition.
-- @param area The area object
local function adjustAreaPositions(area)
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


--- Returns true if any point of area 1 is inside area 2
-- @param a1 The area id 1
-- @param a2 The area id 2
-- @return True if any point of area 1 is inside area 2
local function areaComparator(a1, a2)
  local area1 = areas[a1];
  local area2 = areas[a2];

  return AreaUtils:isPointInArea3D(area1["startChunkpositionX"], area1["startChunkpositionY"], area1["startChunkpositionZ"], area1["startBlockpositionX"], area1["startBlockpositionY"], area1["startBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["endChunkpositionX"], area1["endChunkpositionY"], area1["endChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["startChunkpositionX"], area1["endChunkpositionY"], area1["startChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["endChunkpositionX"], area1["startChunkpositionY"], area1["endChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["startChunkpositionX"], area1["endChunkpositionY"], area1["endChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["endChunkpositionX"], area1["endChunkpositionY"], area1["startChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["startChunkpositionX"], area1["startChunkpositionY"], area1["endChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]) or
         AreaUtils:isPointInArea3D(area1["endChunkpositionX"], area1["startChunkpositionY"], area1["startChunkpositionZ"], area1["endBlockpositionX"], area1["endBlockpositionY"], area1["endBlockpositionZ"], area2["startChunkpositionX"], area2["startChunkpositionY"], area2["startChunkpositionZ"], area2["startBlockpositionX"], area2["startBlockpositionY"], area2["startBlockpositionZ"], area2["endChunkpositionX"], area2["endChunkpositionY"], area2["endChunkpositionZ"], area2["endBlockpositionX"], area2["endBlockpositionY"], area2["endBlockpositionZ"]);
end


--- Load all areas from the database and store them in the global areas object
function loadAreas()
  local result = database:query("SELECT * FROM areas;");

  areas = {};  -- reset areas

  while result:next() do
    local area = {
      id                  = result:getInt("id"),

      name                = result:getString("name"),

      startChunkpositionX = result:getInt("startChunkpositionX"),
      startChunkpositionY = result:getInt("startChunkpositionY"),
      startChunkpositionZ = result:getInt("startChunkpositionZ"),
      startBlockpositionX = result:getInt("startBlockpositionX"),
      startBlockpositionY = result:getInt("startBlockpositionY"),
      startBlockpositionZ = result:getInt("startBlockpositionZ"),

      endChunkpositionX   = result:getInt("endChunkpositionX"),
      endChunkpositionY   = result:getInt("endChunkpositionY"),
      endChunkpositionZ   = result:getInt("endChunkpositionZ"),
      endBlockpositionX   = result:getInt("endBlockpositionX"),
      endBlockpositionY   = result:getInt("endBlockpositionY"),
      endBlockpositionZ   = result:getInt("endBlockpositionZ"),

      createdBy           = result:getInt("createdBy"),
      createdAt           = parseDateTime(result:getString("createdAt")),
      modifiedBy          = result:getInt("modifiedBy"),
      modifiedAt          = parseDateTime(result:getString("modifiedAt"))
    };

    calculateGlobalAreaPosition(area);
    areas[area["id"]] = area;

    print("Area loaded : ".. area["name"] .." (".. area["id"] ..")");
  end

  -- loading rights
  -- NOTE : couldn't do that while loading areas because it creates conflicts
  --        when using more than one resultset at the same time.
  for areaId,area in pairs(areas) do
    area["rights"] = loadRights(areaId);
  end
end


--- Returns the area at the provided position.
-- @param chunkoffsetx The X offset position of the chunk
-- @param chunkoffsety The Y offset position of the chunk
-- @param chunkoffsetz The Z offset position of the chunk
-- @param blockpositionx The X blockposition within the chunk
-- @param blockpositiony The Y blockposition within the chunk
-- @param blockpositionz The Z blockposition within the chunk
-- @return The area at the provided position, or nil if no area was found
function getAreaAtPosition(chunkoffsetx, chunkoffsety, chunkoffsetz, blockpositionx, blockpositiony, blockpositionz)
  local targetArea = nil;

  for areaId,area in pairs(areas) do
    if AreaUtils:isPointInArea3D(chunkoffsetx, chunkoffsety, chunkoffsetz, blockpositionx, blockpositiony, blockpositionz, area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"]) then
      if not targetArea or
         (area["globalStartPositionX"] >= targetArea["globalStartPositionX"] and area["globalStartPositionY"] >= targetArea["globalStartPositionY"] and area["globalStartPositionZ"] >= targetArea["globalStartPositionZ"] and area["globalEndPositionX"] <= targetArea["globalEndPositionX"] and area["globalEndPositionY"] <= targetArea["globalEndPositionY"] and area["globalEndPositionZ"] <= targetArea["globalEndPositionZ"]) then
        targetArea = area;
      end
    end
  end

  return targetArea;
end


--- Create a new area with the given name.
-- @param event   The marking event status
-- @param name    The area name
function createArea(event, name)
  local playerId = event.player:getDBID();
  local area = {
    name = name,

    startChunkpositionX = event.startChunkpositionX,
    startChunkpositionY = event.startChunkpositionY,
    startChunkpositionZ = event.startChunkpositionZ,
    startBlockpositionX = event.startBlockpositionX,
    startBlockpositionY = event.startBlockpositionY,
    startBlockpositionZ = event.startBlockpositionZ,

    endChunkpositionX = event.endChunkpositionX,
    endChunkpositionY = event.endChunkpositionY,
    endChunkpositionZ = event.endChunkpositionZ,
    endBlockpositionX = event.endBlockpositionX,
    endBlockpositionY = event.endBlockpositionY,
    endBlockpositionZ = event.endBlockpositionZ,

    rights = {},

    createdBy = playerId,
    createdAt = os.time(),
    modifiedBy = playerId,
    modifiedAt = os.time()
  };

  adjustAreaPositions(area);
  calculateGlobalAreaPosition(area);

  database:queryupdate("INSERT INTO areas (name, startChunkpositionX, startChunkpositionY, startChunkpositionZ, startBlockpositionX, startBlockpositionY, startBlockpositionZ, endChunkpositionX, endChunkpositionY, endChunkpositionZ, endBlockpositionX, endBlockpositionY, endBlockpositionZ, createdBy, createdAt, modifiedBy, modifiedAt) VALUES ('".. string.sub(event.command, 13) .."', '".. area["startChunkpositionX"] .."', '".. area["startChunkpositionY"] .."', '".. area["startChunkpositionZ"] .."', '".. area["startBlockpositionX"] .."', '".. area["startBlockpositionY"] .."', '".. area["startBlockpositionZ"] .."', '".. area["endChunkpositionX"] .."', '".. area["endChunkpositionY"] .."', '".. area["endChunkpositionZ"] .."', '".. area["endBlockpositionX"] .."', '".. area["endBlockpositionY"] .."', '".. area["endBlockpositionZ"] .."', '".. playerId .."', CURRENT_TIMESTAMP, '".. playerId .."', CURRENT_TIMESTAMP)");

  local insertID = database:getLastInsertID();

  area["id"] = insertID;

  areas[insertID] = area;

  return insertID;
end



--- Update the current area for the given player. If the current area cannot be
--- updated (ex: due to some restriction), the function returns false. Otherwise,
--- it will return true
-- @param player   the player to update area base on it's position
-- @return boolean
function updateCurrentArea(player)
  local areaChanged = false;
  local areaId = player:getAttribute("areaId");
  local playerAreas = player:getAttribute("areas");

  if areaId and not areas[areaId] then
    areaId = nil;
    areaChanged = true;
  end

  for key,value in pairs(areas) do
    local group = getPlayerGroupInArea(player, area);
    local isPlayerArea = table.contains(playerAreas, key);
    local isInside = AreaUtils:isPointInArea3D(player:getPosition(), value["startChunkpositionX"], value["startChunkpositionY"], value["startChunkpositionZ"], value["startBlockpositionX"], value["startBlockpositionY"], value["startBlockpositionZ"], value["endChunkpositionX"], value["endChunkpositionY"], value["endChunkpositionZ"], value["endBlockpositionX"], value["endBlockpositionY"], value["endBlockpositionZ"]);

    if isPlayerArea == false and isInside == true then

      if group and group["canEnter"] == false then
        -- TODO: if player is inside area (i.e. teleport), move player outside now

        player:sendYellMessage(i18n.t(event.player, "area.enter.restricted"))
        return false;
      end

      -- entering area
      areaId = key;
      areaChanged = true;
      table.insert(playerAreas, key); -- push area on top of stack
      table.sort(playerAreas, areaComparator);

    elseif isPlayerArea == true and isInside == false then
      -- we moved out of the current area

      if (areaId == key) and group and (group["canLeave"] == false) then
        -- TODO: hurt player and/or push back??

        player:sendYellMessage(i18n.t(event.player, "area.exit.restricted"))
        return false;
      else
        local stop = false;

        areaId = nil;
        areaChanged = true;
        table.removeAll(playerAreas, key);

        while stop ~= true and #playerAreas > 0 do
          if areas[playerAreas[#playerAreas]] ~= nil then
            areaId = playerAreas[#playerAreas];
            stop = true;
          else
            table.remove(playerAreas);  -- pop area off the stack
          end
        end
      end

    end
  end

  if areaChanged == true then
    player:setAttribute("areaId", areaId);
    player:setAttribute("areas", playerAreas);

    updateAreaLabel(player);
  end

  return true;
end


--- Update the label displaying the current area
-- @param player The player to update
function updateAreaLabel(player)
  local areaId = player:getAttribute("areaId");
  local label = player:getAttribute("areaLabel");

  if areaId then
    local group = getPlayerGroupInArea(player, areas[areaId]);

    label:setText(areas[areaId]["name"] .. (group and (" [".. group["name"] .."]") or ""));
    label:setVisible(true);
  else
    label:setText("");
    label:setVisible(false);
  end
end



--- Remove the specified area from the world
-- @param areaId  The id of the area to remove
-- @return True
function removeArea(areaId)
  database:queryupdate("DELETE FROM areas WHERE id='" .. areaId .. "'");
  database:queryupdate("DELETE FROM rights WHERE areaId= '" .. areaId .. "'");

  areas[areaId] = nil;

  return true;
end


--- Show all areas to the given player
-- @param player The player to show all areas
function showAllAreaBoundaries(player)
  local areasVisible = player:getAttribute("areasVisible");

  if areasVisible ~= true then
    local playerAreas = {};

    areasVisible = {};

    for key,area in pairs(areas) do
      local areaId = baseAreaId + area["id"];

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

        getAreaColor(player, area)
      });
    end

    --print("Showing ".. #playerAreas .." areas to ".. player:getName());

    player:setAttribute("areasVisible", true);
    player:createAreas(playerAreas);
    player:showAreas(areasVisible);
  end
end


--- Hide all areas from the given player
-- @param player The player to hide all areas
function hideAllAreaBoundaries(player)
  local areasVisible = player:getAttribute("areasVisible");

  if areasVisible == true then
    local areaIds = {};

    for key,area in pairs(areas) do
      table.insert(areaIds, baseAreaId + area["id"]);
    end

    --print("Hiding all areas from ".. player:getName());

    player:setAttribute("areasVisible", false);
    player:destroyAreas(areaIds);
  end
end


--- Show the given area for the given player. If the area is already visible,
--- it will be refreshed
-- @param player The player to show the area to
-- @param area The area to show
function showAreaBoundaries(player, area)
  local areasVisible = player:getAttribute("areasVisible");

  if areasVisible == true then
    player:destroyArea(baseAreaId + area["id"]);
    player:createArea(baseAreaId + area["id"], area["startChunkpositionX"], area["startChunkpositionY"], area["startChunkpositionZ"], area["startBlockpositionX"], area["startBlockpositionY"], area["startBlockpositionZ"], area["endChunkpositionX"], area["endChunkpositionY"], area["endChunkpositionZ"], area["endBlockpositionX"], area["endBlockpositionY"], area["endBlockpositionZ"], getAreaColor(player, area));
    player:showArea(baseAreaId + area["id"]);
  end
end


--- Hide the given area from the given player.
-- @param player The player to hide the area from
-- @param areaId The area id to hide
function hideAreaBoundaries(player, areaId)
  local areasVisible = player:getAttribute("areasVisible");

  if areasVisible == true then
    player:destroyArea(baseAreaId + areaId);
  end
end



--- Get information about the area. The amount of information returned depends
--- on which group the specified player belongs to.
-- @param player The player to return the information for
-- @param area The area to return information from
-- @return table An array of strings
function getAreaInfo(player, area)

  -- TODO: fix this damn piece of code
  -- TODO: restrict amount of information based on player group in the area

  local areaCreatedBy = server:findPlayerByID(area["createdBy"]); --- return nil ????
  local areaCreatedAt = area["createdAt"] and os.date("%Y-%m-%d", area["createdAt"]) or "n/a";

  local info = {
    "\"".. area["name"] .."\" was created on ".. areaCreatedAt .." by ".. areaCreatedBy:getName()
  };

  for playerId,areaGroup in pairs(area["rights"]) do
    local assignedPlayer = server:findPlayerByID(playerId):getName();   --- ERROR calling getName() on nil ????
    local assignedByPlayer = areaGroup["assignedBy"] and server:findPlayerByID(areaGroup["assignedBy"]):getName() or "n/a";
    local assignedDate = areaGroup["assignedAt"] and os.date("%Y-%m-%d", areaGroup["assignedAt"]) or "n/a";

    -- TODO : do not show by who or when if the player is member of a "lesser" group

    table.insert(info, assignedPlayer["name"] .." was granted ".. areaGroup["group"]["name"] .." by ".. assignedByPlayer["name"] .." on ".. assignedDate);
  end

  return info;
end