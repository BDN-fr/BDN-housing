game 'gta5'
fx_version 'cerulean'
lua54 'yes'

author 'By BDN_fr for Olympe WL - bdn-fr.xyz'
description 'A FiveM housing script, working with shells'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/**.lua'
}

client_scripts {
    'client/**.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**.lua'
}

dependencies {
    'oxmysql',
    'ox_lib'
}