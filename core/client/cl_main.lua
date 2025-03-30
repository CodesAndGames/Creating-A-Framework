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
