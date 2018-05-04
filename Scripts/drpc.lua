local discordRPC = require("discordRPC")
local appId = require("applicationId")
-- local mp = require("mp")
-- local socket = require("socket")
-- nextPresenceUpdate = 0

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
	filename = mp.get_property("filename")
	discordRPC.initialize(appId, true)
	presence = {
		state = filename,
		details = "Now Playing...",
		largeImageKey = "mpvlogo",
		smallImageKey = "play",
		smallImageText = "Playing",
	}
	discordRPC.updatePresence(presence)
	discordRPC.runCallbacks()
end

--seconds = 0
mp.add_periodic_timer(1, discordrpc)