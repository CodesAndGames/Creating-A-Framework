fx_version 'cerulean'
game 'gta5'

ui_page 'nui/index.html'

server_script '@oxmysql/lib/MySQL.lua'
server_scripts {
	'init.lua',
	'sh_framework.lua',
	-- Load all modules below here.
	'server/modules/player.lua',
	-- Load main.lua last so it loads all modules before it.
	'server/sv_main.lua',
	'server/sv_chars.lua',
}

client_scripts {
	'init.lua',
	'sh_framework.lua',
	'client/cl_main.lua',
	'client/cl_chars.lua',
}

files {
	'config.lua',
	'sh_framework.lua',
	'nui/*',
	'nui/**/*'
}

dependency 'oxmysql'
