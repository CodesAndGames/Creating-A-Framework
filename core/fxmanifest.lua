fx_version 'cerulean'
game 'gta5'

server_scripts {
	'init.lua',
	'sh_framework.lua',
	-- Load all modules below here.
	'server/modules/player.lua',

	-- Load main.lua last so it loads all modules before it.
	'server/sv_main.lua',
}

client_scripts {
	'init.lua',
	'sh_framework.lua',
	-- Load all modules below here.
	-- 'client/modules/something.lua',
	
	-- Load main.lua last so it loads all modules before it.
	'client/cl_main.lua',
}

files {
	'config.lua',
	'sh_framework.lua'
}

dependency 'oxmysql'
