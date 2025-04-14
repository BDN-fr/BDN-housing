--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   | |  | | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | For Olympe WL - https://discord.gg/fH8bSDBFvK

print(([[

    /\     
   /[]\    O-housing (%s)
  /____\   By BDN_fr - https://bdn-fr.xyz/
  |_   |   For Omlympe WL - https://discord.gg/fH8bSDBFvK
  |_|__|   
]]):format(GetCurrentResourceName()))

RegisterNetEvent('esx:setJob', function(job, lastJob)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew, skin)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('Housing:c:RegisterProperties', function (properties)
    Properties = properties
end)
TriggerServerEvent('Housing:s:HeySendMePropertiesPlease')

CreateThread(function (threadId)
    while not Properties do
        Wait(1)
    end
    while true do
        local nearestDist = math.maxinteger
        local nearestCoords = vec3(0,0,0)
        for k,v in pairs(Properties) do
            local pos = GetEntityCoords(PlayerPedId())
            local dist = #(v.enter_coords - pos)
            if dist < nearestDist then
                nearestDist = dist
                nearestCoords = v.enter_coords
            end
        end
        local waitTime = nearestDist/3
        if nearestDist < 30 then
            waitTime = 1
            DrawConfigMarker(nearestCoords)
        end
        Wait(waitTime)
    end
end)

RegisterNetEvent('Housing:c:SubToProperty', function (propertyId, state)
    local p = Properties[propertyId]
    print(p, propertyId, type(propertyId))
    if not p then print('No property '..propertyId) return end
    if state then
        if not p.blip then
            local blip = AddBlipForCoord(p.enter_coords.x, p.enter_coords.y, p.enter_coords.z)
            SetBlipSprite(blip, Config.blip.sprite)
            SetBlipColour(blip, Config.blip.color)
            SetBlipScale(blip, Config.blip.scale)
            SetBlipDisplay(blip, Config.blip.display)
            SetBlipAlpha(blip, Config.blip.alpha)
            SetBlipAsShortRange(blip, Config.blip.showAtShortRange)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(L('Property'))
            EndTextCommandSetBlipName(blip)
            p.blip = blip
        end
    else
        RemoveBlip(p.blip)
        p.blip = nil
    end
end)