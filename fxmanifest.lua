--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   | |  | | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | For Odyssée WL - https://discord.gg/fH8bSDBFvK

game 'gta5'
fx_version 'cerulean'
lua54 'yes'

author 'By BDN_fr for Odyssée WL - bdn-fr.xyz'
description 'A FiveM housing script, working with shells'
version '1.1.0'

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