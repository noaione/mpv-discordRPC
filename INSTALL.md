<p align="center">
  <img align="middle" width="384" height="192" src="https://raw.githubusercontent.com/noaione/mpv-discordRPC/master/assets/mpv_discord.png">
</p>
<h1 align="center">
    Installation Tutorial
</h1>
<p align="center"><b>mpv Discord RPC Version 2.1</b><br>Created by NoAiOne</p>

<p align="center">
    <a href="https://github.com/noaione/mpv-discordRPC">Home</a> •
    <a href="#download">Download</a> •
    <a href="#installation">Installation</a>
</p>

## Download
1. Download this repository or via [releases](https://github.com/noaione/mpv-discordRPC/releases)
2. Extract it to somewhere then follow the Instalation instruction below.

## Installation
- [Windows](#windows)
- [Linux](#linux)
- [OS X or Mac OS](#os-x)
- [Notes](#notes)

### Windows
1. Put `discord-rpc.dll` to your local mpv directory. (copy from `lib\win32` or `lib\win64`)
2. Copy `scripts\mpv-drpc.lua` to your mpv scripts folder

### Linux
1. Put `libdiscord-rpc.so` to your local lib folder. (copy from `lib\linux`)
	- Usually on: `/usr/local/lib`
2. Copy `scripts\mpv-drpc.lua` to your mpv scripts folder
3. Update your library path

### OS X
1. Put `libdiscord-rpc.dylib` to your local lib folder. (copy from `lib\osx`)
	- Usually on: `/usr/local/lib`
2. Copy `scripts\mpv-drpc.lua` to your mpv scripts folder
3. Update your library path

#### Notes
**Scripts folder location**:
- `.\mpv\scripts` **# Windows**
- `%APPDATA%\mpv\scripts` **# Windows**
- `$HOME/.config/mpv/scripts` **# Linux and Mac OS X**

**Discord-RPC library**:
- `.\mpv` **# Windows**
- `/usr/local/lib` **# Linux and Mac OS X**

If you're using Linux/Mac OS, make sure you compiled it with LuaJIT