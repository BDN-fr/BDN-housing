--       /\     |‾|  |‾|  /‾‾‾‾\  |‾|  |‾|  /‾‾‾‾\ |‾‾‾‾‾‾| |‾‾\ |‾|  /‾‾‾‾‾\ 
--      /[]\    | |__| | | /‾‾\ | | |  | | |  ___/  ‾|  |‾  |   \| | | |‾‾‾‾ 
--     /____\   |      | | |  | | | |  | |  \    \   |  |   | \  \ | | |____ 
--     |_   |   | |‾‾| | | \__/ | | \__/ |  /‾‾‾  | _|  |_  | |\   | | |__  |
--     |_|__|   |_|  |_|  \____/   \____/   \____/ |______| |_| \__|  \____/ 
-- By BDN_fr - https://bdn-fr.xyz/ | Open Source - https://github.com/BDN-fr/BDN-housing

print(([[

    /\     
   /[]\    %s
  /____\   By BDN_fr - https://bdn-fr.xyz/
  |_   |   Open Source - https://github.com/BDN-fr/BDN-housing
  |_|__|   
]]):format(GetCurrentResourceName()))

CurrentPropertyId = nil
CurrentPropertyObj = nil
CurrentPropertyCoords = nil
CurrentPropertyFurnitures = {}

local exiting

RegisterNetEvent('esx:setJob', function(job, lastJob)
    ESX.PlayerData.job = job
    ShowJobBlips()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew, skin)
    ESX.PlayerData = xPlayer
    ESX.PlayerData.job = xPlayer.job
    ESX.PlayerData.job.name = xPlayer.job.name
    ShowJobBlips()
end)

RegisterNetEvent('esx:onPlayerLogout', function ()
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
    if not p then return end
    if state then
        if not p.blip then
            p.blip = CreateBlip(p.enter_coords, Config.blip)
        end
    else
        RemoveBlip(p.blip)
        p.blip = nil
    end
end)

function ShowJobBlips()
    if ESX.PlayerData.job.name == Config.Job.name then
        for k,v in pairs(Properties) do
            if not v.jobBlip then
                v.jobBlip = CreateBlip(v.enter_coords, Config.Job.blip)
            end
        end
    else
        for k,v in pairs(Properties) do
            if v.jobBlip then RemoveBlip(v.jobBlip) end
            v.jobBlip = nil
        end
    end
end

CreateThread(function (threadId)
    local uiText
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
            if v then
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(v.enter_coords - pos)
                if dist < nearestDist and k ~= 'preview' then
                    nearestDist = dist
                    nearestCoords = v.enter_coords
                    nearestId = k
                end
            end
        end
        local waitTime = nearestDist/3
        if nearestDist < 30 then
            waitTime = 1
            DrawConfigMarker(nearestCoords)

            if nearestDist < 2 then
                if not lib.isTextUIOpen() then
                    lib.callback('Housing:s:IsPropertyLocked', 1000, function (res)
                        state = res
                    end, nearestId)
                    if ESX?.PlayerData?.job?.name == Config.Job.name then
                        uiText = L('PropertyEnterText')..L('PropertyEnterTextJob')
                    else
                        uiText = L('PropertyEnterText')
                    end
                    lib.showTextUI(uiText)
                end

                stateText = state and '🔓' or '🔒'
                ESX.Game.Utils.DrawText3D(vec3(nearestCoords.xy, nearestCoords.z+Config.stateOffset), stateText, 1.0, 1)

                if IsControlJustReleased(0, 51) then
                    if state then
                        EnterProperty(nearestId)
                    elseif lib.callback.await('Housing:s:DoesIHavePropertyKey', 1000, nearestId) then
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

                if ESX.PlayerData.job.name == Config.Job.name then
                    if IsControlJustReleased(0, 303) then
                        OpenPropertyJobMenu(nearestId)
                    end
                end
            else
                local isOpen, currentText = lib.isTextUIOpen()
                if isOpen and currentText == uiText then
                    lib.hideTextUI()
                end
            end
        end
        Wait(waitTime)
    end
end)

function EnterProperty(propertyId, shellType)
    local preview = propertyId == 'preview'
    if preview then
        Properties[propertyId] = {shell = shellType, enter_coords = GetEntityCoords(PlayerPedId())}
    end
    CreateThread(function (threadId)
        local p = Properties[propertyId]

        DoScreenFadeOut(500)
        FreezeEntityPosition(PlayerPedId(), true)

        local coords = vec3(p.enter_coords.x, p.enter_coords.y, p.enter_coords.z+300)
        CurrentPropertyCoords = coords
        local doorCoords = coords + Config.Shells[p.shell].door

        Wait(500)

        if not preview then
            -- This is a callback because we need to wait to be in the right bucket
            lib.callback.await('Housing:s:EnterProperty', 1000, propertyId)
        end

        if Config.onPropertyEnter then
            Config.onPropertyEnter(propertyId)
        end

        CurrentPropertyObj = SpawnProp(p.shell, coords)

        local furnitures = lib.callback.await('Housing:s:GetPropertyFurnitures', 100, propertyId)
        SpawnFurnitures(coords, furnitures)

        SetEntityCoords(PlayerPedId(), doorCoords.x, doorCoords.y, doorCoords.z, false, false, false, false)

        CurrentPropertyId = propertyId

        DoScreenFadeIn(500)
        FreezeEntityPosition(PlayerPedId(), false)

        CreateThread(function (threadId)
            local maxDims = GetModelDimensions(p.shell)*2
            while CurrentPropertyId == propertyId and not exiting do
                Wait(500)
                local distVec = coords - GetEntityCoords(PlayerPedId())
                local maxDist = math.abs(maxDims.x) + math.abs(maxDims.y) + math.abs(maxDims.z)
                if
                    -- math.abs(distVec.x) > math.abs(maxDims.x) or
                    -- math.abs(distVec.y) > math.abs(maxDims.y) or
                    -- math.abs(distVec.z) > math.abs(maxDims.z)
                    math.max(math.abs(distVec.x), math.abs(distVec.y), math.abs(distVec.z)) > maxDist
                then
                    SetEntityCoords(PlayerPedId(), doorCoords.x, doorCoords.y, doorCoords.z, false, false, false, false)
                end
            end
        end)

        if preview then return end

        CreateThread(function (threadId)
            local uiText = '[E] - '..L('OpenMenu')
            lib.hideTextUI()
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

        CreateThread(function (threadId)
            local uiText = '[E] - '..L('OpenStorage')
            while CurrentPropertyId == propertyId do
                if Properties[CurrentPropertyId].storage_coords then
                    DrawConfigMarker(CurrentPropertyCoords + Properties[CurrentPropertyId].storage_coords)
                    local coords = GetEntityCoords(PlayerPedId())
                    local dist = #(coords - (CurrentPropertyCoords + Properties[CurrentPropertyId].storage_coords))
                    if dist < 2 then
                        if not lib.isTextUIOpen() then
                            lib.showTextUI(uiText)
                        end

                        if IsControlJustReleased(0, 51) then
                            OpenStorage(CurrentPropertyId)
                        end
                    else
                        local isOpen, currentText = lib.isTextUIOpen()
                        if isOpen and currentText == uiText then
                            lib.hideTextUI()
                        end
                    end
                    Wait(0)
                else
                    Wait(1000)
                end
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
    exiting = true
    local preview = CurrentPropertyId == 'preview'
    DoScreenFadeOut(500)
    FreezeEntityPosition(PlayerPedId(), true)
    Wait(500)
    ---@diagnostic disable-next-line: param-type-mismatch
    DeleteObject(CurrentPropertyObj)
    RemoveFurnitures(CurrentPropertyFurnitures)
    if not preview then
        -- This is a callback because we need to wait to be in the right bucket
        lib.callback.await('Housing:s:ExitProperty', 1000, true)
    end
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
    SetEntityCoords(PlayerPedId(), Properties[CurrentPropertyId].enter_coords, false, false, false, false)
    if Config.onPropertyExit then
        Config.onPropertyExit(CurrentPropertyId)
    end
    if preview then
        Properties[CurrentPropertyId] = nil
    end
    CurrentPropertyId = nil
    CurrentPropertyObj = nil
    CurrentPropertyCoords = nil
    FreezeEntityPosition(PlayerPedId(), false)
    DoScreenFadeIn(500)
    exiting = false
end

function RingProperty(propertyId)
    TriggerServerEvent('Housing:s:RingProperty', propertyId)
    Config.Notify(L('YouRinged'), 'success')
end

function TogglePropertyLock(propertyId)
    TriggerServerEvent('Housing:s:TogglePropertyLock', propertyId)
end