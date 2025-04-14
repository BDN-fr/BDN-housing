Config = Config or {}

Config.marker = { -- https://docs.fivem.net/natives/?_0x28477EC23D892089
    type = 20,
    zOffset = 0,
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

Config.PlaceProp = function(handle)
    exports['object_gizmo']:useGizmo(handle)
end

Config.Notify = function (message, type)
    -- Put your function here
    print(message, type)
end