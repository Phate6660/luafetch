-- Luafetch
-- Created by: Phate6660

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


local function replace(arg, char, rep)
    if string.match(arg, char) then
        return arg:gsub(char, rep)
    else
        return arg -- Just return arg without doing anything if char wasn't found.
    end
end

-- Takes a file path, and optionally a line number.
-- With just the file path, it'll return the contents of the file.
-- Specifying a line number will return only that line.
local function read(file_path, line_number)
    line_number = line_number or 'N/A'
    local file = io.open(file_path, 'r')
    if not file then
        return 'N/A (could not read "' .. file_path .. '")'
    else
        local contents = file:read '*a'
        file:close()
        if line_number == 'N/A' then
            return replace(contents, '\n', '')
        else
            local contents_table = {}
            local delim = '\n'
            for line in string.gmatch(contents, '([^' .. delim .. ']+)') do
                table.insert(contents_table, line)
            end
            return replace(contents_table[line_number], '\n', '')
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
    local line = read('/proc/cpuinfo', 5)
    local line_table = split(line, ':')
    return line_table[2]:sub(2) -- Remove leading space from using ':' as delimiter.
end

local function return_distro()
    local line = read('/etc/os-release', 3)
    local line_table = split(line, '=')
    return replace(line_table[2], '"', '')
end

local function return_memory()
    local line = read('/proc/meminfo', 1)
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
    mngr = mngr or 'undefined'
    if mngr == "portage" then
        -- '/var/db/pkg/*/*' is a list of all packages.
        local dirs = io.popen(
            'find "/var/db/pkg/" -mindepth 2 -maxdepth 2 -type d -printf "%f\n"',
            'r'
        )
        local dirs_list = dirs:read('*a')
        dirs:close()
        return linecount(dirs_list) .. ' (portage)'
    elseif mngr == 'undefined' then
        return 'N/A (no package manager was passed to the function)'
    else
        return 'N/A (' .. mngr .. ' is unsupported right now)'
    end
end

local cpu      = return_cpu()
local device   = read('/sys/devices/virtual/dmi/id/product_name')
local distro   = return_distro()
local editor   = env('EDITOR')
local hostname = read('/etc/hostname')
local kernel   = read('/proc/sys/kernel/osrelease')
local memory   = return_memory()
local packages = return_packages(arg[1]) -- Reads first arg specified when running the script.
local shell    = env('SHELL')

print('cpu       =  ' .. cpu      .. '\n'
   .. 'device    =  ' .. device   .. '\n'
   .. 'distro    =  ' .. distro   .. '\n'
   .. 'editor    =  ' .. editor   .. '\n'
   .. 'hostname  =  ' .. hostname .. '\n'
   .. 'kernel    =  ' .. kernel   .. '\n'
   .. 'memory    =  ' .. memory   .. '\n'
   .. 'packages  =  ' .. packages .. '\n'
   .. 'shell     =  ' .. shell
)
