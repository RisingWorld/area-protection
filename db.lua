

database = getDatabase();



--- Initialize the script's database
function initDatabase()
  local result;

  --- 1.x

  -- Create database tables "areas" and "rights" if they don't exist already
  database:queryupdate("CREATE TABLE IF NOT EXISTS 'areas' ( "..
                         "'ID' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                         "'name' VARCHAR, "..
                         "'startChunkpositionX' INTEGER, "..
                         "'startChunkpositionY' INTEGER, "..
                         "'startChunkpositionZ' INTEGER, "..
                         "'startBlockpositionX' INTEGER, "..
                         "'startBlockpositionY' INTEGER, "..
                         "'startBlockpositionZ' INTEGER, "..
                         "'endChunkpositionX' INTEGER, "..
                         "'endChunkpositionY' INTEGER, "..
                         "'endChunkpositionZ' INTEGER, "..
                         "'endBlockpositionX' INTEGER, "..
                         "'endBlockpositionY' INTEGER, "..
                         "'endBlockpositionZ' INTEGER, "..
                         "'playerID' INTEGER);");

  database:queryupdate("CREATE TABLE IF NOT EXISTS 'rights' ( "..
                         "'ID' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                         "'areaID' INTEGER, "..
                         "'playerID' INTEGER, "..
                         "'group' VARCHAR);");

  database:queryupdate("CREATE TABLE IF NOT EXISTS 'chests' ( "..
                         "'ID' INTEGER, "..
                         "'chunkOffsetX' INTEGER, "..
                         "'chunkOffsetY' INTEGER, "..
                         "'chunkOffsetZ' INTEGER, "..
                         "'positionX' INTEGER, "..
                         "'positionY' INTEGER, "..
                         "'positionZ' INTEGER);");

  --- 2.x

  database:queryupdate("CREATE TABLE IF NOT EXISTS 'config' ( "..
                         "'key' VARCHAR PRIMARY KEY, "..
                         "'value' VARCHAR);");

  result = database:query("SELECT `value` FROM `config` WHERE `key` = 'schema.version';");

  update20(result:getInt("value"));

end


--- Remove this function once the script has aged and no one is using a legacy
--- version anymore. Sync initDatabase accordingly.
-- @param currentVersion   pass the current known version
-- @param int              pass the new current version (if changed)
function update20(currentVersion)

  if currentVersion < 20 then

    database:queryupdate("CREATE TABLE IF NOT EXISTS 'areas_tmp' ( "..
                           "'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                           "'name' VARCHAR, "..
                           "'startChunkpositionX' INTEGER, "..
                           "'startChunkpositionY' INTEGER, "..
                           "'startChunkpositionZ' INTEGER, "..
                           "'startBlockpositionX' INTEGER, "..
                           "'startBlockpositionY' INTEGER, "..
                           "'startBlockpositionZ' INTEGER, "..
                           "'endChunkpositionX' INTEGER, "..
                           "'endChunkpositionY' INTEGER, "..
                           "'endChunkpositionZ' INTEGER, "..
                           "'endBlockpositionX' INTEGER, "..
                           "'endBlockpositionY' INTEGER, "..
                           "'endBlockpositionZ' INTEGER, "..
                           "'createdBy' INTEGER, "..
                           "'createdAt' DATETIME, "..
                           "'modifiedBy' INTEGER, "..
                           "'modifiedAt' DATETIME);");
    database:queryupdate("INSERT INTO areas_tmp "..
                           "SELECT ID, name, "..
                                  "startChunkpositionX, startChunkpositionY, startChunkpositionZ, "..
                                  "startBlockpositionX, startBlockpositionY, startBlockpositionZ, "..
                                  "endChunkpositionX, endChunkpositionY, endChunkpositionZ, "..
                                  "endBlockpositionX, endBlockpositionY, endBlockpositionZ, "..
                                  "playerID, NULL, playerID, NULL "..
                            "FROM areas;");
    database:queryupdate("DROP TABLE 'areas';");
    database:queryupdate("ALTER TABLE 'areas_tmp' RENAME TO 'areas';");

    database:queryupdate("CREATE TABLE IF NOT EXISTS 'rights_tmp' ( "..
                           "'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                           "'areaId' INTEGER, "..
                           "'playerId' INTEGER, "..
                           "'group' VARCHAR, "..
                           "'assignedBy' INTEGER, "..
                           "'assignedAt' DATETIME);");
    database:queryupdate("INSERT INTO rights_tmp "..
                           "SELECT ID, areaID, playerID, group, NULL, NULL "..
                             "FROM rights;");
    database:queryupdate("DROP TABLE 'rights';");
    database:queryupdate("ALTER TABLE 'rights_tmp' RENAME TO 'rights';");

    database:queryupdate("DROP TABLE 'chests';");

    database:queryupdate("UPDATE rights "..
                           "SET group = 'landlord' "..
                         "WHERE group = 'Admin' "..
                            "OR group = 'Owner';");


    -- note: we can insert as we assume that before that, no other value was saved
    database:queryupdate("INSERT INTO config (key, value) VALUES ('schema.version', '20');");
    currentVersion = 20;

  end;

  return currentVersion;
end