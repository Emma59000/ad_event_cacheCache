fx_version 'adamant'

game 'gta5'

client_script {
	'config.lua',
    "client/*.lua",
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
    "server/*.lua",
}

ui_page('html/index.html')

files {
    'html/utils/*.png',
    'html/js/index.js',
    'html/css/style.css',
    'html/index.html',
}