exports('updatehud', function(data)
	SendNUIMessage({
		action = 'updatehud',
		data
	})
end)


RegisterCommand('updatehud', function(source)
	exports['hud']:updatehud({
		cash = 1,
		bank = 1,
		blackmoney = 1,
		playerName = 'John Doe',
		playerid = 1
	})
end)