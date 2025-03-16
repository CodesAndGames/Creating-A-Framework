function class(name)
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
		resource = GetCurrentResourceName()--'core' -- or GetCurrentResourceName()
	end
	local key = resource..'/'..path
	local rets = modules[key]
	if rets then
		return table.unpack(retsl, 2, rets.n)
	else
		local code = LoadResourceFile(resource, path..'.lua')
		if code then
			local f, err = load(code, resource..'/'..path..'.lua')
			if f then
				local rets = table.pack(xpcall(f, debug.traceback))
				if rets[1] then
					modules[key] = rets
					return table.unpack(rets,2,rets.n)
				else
					error('error loading module '..resource..'/'..path..':'..rets[2])
				end
			else
				error('error parsing module '..resource..'/'..path..':'..err)
			end
		else
			error('resource file '..resource..'/'..path..'.lua not found.')
		end
	end
end


