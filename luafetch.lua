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

local function return_cpu()
    local line = read('/proc/cpuinfo', 5)
	local line_table = split(line, ':')
	return line_table[2]:sub(2) -- remove leading space from using ':' as delimiter
end

local function return_distro()
    local line = read('/etc/os-release', 3)
    local line_table = split(line, '=')
    return replace(line_table[2], '"', '')
end

local function return_memory()
    local line = read('/proc/meminfo', 1)
    local line_table = split(line, ' ')
    local kb = line_table[2]
    if tonumber(kb) > 1024 then
        local mb = tonumber(kb) / 1024
        local mb_table = split(tostring(mb), '.')
		return mb_table[1] .. ' MB'
    end
    return kb
end

local cpu      = return_cpu()
local device   = read('/sys/devices/virtual/dmi/id/product_name')
local distro   = return_distro()
local editor   = env('EDITOR')
local hostname = read('/etc/hostname')
local kernel   = read('/proc/sys/kernel/osrelease')
local memory   = return_memory()

print('cpu       =  ' .. cpu      .. '\n'
   .. 'device    =  ' .. device   .. '\n'
   .. 'distro    =  ' .. distro   .. '\n'
   .. 'editor    =  ' .. editor   .. '\n'
   .. 'hostname  =  ' .. hostname .. '\n'
   .. 'kernel    =  ' .. kernel   .. '\n'
   .. 'memory    =  ' .. memory
)
