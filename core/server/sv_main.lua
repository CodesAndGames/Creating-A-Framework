AddEventHandler('playerDropped', function(reason)
	local src = source
	Framework.modules.player:removePlayer(src, reason or 'no reason')
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
	TriggerClientEvent('updateclienthud', target, player, target)
end)


RegisterNetEvent('updatehud', function()
	print('updating hud')
	local src = source
	local player = Framework.modules.player:getPlayer(src)
	if player then
		TriggerClientEvent('updateclienthud', src, player, src)
	else
		print('no player.')
	end
end)

RegisterNetEvent('getCharacters', function()
	local src = source
	local characters = Framework.modules.player:getCharactersForUI(src)
	Framework:TriggerCallback('loadCharacters', function(result)
		print("yay?")
	end, src, characters)
end)