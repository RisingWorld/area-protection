

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
      createdAt           = result:getString("createdAt"),
      modifiedBy          = result:getInt("modifiedBy"),
      modifiedAt          = result:getString("modifiedAt"),

      rights = loadRights(result:getInt("id"))
    };

    calculateGlobalAreaPosition(area);
    areas[area["id"]] = area;
    --table.insert(areas, result:getInt("ID"), area);
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
function getCurrentArea(chunkoffsetx, chunkoffsety, chunkoffsetz, blockpositionx, blockpositiony, blockpositionz)
  local area = nil;
  for key,value in pairs(areas) do
    if AreaUtils:isPointInArea3D(chunkoffsetx, chunkoffsety, chunkoffsetz, blockpositionx, blockpositiony, blockpositionz, value["startChunkpositionX"], value["startChunkpositionY"], value["startChunkpositionZ"], value["startBlockpositionX"], value["startBlockpositionY"], value["startBlockpositionZ"], value["endChunkpositionX"], value["endChunkpositionY"], value["endChunkpositionZ"], value["endBlockpositionX"], value["endBlockpositionY"], value["endBlockpositionZ"]) then
      if (area == nil) or
         (value["globalStartPositionX"] >= area["globalStartPositionX"] and value["globalStartPositionY"] >= area["globalStartPositionY"] and value["globalStartPositionZ"] >= area["globalStartPositionZ"] and value["globalEndPositionX"] <= area["globalEndPositionX"] and value["globalEndPositionY"] <= area["globalEndPositionY"] and value["globalEndPositionZ"] <= area["globalEndPositionZ"]) then
        area = value;
      end
    end
  end
  return area;
end
