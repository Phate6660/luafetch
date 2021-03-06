-- Luafetch
-- Created by: Phate6660

-- Takes an environmental variable. Returns the contents if it's set.
local function env(var)
    local data = os.getenv(var)
    if not data then
        return 'N/A (could not read "$' .. var .. '", are you sure it is set?)'
    else
        return data
    end
end

-- Takes a string, creates a table delimited by newlines,
-- counts the number of elements, then returns the number.
local function linecount(string)
    local lines = {}
    for line in string.gmatch(string, '([^\n]+)') do
        table.insert(lines, line)
    end
    local count = {}
    for i, _ in ipairs(lines) do
        table.insert(count, i)
    end
    return count[#count+1-1]
end

-- Takes a string, the character to find, and what to replace it with.
-- Returns the string with all instances of the character replaced.
local function replace(arg, char, rep)
    if string.match(arg, char) then
        return arg:gsub(char, rep)
    else
        return arg -- Just return arg without doing anything if char wasn't found.
    end
end

-- A function to return output, and optionally strip newlines from it.
local function return_output(output, strip)
    strip = strip or false
    if strip == true then
        return replace(output, '\n', '')
    else
        return output
    end
end

-- Takes a file path, optionally a line number, and optionally to strip newlines.
-- With just the file path, it'll return the contents of the file.
-- Specifying a line number will return only that line.
local function read(file_path, line_number, strip)
    line_number = line_number or 'nil'
    strip = strip or false
    local file = io.open(file_path, 'r')
    if not file then
        return 'N/A (could not read "' .. file_path .. '")'
    else
        local contents = file:read '*a'
        file:close()
        if line_number == 'nil' then
            return return_output(contents, strip)
        else
            local contents_table = {}
            local delim = '\n'
            for line in string.gmatch(contents, '([^' .. delim .. ']+)') do
                table.insert(contents_table, line)
            end
            return return_output(contents_table[line_number], strip)
        end
    end
end

-- Split a string based on a delimiter, return a table.
local function split(string, delim)
    local string_table = {}
    for entry in string.gmatch(string, '([^' .. delim .. ']+)') do
        table.insert(string_table, entry)
    end
    return string_table
end

local function return_cpu()
    local line = read('/proc/cpuinfo', 5, true)
    local line_table = split(line, ':')
    return line_table[2]:sub(2) -- Remove leading space from using ':' as delimiter.
end

local function return_distro()
    local line = read('/etc/os-release', 3, true)
    local line_table = split(line, '=')
    return replace(line_table[2], '"', '')
end

local function return_memory()
    local line = read('/proc/meminfo', 1, true)
    local line_table = split(line, ' ')
    local kb = tonumber(line_table[2])
    if kb > 1024 then
        local mb = kb / 1024
        local mb_table = split(tostring(mb), '.')
        return mb_table[1] .. ' MB'
    end
    return kb
end

local function return_packages(mngr)
    mngr = mngr or 'nil'
    if mngr == "portage" then
        -- '/var/db/pkg/*/*' is a list of all packages.
        local dirs = io.popen(
            'find "/var/db/pkg/" -mindepth 2 -maxdepth 2 -type d -printf "%f\n"',
            'r'
        )
        local dirs_list = dirs:read('*a')
        dirs:close()
        local total = linecount(dirs_list)
        local explicit_list = read('/var/lib/portage/world', nil, false)
        local explicit = linecount(explicit_list)
        return explicit .. ' (explicit), ' .. total .. ' (total) ' .. '| Portage'
    elseif mngr == "pacman" then
        local total = io.popen('pacman -Qq | wc -l', 'r'):read('*a')
        return replace(total .. ' (total) | Pacman', '\n', '')
    elseif mngr == 'nil' then
        return 'N/A (no package manager was passed to the function)'
    else
        return 'N/A (' .. mngr .. ' is unsupported right now)'
    end
end

local function return_music(player)
    player = player or 'nil'
    if player == 'mpd' then
        local line = io.popen('mpc -f "%artist% - %album% - %title%" | head -n1', 'r')
        local usable_line = line:read('*a')
        line:close()
        return replace(usable_line, '\n', '')
    elseif player == 'spotify' then
        local line = io.popen(
            'playerctl -p spotify metadata -f "{{ artist }} - {{ album }} - {{ title }}"',
            'r'
        )
        local usable_line = line:read('*a')
        line:close()
        return replace(usable_line, '\n', '')
    elseif player == 'nil' then
        return 'N/A (no player selected)'
    else
        return 'N/A (' .. player .. ' is unsupported right now)'
    end
end

local function return_uptime()
    local uptime = tonumber(split(read('/proc/uptime'), '.')[1])
    if uptime > 86400 then
        local days_pre = uptime / 60 / 60 / 24
        days_pre = split(tostring(days_pre), '.')[1]
        Days = days_pre .. 'd'
    else
        Days = ''
    end
    if uptime > 3600 then
        local hours_pre = (uptime / 60 / 60) % 24
        hours_pre = split(tostring(hours_pre), '.')[1]
        Hours = hours_pre .. 'h'
    else
        Hours = ''
    end
    if uptime > 60 then
        local minutes_pre = (uptime / 60) % 60
        minutes_pre = split(tostring(minutes_pre), '.')[1]
        Minutes = minutes_pre .. 'm'
    else
        Minutes =  ''
    end
    if Days == '' then
        return (Days .. ' ' .. Hours .. ' ' .. Minutes):sub(2)
    else
        return Days .. ' ' .. Hours .. ' ' .. Minutes
    end
end

local cpu      = return_cpu()
local device   = read('/sys/devices/virtual/dmi/id/product_name', nil, true)
local distro   = return_distro()
local editor   = env('EDITOR')
local hostname = read('/etc/hostname', nil, true)
local kernel   = read('/proc/sys/kernel/osrelease', nil, true)
local memory   = return_memory()
local packages = return_packages(arg[1]) -- Reads first arg specified when running the script.
local shell    = env('SHELL')
local uptime   = return_uptime()
local user     = env('USER')
local music    = return_music(arg[2]) -- Reads the second arg passed.

print('cpu       =  ' .. cpu      .. '\n'
   .. 'device    =  ' .. device   .. '\n'
   .. 'distro    =  ' .. distro   .. '\n'
   .. 'editor    =  ' .. editor   .. '\n'
   .. 'hostname  =  ' .. hostname .. '\n'
   .. 'kernel    =  ' .. kernel   .. '\n'
   .. 'memory    =  ' .. memory   .. '\n'
   .. 'packages  =  ' .. packages .. '\n'
   .. 'shell     =  ' .. shell    .. '\n'
   .. 'uptime    =  ' .. uptime   .. '\n'
   .. 'user      =  ' .. user     .. '\n'
   .. 'music     =  ' .. music
)
