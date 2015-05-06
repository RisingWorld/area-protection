

local DATE_TIME_PATTERN = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)";


database = getDatabase();


--- Parse a timestamp from string
-- @param datetime   The string in a "yyyy-mm-dd hh:mm:ss" format
-- @return The timestamp integer
function parseDateTime(datetime)
  if not datetime then
    return nil;
  end

  -- Assuming a date pattern like: yyyy-mm-dd hh:mm:ss
  local Y, M, D, h, m, s = datetime:match(DATE_TIME_PATTERN);

  return os.time({year = Y, month = M, day = D, hour = H, min = m, sec = s});
end




local function getSchemaVersion()
  local result = database:query("SELECT value FROM config WHERE conf_key = 'schema.version';");
  if result and result:next() then
    return result:getInt("value");
  else
    return nil;
  end
end

local function setSchemaVersion(version)
  database:queryupdate("REPLACE INTO config (conf_key, value) "..
    "VALUES ('schema.version', "..version..")");
  return version;
end


--- Remove this function once the script has aged and no one is using a legacy
--- version anymore. Sync initDatabase accordingly.
-- @param currentVersion   pass the current known version
-- @param int              pass the new current version (if changed)
function update20(currentVersion)
  local schemaVersion = 20;

  if not currentVersion or currentVersion < schemaVersion then

    print("Upgrading DB to 2.0...");

    database:queryupdate("CREATE TABLE IF NOT EXISTS areas_tmp ( "..
                           "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                           "name VARCHAR, "..
                           "startChunkpositionX INTEGER, "..
                           "startChunkpositionY INTEGER, "..
                           "startChunkpositionZ INTEGER, "..
                           "startBlockpositionX INTEGER, "..
                           "startBlockpositionY INTEGER, "..
                           "startBlockpositionZ INTEGER, "..
                           "endChunkpositionX INTEGER, "..
                           "endChunkpositionY INTEGER, "..
                           "endChunkpositionZ INTEGER, "..
                           "endBlockpositionX INTEGER, "..
                           "endBlockpositionY INTEGER, "..
                           "endBlockpositionZ INTEGER, "..
                           "createdBy INTEGER, "..
                           "createdAt DATETIME, "..
                           "modifiedBy INTEGER, "..
                           "modifiedAt DATETIME);");
    database:queryupdate("INSERT INTO areas_tmp "..
                           "SELECT ID, name, "..
                                  "startChunkpositionX, startChunkpositionY, startChunkpositionZ, "..
                                  "startBlockpositionX, startBlockpositionY, startBlockpositionZ, "..
                                  "endChunkpositionX, endChunkpositionY, endChunkpositionZ, "..
                                  "endBlockpositionX, endBlockpositionY, endBlockpositionZ, "..
                                  "playerID, NULL, playerID, NULL "..
                            "FROM areas;");
    database:queryupdate("DROP TABLE areas;");
    database:queryupdate("ALTER TABLE areas_tmp RENAME TO areas;");

    database:queryupdate("CREATE TABLE IF NOT EXISTS rights_tmp ( "..
                           "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                           "areaId INTEGER, "..
                           "playerId INTEGER, "..
                           "groupName VARCHAR, "..   -- rename from 'group' to stop God's kittens killing frenzy
                           "assignedBy INTEGER, "..
                           "assignedAt DATETIME);");
    database:queryupdate("INSERT INTO rights_tmp "..
                           "SELECT ID, areaID, playerID, 'group', NULL, NULL "..
                             "FROM rights;");
    database:queryupdate("DROP TABLE rights;");
    database:queryupdate("ALTER TABLE rights_tmp RENAME TO rights;");

    database:queryupdate("DROP TABLE chests;");

    -- adjust rights
    database:queryupdate("UPDATE rights "..
                           "SET groupName = 'landlord' "..
                         "WHERE groupName = 'Admin' "..
                            "OR groupName = 'Owner';");


    currentVersion = setSchemaVersion(schemaVersion);
  end;

  return currentVersion;
end



--- Initialize the script's database
function initDatabase()

  --- 1.x

  print("Initializing DB...");

  -- Create database tables "areas" and "rights" if they don't exist already
  database:queryupdate("CREATE TABLE IF NOT EXISTS areas ( "..
                         "ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                         "name VARCHAR, "..
                         "startChunkpositionX INTEGER, "..
                         "startChunkpositionY INTEGER, "..
                         "startChunkpositionZ INTEGER, "..
                         "startBlockpositionX INTEGER, "..
                         "startBlockpositionY INTEGER, "..
                         "startBlockpositionZ INTEGER, "..
                         "endChunkpositionX INTEGER, "..
                         "endChunkpositionY INTEGER, "..
                         "endChunkpositionZ INTEGER, "..
                         "endBlockpositionX INTEGER, "..
                         "endBlockpositionY INTEGER, "..
                         "endBlockpositionZ INTEGER, "..
                         "playerID INTEGER);");

  database:queryupdate("CREATE TABLE IF NOT EXISTS rights ( "..
                         "ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "..
                         "areaID INTEGER, "..
                         "playerID INTEGER, "..
                         "'group' VARCHAR);");   -- God killed too many kittens.... :(

  database:queryupdate("CREATE TABLE IF NOT EXISTS chests ( "..
                         "ID INTEGER, "..
                         "chunkOffsetX INTEGER, "..
                         "chunkOffsetY INTEGER, "..
                         "chunkOffsetZ INTEGER, "..
                         "positionX INTEGER, "..
                         "positionY INTEGER, "..
                         "positionZ INTEGER);");

  --- 2.x

  database:queryupdate("CREATE TABLE IF NOT EXISTS config ( "..
                         "conf_key VARCHAR UNIQUE, "..
                         "value VARCHAR);");

  update20(getSchemaVersion());
end
