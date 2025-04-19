fx_version 'cerulean'
game 'gta5'

description 'Casse du Casino Itinérant - ESX Legacy'
author 'ChatGPT'
version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}
