

--- The list of allowed permissions (other validations may restrict
--- the player later on).
local permissions = {
  grant = true,
  revoke = true
}


--- Returns true if the player can have access to the specified permission
-- @param player     The player
-- @param permission The permission
-- @return If the player has access (true) or no (false)
function checkPlayerAccess(player, permission)
  if player:isAdmin() == true or permissions[permission] == true then
    return true
  else
    player:sendTextMessage("[#FF0000]"..i18n.t(player, "error.restricted"));
    return false;
  end
end
