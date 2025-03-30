function class(name) -- reverted class function to its original.
	local cls = {}
	cls.__index = cls

	setmetatable(cls, {
		__index = cls,
		__newindex = function(tbl, key, value)
			rawset(tbl, key, value)
			if key == "__construct" then
				value(tbl)
			end
		end
	})

	return cls
end



SERVER = IsDuplicityVersion()
CLIENT = not SERVER

local modules = {}

function module(resource, path)
  if not path then
    path = resource
    resource = GetCurrentResourceName()
  end

  local key = resource .. '/' .. path
  local cached = modules[key]

  if cached then
    return table.unpack(cached.rets or {}, 1, cached.n or 0)
  else
    local code = LoadResourceFile(resource, path .. '.lua')
    if not code then
      error('resource file ' .. resource .. '/' .. path .. '.lua not found.')
    end

    local f, err = load(code, resource .. '/' .. path .. '.lua')
    if not f then
      error('error parsing module ' .. resource .. '/' .. path .. ':' .. err)
    end

    local success, result = xpcall(f, debug.traceback)
    if not success then
      error('error loading module ' .. resource .. '/' .. path .. ':' .. result)
    end

    local rets = { result }
    modules[key] = { rets = rets, n = #rets }

    return table.unpack(rets)
  end
end



