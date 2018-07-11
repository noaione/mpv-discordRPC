local discordRPC = require("discordRPC")
local appId = "441537954259664896" --Do not change this, or it will broke

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

	if seconds == nil or seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end

local function mpvdrpc()
	--get filename/metadata
	local audioformats = { 'aac', 'aax', 'act', 'aiff', 'amr', 'ape', 'au', 'awb', 'dct', 'dss', 'dvf', 'flac', 'gsm', 'm4a', 'm4b', 'm4p', 'mp3', 'mpc', 'ogg', 'oga', 'mogg', 'opus', 'ra', 'rm', 'tta', 'vox', 'wav', 'wma' } -- Copied from wikipedia page
	ff = mp.get_property("file-format")
	ff = tostring(ff)
	for _,v in pairs(audioformats) do
		if v == ff then
			print('### Music')
			songtitle = mp.get_property("media-title")
			songtitle = songtitle..'.'..ff
			artist = mp.get_property_native("metadata/by-key/Artist")
			if songtitle ~= nil then
				filename = songtitle
			end
			if artist ~= nil then
				filename = ("%s - %s"):format(artist, filename)
			end
			playmode = "song"
			break
		else
			filename = mp.get_property("filename/no-ext")
			filename = tostring(filename)
			playmode = "video"
			if filename:find "http" then
				print('### Internet video')
				filename = mp.get_property("media-title")
			else
				print('### Local video')
			end
		end
	end
	
	fileTextLength = string.len(filename)
	
	--get length of the filename/metadata (for checking if it reach maximum character)
	if fileTextLength > 127 then
		if playmode == "song" then
			songtitle = mp.get_property("media-title")
			filename = songtitle..'.'..ff
		elseif playmode == "video" then
			delete = fileTextLength - 127
			filename = string.sub(filename, delete)
		end
	end
	
	-- get time
	timenow = os.time(os.date("*t"))
	timeen = mp.get_property("time-pos")
	timeen = os.time(os.date("*t", timeen))
	total = mp.get_property("duration")
	total = SecondsToClock(total)
	remain = SecondsToClock(timeen)
	
	-- get chapter
	chapCurrent = mp.get_property("chapter")
	chapTotal = mp.get_property("chapters")
	if (tostring(chapCurrent) == 'nil' and tostring(chapTotal) == 'nil') or tostring(chapCurrent) == 'nil' or tostring(chapTotal) == 'nil' then
		chapTotal = '1'
		chapCurrent = '1'
		chapterNow = ("%s/%s"):format(tostring(chapCurrent), tostring(chapTotal))
	else
		chapName = tostring(mp.get_property(string.format("chapter-list/%s/title", tonumber(chapCurrent))))
		chapterNow = ("%s/%s - %s"):format(tostring(tonumber(chapCurrent)+1), tostring(tonumber(chapTotal)+1), tostring(chapName))
	end

	-- get state
	eof = mp.get_property_bool("eof-reached")
	idling = mp.get_property_bool("idle-active")
	pause = mp.get_property_bool("pause")
	stateimage = "play"
	statetext = ("Playing (%s)"):format(chapterNow)
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
			startTimestamp = timenow - timeen,
			largeImageKey = "mpvlogo",
			largeImageText = "mpv Media Player",
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
	elseif status == "paused" then
		presence = {
			state = state,
			details = filename,
			largeImageKey = "mpvlogo",
			largeImageText = "mpv Media Player",
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
	elseif status == "idle" then
		presence = {
			details = state,
			smallImageKey = stateimage,
			smallImageText = statetext,
			largeImageKey = "mpvlogo",
			largeImageText = "mpv Media Player",
		}
	end
	
	-- Pring Debug part (disable with double dash)
	print("Loaded File: "..filename)
	print("File Format: "..ff)
	print(string.format("Chapter: %s", chapterNow))
	print("Total Time (In Seconds): "..total)
	print("Current State: "..status)
	
	discordRPC.updatePresence(presence) -- Send everything \o/
end


mp.add_periodic_timer(1, mpvdrpc) -- set as 1 but repeat every 15 seconds
