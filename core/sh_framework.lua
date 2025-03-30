Framework = class("Framework")
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
  name = string.lower(name) -- 💡 normalize key
  if not self.modules[name] then
    self.modules[name] = tbl
    for k, _ in pairs(self.modules) do print(" +", k) end
    if IsDuplicityVersion() then
      print('Registered class: '..name..' on server')
    else
      print('Registered class: '..name..' on client')
    end
  end
end


function Framework:query(name, query)
	if not name or not query then
		return error('unable to create query due to invalid data passed.')
	end


	if not self.queries[name] then
		self.queries[name] = {
			query = query,
		}
	end
end

function Framework:execute(name, data)
	if not name then
		return error('Missing query name.')
	end

	if not self.queries[name] then
		Framework.log("Query ["..name.."] not found!", 'error')
		return nil
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


-- 📣 Generate a unique event ID
local function generateEventID()
  return "cb_" .. tostring(math.random(100000, 999999))
end

-- 🔧 Register a callback function
function Framework:RegisterCallback(eventName, cb)
  if IsDuplicityVersion() then
    self.callbacks.server[eventName] = cb
  else
    self.callbacks.client[eventName] = cb
  end
end

-- 🔁 Trigger a callback (Client <-> Server)
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

  -- not local: send to other side
  local eventID = generateEventID()
  self.pendingCallbacks[eventID] = callback

  if isServer then
    if not target then
      print("[Framework] ERROR: Missing target player ID for callback: " .. eventName)
      return
    end
    TriggerClientEvent("framework:triggerClient", target, eventName, eventID, table.unpack(args))
  else
    TriggerServerEvent("framework:triggerServer", eventName, eventID, table.unpack(args))
  end
end

-- 🌐 Server-side handler: client → server
if IsDuplicityVersion() then
  RegisterNetEvent("framework:triggerServer", function(eventName, eventID, ...)
    local src = source
    local cb = Framework.callbacks.server[eventName]
    if cb then
      local result = cb(src, ...)
      TriggerClientEvent("framework:serverResponse", src, eventID, result)
    else
      print("[Framework] Missing server callback for: " .. eventName)
    end
  end)
end

-- 🌐 Client-side handlers: server → client and response back
if not IsDuplicityVersion() then
  RegisterNetEvent("framework:triggerClient", function(eventName, eventID, ...)
    local cb = Framework.callbacks.client[eventName]
    if cb then
      local result = cb(...)
      TriggerServerEvent("framework:serverResponse", eventID, result)
    else
      print("[Framework] Missing client callback for: " .. eventName)
    end
  end)

  RegisterNetEvent("framework:serverResponse", function(eventID, result)
    if Framework.pendingCallbacks[eventID] then
      Framework.pendingCallbacks[eventID](result)
      Framework.pendingCallbacks[eventID] = nil
    end
  end)
end


-- Database queries
Framework:query('InitDatabase', [[
	CREATE TABLE IF NOT EXISTS `players` (
		`identifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_bin',
		`cData` LONGTEXT NULL DEFAULT '[]' COLLATE 'armscii8_bin'
	)
	COLLATE='armscii8_bin'
	ENGINE=InnoDB
	;
]])
Framework:query('SelectAllPlayers', [[SELECT * FROM players]])
Framework:query('SelectPlayer', [[SELECT * FROM players WHERE identifier = @identifier]])
Framework:query('AddToPlayers', [[
  INSERT INTO players (identifier, cData)
  VALUES (@identifier, @cData)
  ON DUPLICATE KEY UPDATE cData = @cData
]])
Framework:query('SavePlayer', [[UPDATE players SET cData = @cData WHERE identifier = @identifier]])


AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		Wait(1000)
		Framework:execute('InitDatabase')
	end
end)



return Framework
