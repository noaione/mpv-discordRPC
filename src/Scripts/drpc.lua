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
	--get filename
	ff = mp.get_property("file-format")
	ff = tostring(ff)
	if ff == "mp3" or ff == "flac" or ff == "m4a" or ff == "wav" or ff == "dts" then
		taiteru = mp.get_property("media-title")
		taiteru = taiteru..'.'..ff
		artist = mp.get_property_native("metadata/by-key/Artist")
		if taiteru ~= nil then
			filename = taiteru
		end
		if artist ~= nil then
			filename = ("%s - %s"):format(artist, filename)
		end
		formatto = "song"
	else
		filename = mp.get_property("filename/no-ext")
		filename = tostring(filename)
		formatto = "video"
	end
	
	medianame = mp.get_property("media-title")
	medianame = ("Current File: %s"):format(medianame)
	fileTextLength = string.len(filename)
	
	--get length of filename
	if fileTextLength > 127 then
		if formatto == "song" then
			taiteru = mp.get_property("media-title")
			filename = taiteru..'.'..ff
		elseif formatto == "video" then
			delete = fileTextLength - 127
			filename = string.sub(filename, delete)
		end
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
	eof = mp.get_property_bool("eof-reached")
	idling = mp.get_property_bool("idle-active")
	pause = mp.get_property_bool("pause")
	stateimage = "play"
	statetext = "Playing"
	state = "Playing (" ..total.. ")"
	status = "playing"
	if idling or eof then
		statetext = "Idle"
		stateimage = "idle"
		state = "Idling"
		status = "idle"
	elseif pause then
		stateimage = "pause"
		statetext = "Paused (" ..remain.. " left)"
		state = "Paused (" ..total.. ")"
		status = "paused"
	end
	
	-- init rpc and send
	discordRPC.initialize(appId, true)
	if status == "playing" then
		presence = {
			state = state,
			details = filename,
			startTimestamp = timenow,
			endTimestamp = timenow + timeen,
			largeImageKey = "mpvlogo",
			largeImageText = medianame,
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
	elseif status == "paused" then
		presence = {
			state = state,
			details = filename,
			largeImageKey = "mpvlogo",
			largeImageText = medianame,
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
	elseif status == "idle" then
		presence = {
			details = state,
			smallImageKey = stateimage,
			smallImageText = statetext,
			largeImageKey = "mpvlogo",
			largeImageText = "Current File: None",
		}
	end
	
	-- Pring Debug part (disable with double dash)
	print("Loaded File: "..filename)
	print("File Format: "..ff)
	print("Total Time (In Seconds): "..total)
	print("Current State: "..status)
	
	discordRPC.updatePresence(presence)
end


mp.add_periodic_timer(1, discordrpc) -- set as 1 but repeat every 15 seconds(?)
