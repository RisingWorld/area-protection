


--- Load the rights for a given area id. The rights is a table of player ids
--- and their defined group and assigned information (who? and when?)
-- @param areaId  the area id to load it's rights
-- @return table  the rights to the given area id
function loadRights(areaId)
  local rights = {};
  local result = database:query("SELECT * FROM rights WHERE areaId='"..areaId.."';");

  while result:next() do
    local group = getGroupByName(result:getString("groupName"));

    if group ~= nil then
      rights[result:getInt("playerId")] = {
        group      = group,
        assignedBy = result:getInt("assignedBy"),
        assignedAt = result:getString("assignedAt")
      };
    end
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
  -- revoke any rights, first (prevent duplicate entries)
  revokePlayerRights(player, area, targetPlayer);

  area["rights"][targetPlayer:getDBID()] = {
    group      = group,
    assignedBy = player:getDBID(),
    assignedAt = os.time()
  };

  return database:queryupdate("INSERT INTO rights (areaId, playerId, groupName, assignedBy, assignedAt) "..
    "VALUES (".. area["id"] ..", ".. targetPlayer:getDBID() ..", '".. group["name"] .. "', ".. player:getDBID() ..", CURRENT_TIMESTAMP)");
end


--- Revoke any right to the target player in the specified area
-- @param player  The player who's revoking rights
-- @param area    The target area
-- @param targetPlayer  The player who's rights are being revoked
-- @return True if all rights have been revoked.
function revokePlayerRights(player, area, targetPlayer)
  area["rights"][targetPlayer:getDBID()] = nil;

  return database:queryupdate("DELETE FROM rights "..
    "WHERE areaId = ".. area["id"] .." AND playerId = ".. targetPlayer:getDBID());
end