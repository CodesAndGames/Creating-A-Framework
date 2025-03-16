local player = class('player')

function player:__construct()
	self.config = module('config') -- loads config

	self.players = {} -- active players on the server
	self.characters = {} -- characters created by player
	self.cData = {} -- active character's data

	Framework.log('player module ready and started.', 'info')
end

function player:addPlayer(data)
	if not data or type(data) ~= 'table' then
		return Framework.log('Unable to add player due to invalid data.', 'error')
	end

	id = tostring(source)

	if not (data.firstname or data.lastname) then -- mandatory data for player
		return Framework.log('Player is missing their first and last name!', 'error')
	end


	local function applyDefaults(defaults, target)
		for key, defaultValue in pairs(defaults) do 
			if type(defaultData) == "table" then
				target[key] = type(target[key]) == 'table' and target[key] or {}
				applyDefaults(defaultValue, target[key])
			else
				if target[key] == nil or type(target[key]) ~= type(defaultValue) then
					if key == 'accoutnt' then
						target[key] = math.random(1000,9999)..'-'..math.random(1000, 9999)
					else
						target[key] = defaultValue
					end
				end
			end
		end
	end

	applyDefaults(self.config.defaultData, data)

	if not data.gender or type(data.gender) ~= 'string' then
		data.gender = 'unknown'
	end

	if not self.players[id] then
		self.players[id] = data
		Framework.log('Create player successfully', 'info')
	end

	print(json.encode(self.players[id], {indent = true}))
end

function player:removePlayer(id, reason)
	id = tostring(id)
	if id and self.players[id] then
		local success = self:save(id)
		if success then
			self.players[id] = nil
			Framework.log('Player '..id..' has left the server.\n		Reason for removal: '..reason..'.', 'info')
		end
	end
end

function player:save(id)
	id = tostring(id)
	if id and self.players[id] then
		Framework.log('Saving player(s)...','info')

		-- Save to database

		Framework.log('Player '..id..' saved successfully', 'info')
		return true
	end
	return false
end


function player:getPlayer(id)
	id = tostring(id)
	if id and self.players[id] then
		return self.players[id]
	end
end

Framework:RegisterModule('player', player)