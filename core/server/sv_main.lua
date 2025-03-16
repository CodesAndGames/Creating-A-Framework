RegisterNetEvent('Framework:onSpawn', function()
	Framework.modules.player:addPlayer({
		firstname = 'john',
		lastname = 'doe',
		age = 21,
	})
end)

AddEventHandler('playerDropped', function(reason)
	local src = source

	local player = Framework.modules.player:getPlayer(src)
	print(player.firstname)

	Framework.modules.player:removePlayer(src, reason or 'no reason')
end)