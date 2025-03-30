local config = module('config')
local Framework = module('sh_framework')

--[[ CALLBACKS ]]
Framework:RegisterCallback('saveCharacter', function(source, data)
	local src = source
	local identifier = GetPlayerIdentifierByType(src,'fivem')
	local charData= {
		character_id = data.slot..'-'..identifier,
		firstname = data.character.firstName,
		lastname = data.character.lastName,
		age = data.character.age,
		gender = data.character.gender,
		phone = math.random(1111111111,9999999999)
	}
	local success = Framework.modules.player:addPlayer(src, charData)
	return success
end)

Framework:RegisterCallback('selectCharacter', function(source, data)
	local src = source
	local identifer = GetPlayerIdentifierByType(src, 'fivem')

	local slot = math.floor(tonumber(data.index)) + 1
	local charID = slot..'-'..identifer
	if config.debug then
		Framework.log('charID variable is: '..charID, 'info')
		Framework.log('Attempting to select character '.. charID, 'info')
	end

	local success = Framework.modules.player:select(src, charID)
	if not success then
		return Framework.log('no character selected.', 'info')
	end
	return 'ok'
end)


