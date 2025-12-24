Config = Config or {}

Config.marker = { -- https://docs.fivem.net/natives/?_0x28477EC23D892089
    type = 23, -- https://docs.fivem.net/docs/game-references/markers/
    zOffset = -0.95,
    dir = vec3(0.0,0.0,0.0),
    rot = vec3(0.0,0.0,0.0),
    scale = vec3(0.5,0.5,0.5),
    red = 255,
    green = 255,
    blue = 255,
    alpha = 150,
    bobUpAndDown = false,
    faceCamera = false,
    rotationOrder = 2,
    rotate = false,
	textureDict = nil,
	textureName = nil,
	drawOnEnts = false
}
Config.stateOffset = 0

Config.blip = {
    -- https://docs.fivem.net/docs/game-references/blips/
    sprite = 40,
    color = 66,
    scale = 1.0,
    display = 2, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
    alpha = 255,
    showAtShortRange = true
}

-- Config.previewCamOffset = vec3(5,5,5)

Config.Job = Config.Job or {}
Config.Job.menuKey = 'F6'
Config.Job.blip = {
    -- https://docs.fivem.net/docs/game-references/blips/
    sprite = 40,
    color = 13,
    scale = 0.5,
    display = 2, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
    alpha = 255,
    showAtShortRange = true
}

Config.furnitureMenuKey = 'F1'

Config.onPropertyEnter = function (propertyId)
    -- Désactiver la météo et mettre le jour
    SetWeatherOwnedByNetwork(false)
    NetworkOverrideClockTime(12,00,00)
    PauseClock(true)
    SetWeatherTypeNowPersist('CLEAR')
end

Config.onPropertyExit = function (propertyId)
    -- Réactiver la météo et syncroniser la bonne heure
    PauseClock(false)
    local hours, minutes, seconds = NetworkGetGlobalMultiplayerClock()
    NetworkOverrideClockTime(hours, minutes, seconds)
    NetworkClearClockTimeOverride()
    ClearWeatherTypePersist()
    ClearOverrideWeather()
    SetWeatherOwnedByNetwork(true)
end

Config.PlaceProp = function(model, coords, rot, matrix)
    -- coords, rot and matrix are optionals
    local prop = SpawnProp(model, coords or (GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 3), false)
    if rot then
        SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, false)
    end
    if matrix then
        SetEntityMatrix(
            prop,
            matrix[1].x, matrix[1].y, matrix[1].z,
            matrix[2].x, matrix[2].y, matrix[2].z,
            matrix[3].x, matrix[3].y, matrix[3].z,
            coords.x, coords.y, coords.z
        )
    end
    local data = exports['object_gizmo']:useGizmo(prop)
    data.coords = data.position
    local forward, right, up = GetEntityMatrix(prop)
    data.matrix = {forward, right, up}
    DeleteObject(prop)
    return data
    --[[
        data: {
            coords: {x:number,y:number,z:number}
            rotation: {x:number,y:number,z:number}
            matrix: {vec3, vec3, vec3}
        }
    ]]
end

Config.Garage = {}
Config.Garage.Activated = true -- Turn on / off the garage creation
Config.Garage.SlotsOptions = {1,2,3,4,5,6,7,8,10,12,16}
Config.Garage.Register = function (coords, slotsAmount)
    print(coords, slotsAmount)
end

---@diagnostic disable-next-line: duplicate-set-field
Config.Notify = function (message, type)
    -- Possible types : 'inform', 'success', 'error', 'warning'
    lib.notify({description = message, type = type})
end

RegisterNetEvent('Housing:c:Notify', function (...)
    Config.Notify(...)
end)