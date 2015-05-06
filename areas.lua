
areas = {};


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
      modifiedAt          = parseDateTime(result:getString("modifiedAt")),

      rights = loadRights(result:getInt("id"))
    };

    calculateGlobalAreaPosition(area);
    areas[area["id"]] = area;
  end
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


--- Return the color of an area for the given player. The color returned will be
--- a variant of the color defined for the player's group.
-- @param player  The target player
-- @param area    The area to return the color
-- @return The color as a number (0xRRGGBBAA)
function getAreaColor(player, area)
  local group = getPlayerGroupInArea(player, area);
  local hueOffset = math.random(-10, 10);  -- delta angle in degrees
  local lightness = 0.8 + (math.random() * 0.4); -- multiplier (pivot = 1.0)
  local a = math.random(90, 120);   -- 0 .. 255

  --local r1, g1, b1 = group["areaColor"]:toRGB();
  local color = group["areaColor"]:hueOffset(hueOffset):lightenBy(lightness);
  local r, g, b = color:toRGB();

  --print("Get area color "..
  --  group["areaColor"].H ..",".. group["areaColor"].S ..",".. group["areaColor"].L .." ("..
  --    math.floor(r1*255) ..",".. math.floor(g1*255) ..",".. math.floor(b1*255) ..",".. a ..")"..
  --  " to Hue:".. hueOffset .." and Lightness:".. lightness .." = "..
  --  color.H ..",".. color.S ..",".. color.L .." ("..
  --    math.floor(r*255) ..",".. math.floor(g*255) ..",".. math.floor(b*255) ..",".. a .. ")");

  return (math.floor(r*255) * 16777216) + (math.floor(g*255) * 65536) + (math.floor(b*255) * 256) + a;
end



--- Update the current area for the given player. If the current area cannot be
--- updated (ex: due to some restriction), the function returns false. Otherwise,
--- it will return true
-- @param player   the player to update area base on it's position
-- @return boolean
function updateCurrentArea(player)
  local areaChanged = false;
  local areaId = player:getAttribute("areaId");
  local areaGroup = player:getAttribute("areaGroup");
  local playerAreas = player:getAttribute("areas");
  local label = player:getAttribute("areaLabel");
  local group;

  for key,value in pairs(areas) do
    if AreaUtils:isPointInArea3D(player:getPosition(), value["startChunkpositionX"], value["startChunkpositionY"], value["startChunkpositionZ"], value["startBlockpositionX"], value["startBlockpositionY"], value["startBlockpositionZ"], value["endChunkpositionX"], value["endChunkpositionY"], value["endChunkpositionZ"], value["endBlockpositionX"], value["endBlockpositionY"], value["endBlockpositionZ"]) then
      group = value["rights"][player:getDBID()] or defaultGroup;

      if table.contains(playerAreas, key) == false then
        if group["CanEnter"] == false then
          -- TODO: if player is inside area (i.e. teleport), move player outside now
          return false;
        end

        -- entering area
        areaId = key;
        areaGroup = group;
        areaChanged = true;
        table.insert(playerAreas, key); -- push area on top of stack
      end

    elseif areaId and (areaId == key) then
      -- we moved out of the current area

      if areaGroup["CanLeave"] == false then
        return false;
      else
        local stop = false;

        areaId = nil;
        areaGroup = nil;
        areaChanged = true;
        table.removeAll(playerAreas, key);

        while stop ~= true and #playerAreas > 0 do
          if areas[playerAreas[#playerAreas]] ~= nil then
            areaId = playerAreas[#playerAreas];
            areaGroup = areas[areaId]["rights"][player:getDBID()] or defaultGroup;
            stop = true;
          else
            table.remove(playerAreas);  -- pop area off the stack
          end
        end
      end
    end
  end

  if areaChanged == true then
    if areaId then
      label:setText(areas[areaId]["name"]);
      label:setVisible(true);
    else
      label:setText("");
      label:setVisible(false);
    end

    player:setAttribute("areaId", areaId);
    player:setAttribute("areaGroup", areaGroup);
    player:setAttribute("areas", playerAreas);
  end

  return true;
end