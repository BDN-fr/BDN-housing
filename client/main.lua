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

CurrentPropertyId = nil
CurrentPropertyObj = nil
CurrentPropertyCoords = nil
CurrentPropertyFurnitures = {}

RegisterNetEvent('esx:setJob', function(job, lastJob)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew, skin)
    ESX.PlayerData = xPlayer
    -- When changing character
    ---@diagnostic disable-next-line: param-type-mismatch
    DeleteObject(CurrentPropertyObj)
    CurrentPropertyObj = nil
    RemoveFurnitures(CurrentPropertyFurnitures)
    CurrentPropertyId = nil
    CurrentPropertyCoords = nil
    lib.callback.await('Housing:s:ExitProperty', 1000, false)
end)

RegisterNetEvent('Housing:c:RegisterProperties', function (properties)
    Properties = properties
end)
TriggerServerEvent('Housing:s:HeySendMePropertiesPlease')

RegisterNetEvent('Housing:c:SubToProperty', function (propertyId, state)
    local p = Properties[propertyId]
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

CreateThread(function (threadId)
    local uiText = L('PropertyEnterText')
    local state
    local stateText = ''
    local nearestCoords, nearestId
    RegisterNetEvent('Housing:c:UpdateState', function (propertyId, newState)
        if nearestId == propertyId then
            state = newState
        end
    end)

    while not Properties do
        Wait(1)
    end
    while true do
        local nearestDist = math.maxinteger
        for k,v in pairs(Properties) do
            local pos = GetEntityCoords(PlayerPedId())
            local dist = #(v.enter_coords - pos)
            if dist < nearestDist then
                nearestDist = dist
                nearestCoords = v.enter_coords
                nearestId = k
            end
        end
        local waitTime = nearestDist/3
        if nearestDist < 30 then
            waitTime = 1
            DrawConfigMarker(nearestCoords)
        end
        if nearestDist < 2 then
            if not lib.isTextUIOpen() then
                lib.callback('Housing:s:IsPropertyLocked', 1000, function (res)
                    state = res
                end, nearestId)
                lib.showTextUI(uiText)
            end

            stateText = state and '🔓' or '🔒'
            ESX.Game.Utils.DrawText3D(vec3(nearestCoords.xy, nearestCoords.z+Config.stateOffset), stateText, 1.0, 1)

            if IsControlJustReleased(0, 51) then
                if state then
                    EnterProperty(nearestId)
                else
                    Config.Notify(L('LockedProperty'), 'error')
                end
            end

            if IsControlJustReleased(0, 47) then
                RingProperty(nearestId)
            end

            if IsControlJustReleased(0, 74) then
                TogglePropertyLock(nearestId)
            end
        else
            local isOpen, currentText = lib.isTextUIOpen()
            if isOpen and currentText == uiText then
                lib.hideTextUI()
            end
        end
        Wait(waitTime)
    end
end)

function EnterProperty(propertyId)
    CreateThread(function (threadId)
        local p = Properties[propertyId]

        DoScreenFadeOut(500)
        FreezeEntityPosition(PlayerPedId(), true)
        local tpTime = GetGameTimer()+500

        local coords = vec3(p.enter_coords.x, p.enter_coords.y, p.enter_coords.z+500)
        CurrentPropertyCoords = coords
        local doorCoords = coords + Config.Shells[p.shell].door

        -- This is a callback because we need to wait to be in the right bucket
        lib.callback.await('Housing:s:EnterProperty', 1000, propertyId)

        CurrentPropertyObj = SpawnProp(p.shell, coords)

        local furnitures = lib.callback.await('Housing:s:GetPropertyFurnitures', 100, propertyId)
        SpawnFurnitures(coords, furnitures)

        Wait(tpTime-GetGameTimer())
        SetEntityCoords(PlayerPedId(), doorCoords.x, doorCoords.y, doorCoords.z, false, false, false, false)

        CurrentPropertyId = propertyId

        DoScreenFadeIn(500)
        FreezeEntityPosition(PlayerPedId(), false)

        CreateThread(function (threadId)
            local uiText = '[E]: '..L('OpenMenu')
            while CurrentPropertyId == propertyId do
                DrawConfigMarker(doorCoords)
                local coords = GetEntityCoords(PlayerPedId())
                local dist = #(coords - doorCoords)
                if dist < 2 then
                    if not lib.isTextUIOpen() then
                        lib.showTextUI(uiText)
                    end

                    if IsControlJustReleased(0, 51) then
                        OpenPropertyMenu(CurrentPropertyId)
                    end
                else
                    local isOpen, currentText = lib.isTextUIOpen()
                    if isOpen and currentText == uiText then
                        lib.hideTextUI()
                    end
                end
                Wait(0)
            end
            local isOpen, currentText = lib.isTextUIOpen()
            if isOpen and currentText == uiText then
                lib.hideTextUI()
            end
        end)
    end)
end
RegisterNetEvent('Housing:c:EnterProperty', EnterProperty)

function ExitProperty()
    DoScreenFadeOut(500)
    FreezeEntityPosition(PlayerPedId(), true)
    Wait(500)
    ---@diagnostic disable-next-line: param-type-mismatch
    DeleteObject(CurrentPropertyObj)
    RemoveFurnitures(CurrentPropertyFurnitures)
    -- This is a callback because we need to wait to be in the right bucket
    lib.callback.await('Housing:s:ExitProperty', 1000)
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
    SetEntityCoords(PlayerPedId(), Properties[CurrentPropertyId].enter_coords, false, false, false, false)
    CurrentPropertyId = nil
    CurrentPropertyObj = nil
    CurrentPropertyCoords = nil
    FreezeEntityPosition(PlayerPedId(), false)
    DoScreenFadeIn(500)
end

function RingProperty(propertyId)
    print('Ding DRRIIIIIIING')
end

function TogglePropertyLock(propertyId)
    TriggerServerEvent('Housing:s:TogglePropertyLock', propertyId)
end