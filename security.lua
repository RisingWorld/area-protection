

function checkPlayerAccess(player, permission)
  if player:isAdmin() == false then
    player:sendTextMessage("[#FF0000]"..i18n.t(player, "error.restricted"));
    return false;
  else
    return true
  end
end
