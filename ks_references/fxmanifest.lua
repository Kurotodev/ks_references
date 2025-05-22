fx_version 'bodacious'
game 'gta5'
lua54 'yes'
description 'Kurotodev - Reference Menu'
version '1.0.0'
author 'kurotodev'
discord 'https://discord.gg/AjhhfKbDFH'
ui_page 'html/index.html'
files {
    'html/index.html',
    'html/assets/*.*'
}
client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'escrow/client.lua'
}
server_scripts {
    'config.lua',
    'escrow/server.lua'
}
