function Framework()
	local self = module('shared')()
	return self
end

Framework = Framework()

-- vRP2 inspired proxy system
local Proxy = module('bridge/bridge')
local pFW = {}
Proxy.addInterface('Framework', pFW)
---
AddEventHandler('playerSpawned', function()
	Framework:triggerEvent('isReady')
	TriggerServerEvent('Framework:isReady')
end)

RegisterNetEvent('updateclienthud', function(playerdata, playerid)
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
