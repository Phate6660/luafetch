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

local function replace(arg, char, rep)
    if string.match(arg, char) then
        return arg:gsub(char, rep)
    else
        return arg -- just return arg without doing anything if char wasn't found
    end
end

local function read(file_path, line_number)
    line_number = line_number or 'N/A'
    local file = io.open(file_path, 'r')
    if not file then
        return 'N/A (could not read "' .. arg .. '")'
    else
        local contents = file:read '*a'
        file:close()
        if line_number == 'N/A' then
            return replace(contents, '\n', '')
        else
            local contents_table = {}
            local delim = '\n'
            for line in string.gmatch(contents, '([^'..delim..']+)') do
                table.insert(contents_table, line)
            end
            return replace(contents_table[line_number], '\n', '')
        end
    end
end

local function split(string, delim)
    local string_table = {}
    for entry in string.gmatch(string, '([^'..delim..']+)') do
        table.insert(string_table, entry)
    end
    return string_table
end

local function return_distro()
    local line = read('/etc/os-release', 3)
    local line_table = split(line, '=')
    return replace(line_table[2], '"', '')
end

local distro = return_distro()
local editor = env('EDITOR')
local hostname = read('/etc/hostname')
local kernel = read('/proc/sys/kernel/osrelease')

print('distro    =  ' .. distro   .. '\n'
   .. 'editor    =  ' .. editor   .. '\n'
   .. 'hostname  =  ' .. hostname .. '\n'
   .. 'kernel    =  ' .. kernel
)
