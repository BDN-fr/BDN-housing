local file = io.open(("@%s/sql.sql"):format(GetCurrentResourceName()), "r")
if not file then
    error('sql.sql not found, please create a sql.sql file with the script\'s SQL', 0)
else
    local fileContent = file:read("*a")
    MySQL.rawExecute(fileContent, function ()
        print('SQL successfully executed')
    end)
    file:close()
end

-- print([[
--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   | |  | | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | For Olympe WL - https://discord.gg/fH8bSDBFvK
-- ]])
print(([[

    /\     
   /[]\    O-housing (%s)
  /____\   By BDN_fr - https://bdn-fr.xyz/
  |_   |   For Omlympe WL - https://discord.gg/fH8bSDBFvK
  |_|__|   
]]):format(GetCurrentResourceName()))