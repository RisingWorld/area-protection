
groups = {};
defaultGroup = nil;


--- Custom function to load all groups from a property-file.
-- This function is also used to reload all groups
-- (useful when changing the files during runtime).
function loadGroups(config)
  local groupPath = config:getProperty("groupPath");
  local defaultGroupProperty = config:getProperty("defaultGroup");
  local groupFiles = StringUtils:explode(config:getProperty("groups"), ",");

  groups = {};

  for i = 1, #groupFiles, 1 do
    local groupProperty = getProperty(groupPath .. "/" .. groupFiles[i] .. ".group");
    local group = {
      name                       = groupFiles[i],

      assignableGroups           = StringUtils:explode(groupProperty:getProperty("assignableGroups"), ","),

      areaColor                  = Color.new(groupProperty:getProperty("areaColor")),

      placeObjects               = StringUtils:getBoolean(groupProperty:getProperty("placeObjects")),
      changeObjectStatus         = StringUtils:getBoolean(groupProperty:getProperty("changeObjectStatus")),
      destroyObjects             = StringUtils:getBoolean(groupProperty:getProperty("destroyObjects")),
      removeObjects              = StringUtils:getBoolean(groupProperty:getProperty("removeObjects")),
      pickupObject               = StringUtils:getBoolean(groupProperty:getProperty("pickupObject")),
      objectsPlaceFilter         = StringUtils:explode(groupProperty:getProperty("objectsPlaceFilter"), ","),
      objectsRemoveDestroyFilter = StringUtils:explode(groupProperty:getProperty("objectsRemoveDestroyFilter"), ","),

      placeConstructions         = StringUtils:getBoolean(groupProperty:getProperty("placeConstructions")),
      destroyConstructions       = StringUtils:getBoolean(groupProperty:getProperty("destroyConstructions")),
      removeConstructions        = StringUtils:getBoolean(groupProperty:getProperty("removeConstructions")),
      constructionsFilter        = StringUtils:explode(groupProperty:getProperty("constructionsFilter"), ","),

      placeBlock                 = StringUtils:getBoolean(groupProperty:getProperty("placeBlock")),
      destroyBlock               = StringUtils:getBoolean(groupProperty:getProperty("destroyBlock")),
      blockFilter                = StringUtils:explode(groupProperty:getProperty("blockFilter"), ","),

      fillTerrain                = StringUtils:getBoolean(groupProperty:getProperty("fillWorld")),
      destroyTerrain             = StringUtils:getBoolean(groupProperty:getProperty("destroyWorld")),

      canEnter                   = StringUtils:getBoolean(groupProperty:getProperty("canEnter")),
      canLeave                   = StringUtils:getBoolean(groupProperty:getProperty("canLeave")),

      inventoryToChest           = StringUtils:getBoolean(groupProperty:getProperty("inventoryToChest")),
      chestToInventory           = StringUtils:getBoolean(groupProperty:getProperty("chestToInventory")),
      chestDrop                  = StringUtils:getBoolean(groupProperty:getProperty("chestDrop")),

      placeVegetation            = StringUtils:getBoolean(groupProperty:getProperty("placeVegetation")),
      pickupVegetation           = StringUtils:getBoolean(groupProperty:getProperty("pickupVegetation")),
      removeVegetation           = StringUtils:getBoolean(groupProperty:getProperty("removeVegetation")),
      cutGrass                   = StringUtils:getBoolean(groupProperty:getProperty("cutGrass"))
    };

    --Insert the group into the global groups table
    table.insert(groups, group);

    if group["name"] == defaultGroupProperty then
      defaultGroup = group;
      print("Default Group found \""..defaultGroup["name"].."\"");
    end
    print("Loaded group:\"".. group["name"] .. "\" successfully");
  end

end

--- Returns the group according to a groupname.
-- @param name The name of the group
-- @return The group according to the provided groupname,
-- or nil if no group was found
function getGroupByName(name)
  local group = nil;

  for i = 1, #groups, 1 do
    if groups[i]["name"] == name then
      group = groups[i];
      break;
    end
  end

  return group;
end

--- Returns the player group of a specified area.
-- @param player The player object
-- @param area The area object
-- @return The group of the player in the specified area
function getPlayerGroupInArea(player, area)
  return area and (area["rights"][player:getDBID()] or defaultGroup);
end
