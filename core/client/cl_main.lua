AddEventHandler('playerSpawned', function()
	print('you have spawned.')
	TriggerServerEvent('Framework:onSpawn')
end)