Framework = module('main')() -- creates one single instance of this class for all server files, and resources

-- vRP2 inspired proxy system
local Proxy = module('bridge/bridge')
local pFW = {}
Proxy.addInterface('Framework', pFW)
---
--- Events
RegisterNetEvent('Framework:isReady',function()
	Framework:onSpawn()
	Framework:triggerEvent('playerReady')
end)

AddEventHandler('playerDropped', function()
	Framework:onLeave()
end)


-- Database queries
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
Framework:query('AddToPlayers', [[
  INSERT INTO players (identifier, cData)
  VALUES (@identifier, @cData)
  ON DUPLICATE KEY UPDATE cData = @cData
]])
Framework:query('SavePlayer', [[UPDATE players SET cData = @cData WHERE identifier = @identifier]])

RegisterCommand('changeMoney', function(source, args) -- /changeMoney add 500 1 cash
	local player = Framework.players[source]
	if player then
	
		local action = args[1]
		local amount = tonumber(args[2])
		local target = tonumber(args[3])
		local account = args[4]

		if action == 'add' then
			player:addMoney(target, amount, account)
		elseif action == 'remove' then
			player:removeMoney(target, amount, account)
		else
			return Framework:error('Invalid action.')
		end
		TriggerClientEvent('updateclienthud', target, player, target)
	end
end)


RegisterNetEvent('updatehud', function()
	print('updating hud')
	local src = source
	local player = Framework.players[src]
	if player then
		TriggerClientEvent('updateclienthud', src, player:getCharacter(), src)
	end
end)

RegisterNetEvent('getCharacters', function()
	local src = source
	local player = Framework.players[src]
	if player then
		local characters = player:getCharactersForUI()
		Framework:TriggerCallback('loadCharacters', nil, src, characters)
	end
end)


function Base(Framework)
	local self = {}
	self.__name = "Base"
	self.tunnel = {}
	self.event = {}
	-- inherit modules
	Framework.Modules(self)

	--constructor
	function self:__construct()
		Framework:execute('InitDatabase')
	end

	function self.tunnel:doSomething()
		Framework:log("doing something on server base class")
	end

	function self.event:playerReady()
		Framework:log("Player Ready: Player is ready")
	end

	function self.event:playerLeave()
		Framework:log("Player leave: Player has disconnected")
	end

	return self
end

Framework:RegisterModule(Base)