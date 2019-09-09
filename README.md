<p align="center">
  <img align="middle" width="384" height="192" src="https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/mpv_discord.png">
</p>
<h1 align="center">
    mpv Media Player Discord RPC Integration
</h1>
<p align="center"><b>Version 2.0</b><br>Created by NoAiOne, contact me at Discord or open Issues if there's any problem<br>Using <a href="https://github.com/pfirsich/lua-discordRPC">lua-DiscordRPC</a> as it base code and discord-rpc library files</p>

<p align="center">
    <a href="#screenshot">Screenshot</a> •
    <a href="https://github.com/noaione/mpv-discordRPC/releases">Download</a> •
    <a href="https://github.com/noaione/mpv-discordRPC/blob/master/INSTALL.md">Installation</a> •
    <a href="#changelog">Changelog</a>
</p>

---
## Screenshot
| State | Image |
| :-: | :-: |
| Playing: Video | ![Playing Video](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_video.png) |
| Playing: Music | ![Playing Music](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_music.png) |
| Playing: Other | ![Playing Other Stuff/Image](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_other.png) |
| Playing: Stream | ![Playing from website (Stream)](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/playing_stream.png) |
| Paused | ![Paused](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/paused.png) |
| Idling/Stop | ![Idling](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/idling.png) |


### Information
```
-- Refresh interval: 15 seconds (Limited by Discord itself)
-- Script: lua
-- Current Version: 2.0
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
![Idling](https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/idling.png) |

### [Download](https://github.com/noaione/mpv-discordRPC/releases)

### How to install
Download this repo or goto [Release](https://github.com/noaione/mpv-discordRPC/releases) then refer to [INSTALL.txt](https://github.com/noaione/mpv-discordRPC/blob/master/INSTALL.txt)

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
