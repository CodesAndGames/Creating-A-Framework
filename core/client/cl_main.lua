local config = module('config')

AddEventHandler('playerSpawned', function()
	print('you have spawned.')
	TriggerServerEvent('Framework:onSpawn')
	Wait(1000)

	if not config.enableHud then
		return
	end
	TriggerServerEvent('updatehud')
end)

RegisterNetEvent('updateclienthud', function(playerdata)
	print(json.encode(playerdata))
	local bankaccount = playerdata.bank
	local playername = playerdata.firstname.." "..playerdata.lastname

	exports['hud']:updatehud({
		playerName = playername,
		blackmoney = 0,
		cash = bankaccount.cash,
		bank = bankaccount.checking.balance,
		job = 'Trash Collector'
	})
end)