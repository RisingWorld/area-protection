-- Global variables
--server = getServer();
--world = getWorld();

-- Includes
include("db.lua");
include("groups.lua");
include("rights.lua");
include("areas.lua");
include("table-ext/table-ext.lua");
include("listener/playerListener.lua");
include("listener/commandListener.lua");


-- Some color definitions
--colors = {0xFFFF00AA, 0xAA00AAAA, 0x1111FFAA, 0xCCCCDDAA, 0x34DD54AA, 0xFF5555AA};

--- Script enable event.
-- This event is triggered when the script is loaded.
-- From this point on, the script gets notified about
-- all events and is able to call serverside functions.
function onEnable()
	local config = getProperty("config.properties");

	initDatabase(config);

	-- Load all groups from property-files
	loadGroups(config);

	-- Receive all saved areas from database and store them in a global table
	loadAreas(config);

	print("Script v2.0 loaded.");
end

--- Script disable event.
-- This event is triggered when the script is unloaded
-- which causes the script to stop.
function onDisable()
	print("Script stopped!");
end

--- Update tick event (frequently called event!)
-- This event is triggered every tick. Use this event
-- to update your script environment, as long as it requires frequent updates.
-- @param event The update event object
-- You can get the current tpf (event:getTpf()) or runningtime from it
--function onUpdate(event)
	--print(server:getGameTimestamp());
	--print("TPF:" .. event:getTpf());
	--print("RUNNINGTIME:" .. event:getRunningTime());
--end
--addEvent("Update", onUpdate);

