local config = module('config')

AddEventHandler('playerSpawned', function()
	print('you have spawned.')
	TriggerServerEvent('Framework:onSpawn')
	Wait(1500)

	if not config.enableHud then
		return
	end
	TriggerServerEvent('updatehud')
end)

RegisterNetEvent('updateclienthud', function(playerdata, playerid)
	print(json.encode(playerdata))
	local bankaccount = playerdata.bank
	local name = playerdata.firstname..' '..playerdata.lastname

	exports['hud']:updatehud({
		playerName = name,
		cash = bankaccount.cash,
		bank = bankaccount.checking.balance,
		blackmoney = 0,
		job = 'unemployed',
		playerid=playerid
	})
end)