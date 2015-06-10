


--- Load the rights for a given area id. The rights is a table of player ids
--- and their defined group and assigned information (who? and when?)
-- @param areaId  the area id to load it's rights
-- @return table  the rights to the given area id
function loadRights(areaId)
  local rights = {};
  local result = database:query("SELECT * FROM rights WHERE areaId="..areaId);

  while result:next() do
    rights[result:getInt("playerId")] = {
      group      = getGroupByName(result:getString("groupName")) or defaultGroup,
      assignedBy = result:getInt("assignedBy"),
      assignedAt = parseDateTime(result:getString("assignedAt"))
    };
  end

  return rights;
end



--- Grant a group to the target player in the specified area
-- @param player  The player who's granting rights
-- @param area    The target area
-- @param targetPlayer  The player who's given rights to
-- @param group   The group the target player is being assigned
-- @return True if the player as successfully assigned
function grantPlayerRights(player, area, targetPlayer, group)
  local playerGroup = getPlayerGroupInArea(player, area);

  if player:isAdmin() or (playerGroup and table.contains(playerGroup["group"]["assignableGroups"], group["name"])) then

    -- revoke any rights, first (prevent duplicate entries)
    if revokePlayerRights(player, area, targetPlayer) then

      area["rights"][targetPlayer:getDBID()] = {
        group      = group,
        assignedBy = player:getDBID(),
        assignedAt = os.time()
      };

      -- make sure we cleanup first!
      database:queryupdate("DELETE FROM rights "..
        "WHERE areaId = ".. area["id"] .." AND playerId = ".. targetPlayer:getDBID());

      return database:queryupdate("INSERT INTO rights (areaId, playerId, groupName, assignedBy, assignedAt) "..
        "VALUES (".. area["id"] ..", ".. targetPlayer:getDBID() ..", '".. group["name"] .. "', ".. player:getDBID() ..", CURRENT_TIMESTAMP)");
    end
  end

  return false;
end


--- Revoke any right to the target player in the specified area
-- @param player  The player who's revoking rights
-- @param area    The target area
-- @param targetPlayer  The player who's rights are being revoked
-- @return True if all rights have been revoked.
function revokePlayerRights(player, area, targetPlayer)
  local playerGroup = getPlayerGroupInArea(player, area);
  local targetPlayerGroup = getPlayerGroupInArea(targetPlayer, area);

  if player:isAdmin() or (playerGroup and targetPlayerGroup and table.contains(playerGroup["group"]["assignableGroups"], targetPlayerGroup["group"]["name"])) then

    area["rights"][targetPlayer:getDBID()] = nil;

    return database:queryupdate("DELETE FROM rights "..
      "WHERE areaId = ".. area["id"] .." AND playerId = ".. targetPlayer:getDBID());
  end

  return false;
end


--- Revoke all rights to a given group in the specified area
-- @param player     The player who's revoking all rights
-- @param area       The target area
-- @param groupName  The group name that is being revoked
-- @return table     A table of all user IDs revoked
function revokeAllRights(player, area, groupName)
  local playerGroup = getPlayerGroupInArea(player, area);
  local group = getGroupByName(groupName);
  local playersRemoved = {};

  if player:isAdmin() or (playerGroup and group and table.contains(playerGroup["group"]["assignableGroups"], group["name"])) then
    for targetPlayerDBID,targetGroup in pairs(area["rights"]) do
      if targetGroup["name"] == group["name"] then
        table.insert(playersRemoved, targetPlayerDBID);
      end
    end
  end

  for i = 1, #playersRemoved do
    area["rights"][playersRemoved] = nil;
  end

  -- cleanup
  database:queryupdate("DELETE FROM rights "..
      "WHERE areaId = ".. area["id"] .." AND playerId IN (".. table.concat(playersRemoved, ",") ..")");

  return playersRemoved;
end