function WaitInput(message, keys, cb)
    lib.showTextUI(message)
    while true do
        Wait(0)
        for i, key in ipairs(keys) do
            if IsControlJustReleased(0, key) then
                cb(key)
                lib.hideTextUI()
                return
            end
        end
    end
end

function DrawConfigMarker(coords)
    local m = Config.marker
    DrawMarker(
        m.type,
        coords.x, coords.y, coords.z+m.zOffset,
        m.dir.x, m.dir.y, m.dir.z,
        m.rot.x, m.rot.y, m.rot.z,
        m.scale.x, m.scale.y, m.scale.z,
        m.red,
        m.green,
        m.blue,
        m.alpha,
        m.bobUpAndDown,
        m.faceCamera,
        m.rotationOrder,
        m.rotate,
        m.textureDict,
        m.textureName,
        m.drawOnEnts
    )
end

function CreateProperty()
    local isCreatingProperty = true
    local enterCoords
    WaitInput('[E] : '..L('PlaceEnter'), {51}, function (key)
        enterCoords = GetEntityCoords(PlayerPedId())
        CreateThread(function ()
            while isCreatingProperty do
                Wait(0)
                DrawConfigMarker(enterCoords)
            end
        end)
    end)
    local shellsOptions = {}
    for k,v in pairs(Config.Shells) do
        table.insert(shellsOptions, {value = k, label = v.label})
    end
    local input = lib.inputDialog(L('CreateProperty'), {
        {type = 'select', label = L('InteriorType'), options = shellsOptions, required = true, searchable = true}
    })
    if not input then
        isCreatingProperty = false
        return
    end
    local data = {}
    data.shell = input[1]
    data.enterCoords = enterCoords
    TriggerServerEvent('Housing:s:CreateProperty', data)
    isCreatingProperty = false
end

function SpawnProp(model, coords)
    lib.requestModel(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(obj, true)
    SetEntityCanBeDamaged(obj, false)
    SetEntityCollision(obj, true, false)
    SetEntityDynamic(obj, false)
    SetEntityHasGravity(obj, false)
    SetModelAsNoLongerNeeded(model)
    return obj
end

function RemoveShell(obj)
    DeleteObject(obj)
end

function SpawnFurnitures(propertyCoords, furnitures)
    for i, v in ipairs(furnitures) do
        local coords = json.decode(v.coords)
        coords = vec3(coords.x, coords.y, coords.z)
        local obj = SpawnProp(v.model, propertyCoords + coords)
        local rot = json.decode(v.rotation)
        SetEntityRotation(obj, rot.pitch, rot.roll, rot.yaw, 2, false)
        table.insert(CurrentPropertyFurnitures, obj)
    end
end

function RemoveFurnitures(furnitures)
    for i, v in ipairs(furnitures) do
        DeleteObject(v)
    end
end

RegisterNetEvent('Housing:c:AddProperty', function (data)
    Properties[data[1]] = data[2]
end)

RegisterNetEvent('Housing:c:RemoveProperty', function (id)
    table.remove(Properties, id)
end)