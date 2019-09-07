# mpv media player Discord RPC Integration
#### Created by noaione, contact me at discord if there is any problem: N4O#8868
Using [lua-DiscordRPC](https://github.com/pfirsich/lua-discordRPC) as base and mpv lua module

![Playing Video](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_video.png) 
![Playing Audio](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_audio.png) 
![Playing Other Stuff/Image](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_other.png)
![Playing from website (Stream)](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_stream.png)

![Paused](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/paused.png) ![Idling](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/idling.png)

### [Download](https://github.com/noaione/mpv-discordRPC/releases)

#### Recommended Linux Version: [cniw version](https://github.com/cniw/mpv-discordRPC)

### How to install
1. Download this repo or goto Release
2. Extract files from the Scripts folder to your scripts folder (Some of them are in appdata)
3. Put the DLL besides mpv.exe
- 3a. Change appId (Line 2) to `470185467959050261` if you download it via **Release tab**
4. Done

### Information:
```
-- Refresh interval: 15 seconds (Limited by Discord itself)
-- Script: lua
-- Current Version: 2.0
```

### Problem:
```
-- Sometimes it won't gone after you exit (can be fixed by restarting discord: CTRL+R)
-- Sometimes it takes about 10+ seconds until it show up
```

### Changelog
```
-- Version 1.0: First initial release
-- Version 1.1: Pause/Play kinda thingy, added win32/win64 version, linux/mac soon, since i don't know how lua loaded in linux/mac
-- Version 1.2: Cleaned up, making idle mode more idle. Compacted everything to 3 files
-- Version 1.3: Linux Support (please open issue if there is any problem)
-- Version 1.4: Remaining time, more detailed info, and updated DiscordRPC.lua and .dll to version 3.3.0
-- Version 1.5: Reworked how Idle, playing, paused works
-- Version 1.6: Youtube Mode
                Find chapter number, metadata, etc
-- Version 1.7: Renamed drpc.lua to mpv-drpc.lua
                Add more audio formats that i get from wikipedia page.
                Make the script more cleaner.
-- Version 1.8: Added some options
                More feature for chapter/playlist
-- Version 2.0: Added toggle option to enable/disable mpv-drpc. 
                Merge all scripts to one file.
                Fix "streaming video" checking
                Add website name and strip them to only the Website name.
                Improve "Image" and "Other" checking.
```
