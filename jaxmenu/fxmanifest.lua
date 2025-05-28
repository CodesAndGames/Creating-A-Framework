fx_version "cerulean"
game "gta5"
ui_page 'build/index.html'

client_scripts {
	'client/menu_config.lua',
	'client/client.lua'
}

files {
	'build/*',
	'build/**/*'
}

exports {
	'GetMenu',
	'openMenu',
	'RegisterMenu'
}