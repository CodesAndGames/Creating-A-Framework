local player = class('player')

function player:__construct()
	self.config = module('config') -- loads config

	self.characters = {} -- characters created by player
	self.cData = {} -- active character's data

	Framework.log('player module ready and started.', 'info')
end

function player:addPlayer(id, data)
	if not (id or data) or type(data) ~= 'table' then
		return Framework.log('Unable to create character due to invalid data. '..tostring(id), 'error')
	end

	id = tostring(id)
	local char_id = data.character_id
	print('adding player for id', id, char_id)

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

	self.characters[id] = self.characters[id] or {}
	self.characters[id][char_id] = data

	local identifier = GetPlayerIdentifierByType(id, 'fivem')
	local params = {
		['@identifier'] = identifier,
		['@cData'] = json.encode(self.characters[id])
	}

	local isInDb = Framework:execute('SelectPlayer', {['@identifier'] = identifier})
	if not isInDb[1] then
		local isAdded = Framework:execute('AddToPlayers', params)
		if isAdded.affectedRows > 0 then
			print('add to players was successful')
			return 'success'
		else
			print('add to players was NOT successful.')
		end
	end
	local result = Framework:execute('SavePlayer', params)
	if result.affectedRows > 0 then
		return 'success'
	else
		error('could not create character.')
		return false
	end
end

function player:removePlayer(id, reason)
	id = tostring(id)
	if self.cData[id] then
		local success = self:save(id)
		if success then
			self.cData[id] = nil
			Framework.log('Player '..id..' has left the server.\n		Reason for removal: '..reason..'.', 'info')
		end
	end
end


function player:select(id, char_id)
	id = tostring(id)
	if self.characters[id] then
		if self.characters[id][char_id] then
			self.cData[id] = self.characters[id][char_id]
			return 'ok'
		else
			print('char_id not found: '..char_id)
		end
	else
		print('no characters found for id ', id, char_id)
	end
end




function player:save(id)
	id = tostring(id)
	local identifier = GetPlayerIdentifierByType(id, 'fivem')
	if self.cData[id] then
		Framework.log('Saving player(s)...','info')
		local char_id = self.cData[id].character_id

		-- Save to database
		local isInDb = Framework:execute('SelectPlayer', {
			['@identifier'] = identifier
		})
		if isInDb[1] then
			local isSave = Framework:execute('SavePlayer', {
				['cData'] = json.encode(self.characters[id]),
				['identifier'] = identifier
			})
			if isSaved then
				Framework.log('Player '..id..' saved successfully', 'info')
				return true
			end
		else
			Framework.log('Unable to save '..id..'\'s character. Not in db')
		end
	end
	return false
end


function player:getPlayer(id)
	id = tostring(id)
	if self.cData[id] then
		return self.cData[id]
	end
end

function player:addMoney(id, amount, account) -- self:addMoney(1, 500, 'cash')
	if not (id or amount or account) or type(amount) ~= 'number' then
		return Framework.log('Cannot add money. Invalid parameters.', 'error')
	end

	id = tostring(id)
	if self.cData[id] then
		if account == 'cash' then
			self.cData[id].bank.cash = self.cData[id].bank.cash + amount
		elseif account == 'checking' then
			self.cData[id].bank.checking.balance = self.cData[id].bank.checking.balance + amount
		elseif account == 'savings' then
			self.cData[id].bank.savings.balance = self.cData[id].bank.savings.balance + amount
		else
			Framework.log('Cannot add moeny. Invalid account type.', 'error')
		end
		return
	end
end


function player:removeMoney(id, amount, account) -- self:removeMoney(1, 500, 'cash')
	if not (id or amount or account) or type(amount) ~= 'number' then
		return Framework.log('Cannot add money. Invalid parameters.', 'error')
	end

	id = tostring(id)
	if self.cData[id] then
		if account == 'cash' then
			self.cData[id].bank.cash = self.cData[id].bank.cash - amount
		elseif account == 'checking' then
			self.cData[id].bank.checking.balance = self.cData[id].bank.checking.balance - amount
		elseif account == 'savings' then
			self.cData[id].bank.savings.balance = self.cData[id].bank.savings.balance - amount
		else
			Framework.log('Cannot add moeny. Invalid account type.', 'error')
		end
		return
	end
end

function player:getAllCharacters(id)
	id = tostring(id)

	if self.characters[id] then
		return self.characters[id]
	end

	local identifier = GetPlayerIdentifierByType(id, 'fivem')
	local result = Framework:execute('SelectPlayer', {['@identifier'] = identifier})
	if result[1] and result[1].cData then
		local decoded = json.decode(result[1].cData)
		if decoded = then
			self.characters[id] = decoded
			print(json.encode(decoded))
			return decoded
		else
			Framework.log('Couldn to decode cData for player: '..identifier, 'error')
		end
	end
end

function player:getCharactersForUI(id)
	id = tostring(id)

	local characters = self.characters[id]
	local formatted = {}

	for key, char in pairs(characters or {}) do
		local slot = tonumber(key:match("^(%d+)%-%w+")) -- extracts the slot number (1,2 or 3)
		if slot then
			formatted[#formatted + 1] = {
				slot = slot,
				firstname = char.firstname,
				lastname = char.lastname, 
				age = char.age,
				-- gender = char.gender,
				-- character_id = char.character_id
				-- add more data to display in UI
			}
		end
	end
	return formatted
end

Framework:RegisterModule('player', player)