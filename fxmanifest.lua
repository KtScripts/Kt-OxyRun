lua54 'yes'

fx_version 'cerulean'
game 'gta5'

description 'Oxy Run Script for QBCore with ox_target and ox_inventory'

shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@qb-core/server/main.lua',
    'server.lua'
}
