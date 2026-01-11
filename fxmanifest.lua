--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   |      | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | Open Source - https://github.com/BDN-fr/BDN-housing

game 'gta5'
fx_version 'cerulean'
lua54 'yes'

author 'BDN_fr - bdn-fr.xyz'
description 'A FiveM housing script, working with shells'
version '2.0.0'

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