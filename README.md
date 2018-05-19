# mpv media player Discord RPC Integration
#### This is work in progress thingymagic, since it can broke anytimes

### [Download](https://github.com/noaione/mpv-discordRPC/releases)

### How to install (Windows)
1. Download this repo or goto Release
2. Extract it to mpv directory, ex mpv dir. C:\mpv\
3. Done

### How to install (Linux)
1. Extract files
2. open up terminal and write this LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/YOURUSERNAME/.config/mpv/scripts/
3. Copy extracted files folder to /home/YOURUSERNAME/.config/mpv/scripts
4. Open up terminal and type this: 
```bash
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.config/mpv/scripts/" >> ~/.bashrc
```
5. Done

### Information:
```
-- Refresh interval: 15 seconds (?)
-- Script: lua
-- Version: 1.3
```

### Problem:
```
-- 15 seconds interval is too long
-- Sometimes it won't gone after you exit (can be fixed by restarting discord: CTRL+R)
-- Sometimes it takes about 10+ seconds until it show up
```

### Changelog
```
-- Version 1.0: First initial release
-- Version 1.1: Pause/Play kinda thingy, added win32/win64 version, linux/mac soon, since i don't know how lua loaded in linux/mac
-- Version 1.2: Cleaned up, making idle mode more idle. Compacted everything to 3 files
-- Version 1.3: Linux Support (please open issue if there is any problem)
```
