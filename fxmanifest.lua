fx_version 'cerulean'
game 'gta5'
author 'Dezzu'
description 'Dezzu_shoprobbery'
lua54 'yes'

client_scripts {
    'client/client.lua',
}

server_scripts {
    'shared_config/sv_config.lua',
    'server/server.lua',
    
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared_config/config.lua',
    
}
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/js.js',
}