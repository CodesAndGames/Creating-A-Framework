fx_version 'cerulean'
game 'gta5'
ui_page 'nui/index.html'

shared_script 'init.lua'
server_script '@oxmysql/lib/MySQL.lua'
server_scripts {
	'modules/base.lua',
	'modules/characters.lua',
}

client_scripts {
	'client/base.lua',
	'client/characters.lua',
}

files {
	'bridge/*.lua',
	'shared.lua',
	'main.lua',
	'cfg/config.lua',
	'nui/*',
	'nui/**/*'
}

dependency 'oxmysql'
