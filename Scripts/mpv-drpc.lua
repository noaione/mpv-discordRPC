local appId = "470185467959050261" --Do not change this, or it will broke (v2 update)
local opts = require 'mp.options'
local version = '2.1'
drpcStatus = 'active' -- Don't change this

local drpc_opts = {
	playText = "Watching",
	-- Set Playing text for video
	playStreamText = "Streaming",
	-- Set Playing text for streaming
	playMusicText = "Listening",
	-- Set Playing text for Music
	playOtherText = "Viewing",
	-- Set Playing text for image or something else
	pausedText = "Paused",
	-- Set Paused state text
	idlingText = "Idling",
	-- Set Idling state text

	useMediaTitle = "no", -- "yes" or "no"
	-- Use media-title for video not filename/no-ext

	runDRPC = "yes" -- "yes", "no, or "always"
	-- Disable, or enable it
}
opts.read_options(drpc_opts)

-- Merge to one file: https://github.com/pfirsich/lua-discordRPC

local ffi = require "ffi"
local discordRPClib = ffi.load("discord-rpc")
local msg = require 'mp.msg'

ffi.cdef[[
typedef struct DiscordRichPresence {
    const char* state;   /* max 128 bytes */
    const char* details; /* max 128 bytes */
    int64_t startTimestamp;
    int64_t endTimestamp;
    const char* largeImageKey;  /* max 32 bytes */
    const char* largeImageText; /* max 128 bytes */
    const char* smallImageKey;  /* max 32 bytes */
    const char* smallImageText; /* max 128 bytes */
    const char* partyId;        /* max 128 bytes */
    int partySize;
    int partyMax;
    const char* matchSecret;    /* max 128 bytes */
    const char* joinSecret;     /* max 128 bytes */
    const char* spectateSecret; /* max 128 bytes */
    int8_t instance;
} DiscordRichPresence;

typedef struct DiscordUser {
    const char* userId;
    const char* username;
    const char* discriminator;
    const char* avatar;
} DiscordUser;

typedef void (*readyPtr)(const DiscordUser* request);
typedef void (*disconnectedPtr)(int errorCode, const char* message);
typedef void (*erroredPtr)(int errorCode, const char* message);
typedef void (*joinGamePtr)(const char* joinSecret);
typedef void (*spectateGamePtr)(const char* spectateSecret);
typedef void (*joinRequestPtr)(const DiscordUser* request);

typedef struct DiscordEventHandlers {
    readyPtr ready;
    disconnectedPtr disconnected;
    erroredPtr errored;
    joinGamePtr joinGame;
    spectateGamePtr spectateGame;
    joinRequestPtr joinRequest;
} DiscordEventHandlers;

void Discord_Initialize(const char* applicationId,
                        DiscordEventHandlers* handlers,
                        int autoRegister,
                        const char* optionalSteamId);

void Discord_Shutdown(void);

void Discord_RunCallbacks(void);

void Discord_UpdatePresence(const DiscordRichPresence* presence);

void Discord_ClearPresence(void);

void Discord_Respond(const char* userid, int reply);

void Discord_UpdateHandlers(DiscordEventHandlers* handlers);
]]

local discordRPC = {} -- module table

-- proxy to detect garbage collection of the module
discordRPC.gcDummy = newproxy(true)

local function unpackDiscordUser(request)
    return ffi.string(request.userId), ffi.string(request.username),
        ffi.string(request.discriminator), ffi.string(request.avatar)
end

-- callback proxies
-- note: callbacks are not JIT compiled (= SLOW), try to avoid doing performance critical tasks in them
-- luajit.org/ext_ffi_semantics.html
local ready_proxy = ffi.cast("readyPtr", function(request)
    if discordRPC.ready then
        discordRPC.ready(unpackDiscordUser(request))
    end
end)

local disconnected_proxy = ffi.cast("disconnectedPtr", function(errorCode, message)
    if discordRPC.disconnected then
        discordRPC.disconnected(errorCode, ffi.string(message))
    end
end)

local errored_proxy = ffi.cast("erroredPtr", function(errorCode, message)
    if discordRPC.errored then
        discordRPC.errored(errorCode, ffi.string(message))
    end
end)

local joinGame_proxy = ffi.cast("joinGamePtr", function(joinSecret)
    if discordRPC.joinGame then
        discordRPC.joinGame(ffi.string(joinSecret))
    end
end)

local spectateGame_proxy = ffi.cast("spectateGamePtr", function(spectateSecret)
    if discordRPC.spectateGame then
        discordRPC.spectateGame(ffi.string(spectateSecret))
    end
end)

local joinRequest_proxy = ffi.cast("joinRequestPtr", function(request)
    if discordRPC.joinRequest then
        discordRPC.joinRequest(unpackDiscordUser(request))
    end
end)

-- helpers
local function checkArg(arg, argType, argName, func, maybeNil)
    assert(type(arg) == argType or (maybeNil and arg == nil),
        string.format("Argument \"%s\" to function \"%s\" has to be of type \"%s\"",
            argName, func, argType))
end

local function checkStrArg(arg, maxLen, argName, func, maybeNil)
    if maxLen then
        assert(type(arg) == "string" and arg:len() <= maxLen or (maybeNil and arg == nil),
            string.format("Argument \"%s\" of function \"%s\" has to be of type string with maximum length %d",
                argName, func, maxLen))
    else
        checkArg(arg, "string", argName, func, true)
    end
end

local function checkIntArg(arg, maxBits, argName, func, maybeNil)
    maxBits = math.min(maxBits or 32, 52) -- lua number (double) can only store integers < 2^53
    local maxVal = 2^(maxBits-1) -- assuming signed integers, which, for now, are the only ones in use
    assert(type(arg) == "number" and math.floor(arg) == arg
        and arg < maxVal and arg >= -maxVal
        or (maybeNil and arg == nil),
        string.format("Argument \"%s\" of function \"%s\" has to be a whole number <= %d",
            argName, func, maxVal))
end

-- function wrappers
function discordRPC.initialize(applicationId, autoRegister, optionalSteamId)
    local func = "discordRPC.Initialize"
    checkStrArg(applicationId, nil, "applicationId", func)
    checkArg(autoRegister, "boolean", "autoRegister", func)
    if optionalSteamId ~= nil then
        checkStrArg(optionalSteamId, nil, "optionalSteamId", func)
    end

    local eventHandlers = ffi.new("struct DiscordEventHandlers")
    eventHandlers.ready = ready_proxy
    eventHandlers.disconnected = disconnected_proxy
    eventHandlers.errored = errored_proxy
    eventHandlers.joinGame = joinGame_proxy
    eventHandlers.spectateGame = spectateGame_proxy
    eventHandlers.joinRequest = joinRequest_proxy

    discordRPClib.Discord_Initialize(applicationId, eventHandlers,
        autoRegister and 1 or 0, optionalSteamId)
end

function discordRPC.shutdown()
    discordRPClib.Discord_Shutdown()
end

function discordRPC.runCallbacks()
    discordRPClib.Discord_RunCallbacks()
end
-- http://luajit.org/ext_ffi_semantics.html#callback :
-- It is not allowed, to let an FFI call into a C function (runCallbacks)
-- get JIT-compiled, which in turn calls a callback, calling into Lua again (e.g. discordRPC.ready).
-- Usually this attempt is caught by the interpreter first and the C function
-- is blacklisted for compilation.
-- solution:
-- "Then you'll need to manually turn off JIT-compilation with jit.off() for
-- the surrounding Lua function that invokes such a message polling function."
jit.off(discordRPC.runCallbacks)

function discordRPC.updatePresence(presence)
    local func = "discordRPC.updatePresence"
    checkArg(presence, "table", "presence", func)

    -- -1 for string length because of 0-termination
    checkStrArg(presence.state, 127, "presence.state", func, true)
    checkStrArg(presence.details, 127, "presence.details", func, true)

    checkIntArg(presence.startTimestamp, 64, "presence.startTimestamp", func, true)
    checkIntArg(presence.endTimestamp, 64, "presence.endTimestamp", func, true)

    checkStrArg(presence.largeImageKey, 31, "presence.largeImageKey", func, true)
    checkStrArg(presence.largeImageText, 127, "presence.largeImageText", func, true)
    checkStrArg(presence.smallImageKey, 31, "presence.smallImageKey", func, true)
    checkStrArg(presence.smallImageText, 127, "presence.smallImageText", func, true)
    checkStrArg(presence.partyId, 127, "presence.partyId", func, true)

    checkIntArg(presence.partySize, 32, "presence.partySize", func, true)
    checkIntArg(presence.partyMax, 32, "presence.partyMax", func, true)

    checkStrArg(presence.matchSecret, 127, "presence.matchSecret", func, true)
    checkStrArg(presence.joinSecret, 127, "presence.joinSecret", func, true)
    checkStrArg(presence.spectateSecret, 127, "presence.spectateSecret", func, true)

    checkIntArg(presence.instance, 8, "presence.instance", func, true)

    local cpresence = ffi.new("struct DiscordRichPresence")
    cpresence.state = presence.state
    cpresence.details = presence.details
    cpresence.startTimestamp = presence.startTimestamp or 0
    cpresence.endTimestamp = presence.endTimestamp or 0
    cpresence.largeImageKey = presence.largeImageKey
    cpresence.largeImageText = presence.largeImageText
    cpresence.smallImageKey = presence.smallImageKey
    cpresence.smallImageText = presence.smallImageText
    cpresence.partyId = presence.partyId
    cpresence.partySize = presence.partySize or 0
    cpresence.partyMax = presence.partyMax or 0
    cpresence.matchSecret = presence.matchSecret
    cpresence.joinSecret = presence.joinSecret
    cpresence.spectateSecret = presence.spectateSecret
    cpresence.instance = presence.instance or 0

    discordRPClib.Discord_UpdatePresence(cpresence)
end

function discordRPC.clearPresence()
    discordRPClib.Discord_ClearPresence()
end

local replyMap = {
    no = 0,
    yes = 1,
    ignore = 2
}

-- maybe let reply take ints too (0, 1, 2) and add constants to the module
function discordRPC.respond(userId, reply)
    checkStrArg(userId, nil, "userId", "discordRPC.respond")
    assert(replyMap[reply], "Argument 'reply' to discordRPC.respond has to be one of \"yes\", \"no\" or \"ignore\"")
    discordRPClib.Discord_Respond(userId, replyMap[reply])
end

-- garbage collection callback
getmetatable(discordRPC.gcDummy).__gc = function()
    discordRPC.shutdown()
    ready_proxy:free()
    disconnected_proxy:free()
    errored_proxy:free()
    joinGame_proxy:free()
    spectateGame_proxy:free()
    joinRequest_proxy:free()
end

function discordRPC.ready(userId, username, discriminator, avatar)
    msg.verbose("[discordrpc] Discord: ready (" .. userId .. ", " .. username .. ", " .. discriminator ", " .. avatar .. ")")
end

function discordRPC.disconnected(errorCode, message)
    msg.verbose("[discordrpc] Discord: disconnected (" .. errorCode .. ": " .. message .. ")")
end

function discordRPC.errored(errorCode, message)
    msg.verbose("[discordrpc] Discord: error (" .. errorCode .. ": " .. message .. ")")
end

--------------------------------------------------------------------------------

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

function check_if_stream(path)
	if string.match(path, '^https?://.*') ~= nil then
		return true, 'HTTP(S)/HLS'
	else
		return false, ''
	end
end

function uri_video_source_name(url_path)
	-- This is bad
	-- Also I hate lua regex
	if url_path:find('youtu.be') ~= nil then
		url_path = url_path:gsub('youtu.be', 'youtube.com')
	end
	remove_www = url_path:gsub('www.', '')
	i, j = remove_www:find('://')
	remove_front = remove_www:sub(j+1)
	i2, j2 = remove_front:find('/')
	final_text = remove_front:sub(0, i2-1)

	return final_text:gsub("^%l", final_text.upper)
end

function mpvdrpc()
	--get filename/metadata
	local audioformats = { 'aac', 'aax', 'act', 'aiff', 'amr', 'ape', 'au', 'awb', 'dct', 'dsf', 'dss', 'dvf', 'flac', 'gsm', 'm4a', 'm4b', 'm4p', 'mp3', 'mpc', 'ogg', 'oga', 'mogg', 'opus', 'ra', 'rm', 'tta', 'vox', 'wav', 'wma' } -- Copied from wikipedia page
	ff = mp.get_property("file-format")
	for _,v in pairs(audioformats) do
		if v == ff then
			songtitle = mp.get_property("media-title")
			artist = mp.get_property_native("metadata/by-key/Artist")
			if songtitle ~= nil then
				filename = songtitle
			end
			if artist ~= nil then
				filename = ("%s - %s"):format(artist, filename)
			end
			playmode = "music"
			break
		elseif ff == "png_pipe" or ff == "mf" then
			playmode = "image" -- Why am I doing this
			filename = mp.get_property("filename")
		else
			filename = mp.get_property("filename")
			playmode = "video"
			is_stream, stream_ff = check_if_stream(mp.get_property("path"))
			if is_stream then
				filename = mp.get_property("media-title")
				stream_source = uri_video_source_name(mp.get_property("path"))
				playmode = "stream"
			else
				if drpc_opts.useMediaTitle == "no" then
					filename = mp.get_property("filename/no-ext")
				else
					filename = mp.get_property("media-title")
				end
			end
		end
	end
	
	msg.verbose("### "..playmode:upper())

	if ff == nil then
		ff = 'Unknown'
	end
	
	-- get length of the filename/metadata (for checking if it reach maximum character)
	if(string.len(filename) > 117) then
		filename = string.sub(filename, 1, 117) .. "..."
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
	if chapCurrent == 'nil' and chapTotal == nil or chapCurrent == nil or chapTotal == nil then
		if playmode == "music" then
			chapTotal = mp.get_property("playlist-count")
			chapCurrent = mp.get_property("playlist-pos-1")
		else
			chapTotal = '1'
			chapCurrent = '1'
		end
		chapterNow = ("%s/%s"):format(chapCurrent, chapTotal)
	else
		chapName = mp.get_property(string.format("chapter-list/%s/title", chapCurrent))
		chapterNow = ("%s/%s - %s"):format(chapCurrent+1, chapTotal, chapName)
	end

	-- get state
	eof = mp.get_property_bool("eof-reached")
	idling = mp.get_property_bool("idle-active")
	pause = mp.get_property_bool("pause")
	stateimage = "play"
	if playmode == "video" then
		statetext = ("%s (%s)"):format(drpc_opts.playText, chapterNow)
		state = ("%s (%s)"):format(drpc_opts.playText, total)
	elseif playmode == "music" then
		statetext = ("%s (%s) - %s"):format(drpc_opts.playMusicText, chapterNow, ff:upper())
		state = ("%s (%s)"):format(drpc_opts.playMusicText, total)
	elseif playmode == "stream" then
		statetext = ("%s (%s) - %s"):format(stream_source, chapterNow, stream_ff)
		state = ("%s (%s)"):format(drpc_opts.playStreamText, total)
	else
		statetext = ("%s (%s)"):format(drpc_opts.playOtherText, chapterNow)
		state = ("%s (%s)"):format(drpc_opts.playOtherText, total)
	end
	status = "playing"
	if idling and not playmode == "image" or eof and not playmode == "image" then
		statetext = "Idle"
		stateimage = "idle"
		state = "Idling"
		status = "idle"
	elseif idling and playmode == "image" or eof and playmode == "image" then
		status = "playing"
		statetext = ("%s (%s)"):format(drpc_opts.playOtherText, chapterNow)
		state = ("%s (%s)"):format(drpc_opts.playOtherText, total)
		stateimage = "play"
	elseif pause then
		stateimage = "pause"
		statetext = "Paused (" ..remain.. " elapsed)"
		state = "Paused (" ..total.. ")"
		status = "paused"
	end
	
	-- make presence table
	if status == "playing" then
		presence = {
			state = state,
			details = filename,
			largeImageKey = "mpvlogo",
			largeImageText = "mpv Media Player",
			smallImageKey = stateimage,
			smallImageText = statetext,
		}
		if playmode ~= "image" then
			presence["startTimestamp"] = timenow - timeen
		end
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
	
	if drpcStatus == "active" then
		msg.verbose("Status: active")
		msg.verbose("Loaded File: "..filename)
		msg.verbose("File Format: "..ff)
		msg.verbose(string.format("Chapter: %s", chapterNow))
		msg.verbose("Total Time (In Seconds): "..total)
		msg.verbose("Current State: "..status)

		discordRPC.updatePresence(presence)
	else
		-- Disabled
		msg.verbose("Status: inactive")
	end
end


function mpvdrpctoggle()
	if drpc_opts.runDRPC == "yes" then
		drpcStatus = "inactive"
		drpc_opts.runDRPC = "no"
		msg.info('Disabling mpv-drpc')
		discordRPC.clearPresence() -- Delete presence
		discordRPC.shutdown() -- Shutdown properly
		mp.osd_message('mpv-drpc: Disabled')
		msg.info('Disabled mpv-drpc')
	elseif drpc_opts.runDRPC == "no" then
		drpcStatus = "active"
		drpc_opts.runDRPC = "yes"
		msg.info('Enabled mpv-drpc')
		mp.osd_message('mpv-drpc: Enabled')
	elseif drpc_opts.runDRPC == "always" then
		drpcStatus = "active"
		msg.warn('Cannot disable mpv-drpc: options `runDRPC` set to always')
		mp.osd_message('mpv-drpc: cannot be disabled (check `runDRPC` options)')
	end
end

function init_drpc()
	-- Initialize DRPC
	discordRPC.initialize(appId, true)
	discordRPC.clearPresence()
	-- Add keybind
	mp.add_key_binding("D-X", "drpc_toggle", mpvdrpctoggle)

	-- Start drpc
	msg.info('File loaded, Starting mpv-drpc v' .. version)
	mp.add_periodic_timer(1, mpvdrpc) -- set as 1 sec to check everytime and discord will update it every 15 seconds
end

mp.register_event("file-loaded", init_drpc)