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

function SpawnShell(model, coords, props)
    lib.requestModel(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(obj, true)
    SetEntityCanBeDamaged(obj, false)
    SetEntityCollision(obj, true, false)
    SetEntityDynamic(obj, false)
    SetEntityHasGravity(obj, false)
    return obj
end

function RemoveShell(obj, model)
    DeleteObject(obj)
    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('Housing:c:AddProperty', function (data)
    Properties[data[1]] = data[2]
end)

RegisterNetEvent('Housing:c:RemoveProperty', function (id)
    table.remove(Properties, id)
end)