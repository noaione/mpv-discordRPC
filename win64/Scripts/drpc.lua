local discordRPC = require("discordRPC")
local appId = "441537954259664896" --Do not change this, or it will broke

function discordRPC.ready()
	print("Discord: ready")
end

function discordRPC.disconnected(errorCode, message)
    print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

function discordRPC.errored(errorCode, message)
    print(string.format("Discord: error (%d: %s)", errorCode, message))
end

local function discordrpc()
	filename = mp.get_property("media-title")
	filename = tostring(filename)
	file = "file"
	print(filename)
	if filename == "nil" then
		filename = "zzz~"
		file = "nofile"
	end
	print(durstr)
	print(posstr)
	-- get state
	state = mp.get_property("core-idle")
	state = tostring(state)
	if state == "yes" then
		stateimage = "pause"
		detailstext = "Paused"
		statetext = "Paused"
	elseif state == "no" then
		stateimage = "play"
		statetext = "Playing"
		detailstext = "Playing"
	end
	if file == "file" then
		stateimage = stateimage
		detailstext = detailstext
		statetext = statetext
	elseif file == "nofile" then
		stateimage = "idle"
		statetext = "Idle"
		detailstext = "Idling"
	end
	local now = os.time(os.date("*t"))
	-- init rpc and send
	discordRPC.initialize(appId, true)
	presence = {
		state = detailstext,
		details = filename,
		largeImageKey = "mpvlogo",
		largeImageText = "mpv Media player",
		smallImageKey = stateimage,
		smallImageText = statetext,
	}
	discordRPC.updatePresence(presence)
end

mp.add_periodic_timer(1, discordrpc) -- set as 1 but repeat every 15 seconds(?)
