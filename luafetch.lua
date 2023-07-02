-- Luafetch
-- Created by: Phate6660

-- Runs an external command in bash and returns the output.
local function cmd(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

-- Reads an environmental variable and returns the contents if possible,
-- otherwise it returns a dynamic error message stating which variable failed.
local function env(var)
    local data = os.getenv(var)
    if not data then
        return 'N/A (could not read "$' .. var .. '", are you sure it is set?)'
    else
        return data
    end
end

-- Returns a bool based on whether or not the file exists.
local function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then 
        io.close(f)
        return true
    else
        return false
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

-- An Android specific function for matching the processor ID (obtained from `/proc/cpuinfo`),
-- with the processor name and returns said name.
local function match_processor(id)
    local hardware = {
        ['0xd46'] = "Cortex-A510",
    }
    return hardware[id]
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

-- Checks if the OS is Android, currently by parsing the kernel
-- name and checking if it contains 'android', since it seems that
-- most of not all android versions will contain 'android'
-- in the kernel version.
local function android()
    local s = return_output(cmd('uname -r'))
    if string.match(s, "android") then
        return true
    else
        return false
    end
end

local function return_cpu()
    if android() then
        line = read('/proc/cpuinfo', 7, true)
    else
        line = read('/proc/cpuinfo', 5, true)
    end
    local line_table = split(line, ':')
    local result = line_table[2]:sub(2) -- Remove leading space from using ':' as delimiter.
    if android() then
      return match_processor(result)
    else
      return result
    end
end

local function return_distro()
    local line = read('/etc/os-release', 3, true)
    if android() then
        local av = cmd("getprop ro.build.version.release")
        av = return_output(av, true)
        local android = "Android " .. av
        local kv = cmd("uname -r")
        kv = return_output(kv, true)
        local device = cmd("getprop ro.vendor.product.display")
        device = return_output(device, true)
        return android, kv, device
    end
    local line_table = split(line, '=')
    return replace(line_table[2], '"', '')
end

-- TODO: Gather more info, such as total and used memory.
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
        -- TODO: Get the list of dirs in pure lua.
        local dirs = cmd('find "/var/db/pkg/" -mindepth 2 -maxdepth 2 -type d -printf "%f\n"')
        local dirs_list = dirs:read('*a')
        dirs:close()
        local total = linecount(dirs_list)
        local explicit_list = read('/var/lib/portage/world', nil, false)
        local explicit = linecount(explicit_list)
        return explicit .. ' (explicit), ' .. total .. ' (total) ' .. '| Portage'
    elseif mngr == "pacman" then
        local total = cmd('pacman -Qq | wc -l')
        return replace(total .. ' (total) | Pacman', '\n', '')
    -- `pkg` is also a BSD package manager, but we'll get to that later
    -- if this reaches a stage where it expands to BSD.
    -- For now, this is in reference to the `pkg`
    -- package manager built in to Termux
    elseif mngr == 'pkg' or 'apt' or 'dpkg' then
        local output = cmd("dpkg -l --no-pager")
        output = linecount(output) - 4
        return output .. " (total) | " .. mngr
    elseif mngr == 'nil' then
        return 'N/A (no package manager was passed to the function)'
    else
        return 'N/A (' .. mngr .. ' is unsupported right now)'
    end
end

local function return_music(player)
    player = player or 'nil'
    if player == 'mpd' then
        local line = cmd('mpc -f "%artist% - %album% - %title%" | head -n1')
        return replace(usable_line, '\n', '')
    elseif player == 'spotify' then
        local line = cmd('playerctl -p spotify metadata -f "{{ artist }} - {{ album }} - {{ title }}"')
        return replace(usable_line, '\n', '')
    elseif player == 'nil' then
        return 'N/A (no player selected)'
    else
        return 'N/A (' .. player .. ' is unsupported right now)'
    end
end

local function return_uptime()
    local uptime = tonumber(split(read('/proc/uptime'), '.')[1])
    if android() then
        -- TODO: Find a better method than running a command,
        -- though unfortunately `/proc/uptime` is either missing or inaccessible on Android.
        local output = cmd("uptime -p")
        local usable_output = return_output(output, true)
        -- TODO: Clean up and format output before returning it.
        return usable_output
    end
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

-- Gather Information
-- Notes:
-- * the first arg passed to the script is the packaga manager
-- * the second arg the music player if music info is wanted
-- TODO: hide info behind options, this will require more robust arg parsing.
local cpu               = return_cpu()
if android() then
    distro, kernel, device = return_distro()
else
    device              = read(
        '/sys/devices/virtual/dmi/id/product_name', 
        nil, true
    )
    distro              = return_distro()
    kernel              = read('/proc/sys/kernel/osrelease', nil, true)
end
local editor            = env('EDITOR')
local hostname          = read('/etc/hostname', nil, true)
local memory            = return_memory()
local packages          = return_packages(arg[1])
local shell             = env('SHELL')
local uptime            = return_uptime()
local user              = env('USER')
local music             = return_music(arg[2])

print('cpu             =  ' .. cpu      .. '\n'
   .. 'device          =  ' .. device   .. '\n'
   .. 'distro          =  ' .. distro   .. '\n'
   .. 'kernel  version =  ' .. kernel   .. '\n'
   .. 'editor          =  ' .. editor   .. '\n'
   .. 'hostname        =  ' .. hostname .. '\n'
   .. 'memory          =  ' .. memory   .. '\n'
   .. 'packages        =  ' .. packages .. '\n'
   .. 'shell           =  ' .. shell    .. '\n'
   .. 'uptime          =  ' .. uptime   .. '\n'
   .. 'user            =  ' .. user     .. '\n'
   .. 'music           =  ' .. music
)