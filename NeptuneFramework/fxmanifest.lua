fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'k x2z h'
description 'Neptune Framework'
version '0.0.1'

client_scripts {
    'client/functions.lua',
    'client/main.lua',

    'common/*.lua',

    'client/instances/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/common.lua',
    'server/classes/*.lua',
    'server/functions.lua',
    'server/main.lua',

    'common/*.lua',
}

dependencies {
    '/native:0x6AE51D4B',
    'spawnmanager',
}