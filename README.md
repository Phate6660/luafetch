# luafetch

Decided to make this. Lua has been growing on me and I wanted to test it more.

Run with `lua luafetch.lua` or `luajit luafetch.lua`.

Args:
- package manager: currently only `portage` is supported
- music player: currently only `mpd` and `spotify` are supported

This is all pure Lua, EXCEPT for when using the args specified above.<br>
My reasoning: I use `find` for getting a list of dirs, because I could not find a simple pure<br>
lua solution. I use `mpc` and `head` for getting the music info for MPD. And I use<br>
`playerctl` to get the music information from Spotify.

## Output

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
