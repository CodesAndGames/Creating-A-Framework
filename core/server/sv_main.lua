RegisterNetEvent('Framework:onSpawn', function()
	local src = source
	Wait(100)
	Framework.modules.player:addPlayer(src, {
		firstname = 'john',
		lastname = 'doe',
		age = 21,
	})
end)


AddEventHandler('playerDropped', function(reason)
	local src = source
	Framework.modules.player:removePlayer(src, reason or 'no reason')
end)


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
Framework:query('AddToPlayers', [[INSERT INTO players (identifier, cData) VALUES (@identifier, @cData)]])
Framework:query('SavePlayer', [[UPDATE players SET cData = @cData WHERE identifier = @identifier]])

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		Framework:execute('InitDatabase')
	end
end)


RegisterCommand('changeMoney', function(source, args) -- /changeMoney add 500 1 cash
	local action = args[1]
	local amount = tonumber(args[2])
	local target = tonumber(args[3])
	local account = args[4]

	if action == 'add' then
		Framework.modules.player:addMoney(target, amount, account)
	elseif action == 'remove' then
		Framework.modules.player:removeMoney(target, amount, account)
	else
		return Framework.log('Invalid action.', 'error')
	end
	local player = Framework.modules.player:getPlayer(target)
	Framework.log('Successfully updated '..account..' to '..json.encode(player.bank), 'info')
end)