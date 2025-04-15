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

Config.PlaceProp = function(model)
    local prop = SpawnProp(model, GetEntityCoords(PlayerPedId()), false)
    return exports['object_gizmo']:useGizmo(prop)
end

Config.previewCamOffset = vec3(5,5,5)

---@diagnostic disable-next-line: duplicate-set-field
Config.Notify = function (message, type)
    -- Put your function here
    lib.notify({description = message, type = type})
end

RegisterNetEvent('Housing:c:Notify', function (...)
    Config.Notify(...)
end)