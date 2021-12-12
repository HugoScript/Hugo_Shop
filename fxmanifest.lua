fx_version 'cerulean'
games { 'gta5' }

author 'Philipp Decker'
description 'Lets you create context menus.'
version '1.1'

client_scripts {
	'screenToWorld.lua',

	'Drawables/Color.lua',
	'Drawables/Rect.lua',
	'Drawables/Text.lua',
	'Drawables/Sprite.lua',

	'Menu/Item.lua',
	'Menu/TextItem.lua',
	'Menu/CheckboxItem.lua',
	'Menu/SubmenuItem.lua',
	'Menu/Separator.lua',
	'Menu/Border.lua',
	'Menu/Menu.lua',
	'Menu/MenuPool.lua',

	'client.lua'
}

server_script {
	'@mysql-async/lib/MySQL.lua'
}