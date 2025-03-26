Framework = class('Framework')
Framework.modules = {}

function Framework:__construct()
	print('Framework has started.')
	self.queries = {}
	self.pendingCallbacks = {}
	self.callbacks = {
		client = {},
		server = {}
	}
end

function Framework.log(msg, level)
	if not (msg or level) then return end

	if level == 'info' then
		print('^3[INFO] '..msg.."^0")
	elseif level == 'error' then
		print('^1[ERROR] '..msg.."^0")
	else
		print('Cannot log. Invalid level')
	end
end

function Framework:RegisterModule(name, tbl)
	if not Framework.modules[name] then
		Framework.modules[name] = tbl
		if IsDuplicityVersion() then
			print('Registered class: '..name..' on server')
		else
			print('Registered class: '..name..' on client')
		end
	end
end

function Framework:query(name, query)
	if not (name or query) then
		return error('unable to create query due to invalid data passed.')
	end

	if not self.queries[name] then
		self.queries[name] = {
			query = query,
		}
	end
end

function Framework:execute(name, data)
	if not (name or self.queries[name]) then
		return error('unable to execute query. Does it exist?')
	end

	local query = self.queries[name].query
	local result

	if data then
		result = exports['oxmysql']:executeSync(query, data)
	else
		result = exports['oxmysql']:executeSync(query)
	end
	return result
end


local function generateEventID()
	return "cb_"..tostring(math.random(1000000, 9999999))
end

function Framework:RegisterCallback(eventName, cb)
	if IsDuplicityVersion() then
		self.callbacks.server[eventName] = cb
	else
		self.callbacks.client[eventName] = cb
	end
end

function Framework:TriggerCallback(eventName, callback, target, ...)
	local isServer = IsDuplicityVersion()
	local args = { ... }

	if isServer then
		local cb = self.callbacks.server[eventName]
		if cb then
			local result = target and cb(target, table.unpack(args)) or cb(source, table.unpack(args))
			if callback then callback(result) end
			return
		end
	else
		local cb = self.callbacks.client[eventName]
		if cb then
			local result = cb(table.unpack(args))
			if callback then callback(result) end
			return
		end
	end

	local eventID = generateEventID()
	self.pendingCallbacks[eventID] = callback

	if isServer then
		if not target then
			Framework.log('Missing target player id for callback: '.. eventName)
			return
		end

		TriggerClientEvent('framework:triggerClient', target, eventName, eventID, table.unpack(args))
	else
		TriggerServerEvent('framework:triggerServer', eventName, eventID, table.unpack(args))
	end
end

if IsDuplicityVersion() then
	RegisterNetEvent('framework:triggerServer', function(eventName, eventID, ...)
		local src = source
		local cb = Framework.callbacks.server[eventName]
		if cb then
			local result(src, ...)
			TriggerClientEvent('framework:serverResponse',src, eventID, result)
		else
			Framework.log('Missing server callback for '..eventName)
		end
	end)
end

if not IsDuplicityVersion() then
	RegisterNetEvent('framework:triggerClient', function(eventName, eventID, ...)
		local cb =Framework.callbacks.client[eventName]
		if cb then
			local result = cb(...)
			TriggerServerEvent('framework:serverResponse', eventID, result)
		else
			Framework.log('Missing client callback for: '..eventName)
		end
	end)

	RegisterNetEvent('framework:serverResponse', function(eventID, result)
		if Framework.pendingCallbacks[eventID] then
			Framework.pendingCallbacks[eventID](result)
			Framework.pendingCallbacks[eventID] = nil
		end
	end)
end
return Framework
