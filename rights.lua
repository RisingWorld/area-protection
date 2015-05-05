


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