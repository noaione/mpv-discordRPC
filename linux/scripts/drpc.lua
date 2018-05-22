local discordRPC = require("discordRPC")
local appId = "441537954259664896" --Do not change this, or it will broke
local count = 1

function discordRPC.ready(userId, username, discriminator, avatar)
    print(string.format("Discord: ready (%s, %s, %s, %s)", userId, username, discriminator, avatar))
end

function discordRPC.disconnected(errorCode, message)
    print(string.format("Discord: disconnected (%d: %s)", errorCode, message))
end

function discordRPC.errored(errorCode, message)
    print(string.format("Discord: error (%d: %s)", errorCode, message))
end

function SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds == nil then
		return "00:00:00";
	elseif seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end

local function discordrpc()
	ff = mp.get_property("file-format")
	ff = tostring(ff)
	if ff == "mp3" or ff == "flac" or ff == "m4a" or ff == "wav" or ff == "dts" then
		filename = mp.get_property("media-title")
		filename = tostring(filename)
		filename = filename.."."..ff
	else
		filename = mp.get_property("filename/no-ext")
		filename = tostring(filename)
	end
	file = "file"
	if filename == "nil" then
		filename = "Idling"
		file = "nofile"
	end
	
	-- get time
	timenow = os.time(os.date("*t"))
	timest = os.time(os.date("*t", timest))
	timeen = mp.get_property("playtime-remaining")
	timeen = os.time(os.date("*t", timeen))
	total = mp.get_property("duration")
	total = SecondsToClock(total)
	remain = SecondsToClock(timeen)
	
	-- get state
	state = mp.get_property("core-idle")
	state = tostring(state)
	if state == "yes" then
		stateimage = "pause"
		statetext = "Paused (" ..remain.. " Left)"
		detailstext = "Paused (" ..total.. ")"
	elseif state == "no" then
		stateimage = "play"
		statetext = "Playing"
		detailstext = "Playing (" ..total.. ")"
	end
	if file == "file" then
		stateimage = stateimage
		detailstext = detailstext
		statetext = statetext
	elseif file == "nofile" then
		stateimage = "idle"
		statetext = "Idle"
		detailstext = ""
	end
	
	-- init rpc and send
	discordRPC.initialize(appId, true)
	if state == "no" then
		presence = {
			state = detailstext,
			details = filename,
			startTimestamp = timenow,
			endTimestamp = timenow + timeen,
			largeImageKey = "mpvlogo",
			largeImageText = "mpv Media player",
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
	elseif state == "yes" or file == "nofile" then
		presence = {
			state = detailstext,
			details = filename,
			largeImageKey = "mpvlogo",
			largeImageText = "mpv Media player",
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
	end
	nextPresenceUpdate = 0
	
	-- Pring Debug part (disable with double dash)
	print("Now Playing: "..filename)
	print("File Format: "..ff)
	print("Total Time (In Seconds): "..total)
	print("Current State: "..statetext)
	
	discordRPC.updatePresence(presence)
	--discordRPC.updatePresence(presence)
end


mp.add_periodic_timer(1, discordrpc) -- set as 1 but repeat every 15 seconds(?)
