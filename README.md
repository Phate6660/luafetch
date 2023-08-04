# luafetch

Decided to make this. Lua has been growing on me and I wanted to test it more.

Run with `lua luafetch.lua` or `luajit luafetch.lua`.

Args:
- package manager: currently only `pacman` and `portage` is supported
- music player: currently only `mpd` and `spotify` are supported

This is all pure Lua, EXCEPT for when using the args specified above.<br>
My reasoning: I use `find` for getting a list of dirs, because I could not find a simple pure<br>
lua solution. I use `mpc` and `head` for getting the music info for MPD. And I use<br>
`playerctl` to get the music information from Spotify.

## Output

From my personal desktop:

`$ luajit luafetch.lua portage spotify`

```
cpu       =  Intel(R) Core(TM) i5-3470 CPU @ 3.20GHz
device    =  OptiPlex 7010
distro    =  Gentoo/Linux
editor    =  /usr/bin/nvim
hostname  =  gentoo
kernel    =  5.11.3-ck-VALLEY
memory    =  15970 MB
packages  =  156 (explicit), 835 (total) | Portage
shell     =  /bin/bash
uptime    =  10d 16h 34m
user      =  valley
music     =  Flaw - Endangered Species - Medicate
```

From my Android device:

`$ luajit luafetch.lua pkg`

```
cpu      =  Cortex-A510
device   =  motorola edge+ (2022)
distro   =  Android 12
editor   =  N/A (could not read "$EDITOR", are you sure it is set?)
hostname =  N/A (could not read "/etc/hostname")
kernel   =  5.10.101-android12-9-00004-ge2ccd2db469a-ab9403744
memory   =  7258 MB
packages =  207 (total) | pkg
shell    =  /data/data/com.termux/files/usr/bin/bash
uptime   =  up 1 day, 11 hours, 45 minutes
user     =  N/A (could not read "$USER", are you sure it is set?)
music    =  N/A (no player selected)
```