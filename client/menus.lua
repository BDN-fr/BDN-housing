lib.registerContext({
    id = 'jobMenu',
    title = L('JobMenuTitle'),
    canClose = true,
    options = {
        {
            title = L('CreateProperty'),
            onSelect = function ()
                CreateProperty()
            end
        }
    }
})

function OpenJobMenu()
    if ESX.PlayerData.job.name ~= Config.Job.name then return end
    lib.showContext('jobMenu')
end

RegisterCommand('housing-job-menu', function ()
    OpenJobMenu()
end, false)
RegisterKeyMapping('housing-job-menu', L('JobMenuTitle'), 'keyboard', Config.Job.menuKey)

lib.registerContext({
    id = 'propertyMenu',
    title = L('PropertyMenuTitle'),
    canClose = true,
    options = {
        {
            title = L('Exit'),
            onSelect = function ()
                ExitProperty()
            end
        },
        {
            title = L('ToggleLock'),
            onSelect = function ()
                TogglePropertyLock(CurrentPropertyId)
            end
        },
        {
            title = L('GetKey'),
            onSelect = function ()
                TriggerServerEvent('Housing:s:giveKey', CurrentPropertyId)
            end
        },
        {
            title = L('FurnitureMenuTitle'),
            onSelect = function ()
                OpenFurnitureMenu()
            end
        }
    }
})

function OpenPropertyMenu(propertyId)
    if lib.getOpenContextMenu() == 'propertyMenu' then return end
    if lib.getOpenMenu() then return end
    lib.showContext('propertyMenu')
end

local isPreviewActive = false
lib.registerMenu({
    id = 'furnitureMenu',
    title = L('FurnitureMenuTitle'),
    options = {
        {
            label = L('PlacedFurnitures'),
            args = {
                func = function (selected, scrollIndex, args)
                    OpenPlacedFurnituresMenu()
                end
            }
        },
        {
            label = L('PreviewFurnitures'),
            checked = isPreviewActive
        },
        {
            label = L('PlaceCustomModel'),
            args = {
                action = 'askModel'
            }
        }
    },
    canClose = true,
    onCheck = function (selected, checked, args)
        if selected == 2 then
            if checked then
                StartPreview()
                isPreviewActive = true
            else
                StopPreview()
                isPreviewActive = false
            end
        end
    end,
    onClose = function (keyPressed)
        if isPreviewActive then
            StopPreview()
        end
    end
}, function(selected, scrollIndex, args)
    if args?.action then
        if args.action == 'askModel' then
            local input = lib.inputDialog(L('PlaceCustomModel'), {
                {type = 'input', label = L('Model'), required = true}
            })
            if input and IsModelValid(input[1]) then
                if isPreviewActive then
                    PreviewProp(input[1])
                    WaitInput(L('PreviewValidationText'), {51, 73}, function (key)
                        StopPreview()
                        isPreviewActive = false
                        if key == 73 then
                            return
                        end
                    end)
                end
                PlaceFurniture(input[1])
            else
                Config.Notify(L('InvalidModel'), 'error')
                if isPreviewActive then
                    StopPreview()
                end
            end
            OpenFurnitureMenu()
        end
    end
    if args?.func then
        args.func(selected, scrollIndex, args)
    end
end)

function OpenFurnitureMenu()
    if not CurrentPropertyId then
        Config.Notify(L('YouNeedToBeInside'), 'error')
        return
    end
    if lib.getOpenMenu() then return end
    lib.showMenu('furnitureMenu')
end
RegisterCommand('housing-furniture-menu', function ()
    OpenFurnitureMenu()
end, false)
RegisterKeyMapping('housing-furniture-menu', L('FurnitureMenuTitle'), 'keyboard', Config.furnitureMenuKey)

local options, currentEntity
lib.registerMenu({
    id = 'placedFurnituresMenu',
    title = L('PlacedFurnitures'),
    options = {},
    canClose = true,
    onClose = function (keyPressed)
        if currentEntity then
            SetEntityDrawOutline(currentEntity, false)
        end
        OpenFurnitureMenu()
    end,
    onSelected = function (selected, secondary, args)
        if currentEntity then
            SetEntityDrawOutline(currentEntity, false)
        end
        currentEntity = args.entity
        SetEntityDrawOutline(currentEntity, true)
    end
}, function(selected, scrollIndex, args)
    SetEntityDrawOutline(args.entity, false)
    DeleteFurniture(CurrentPropertyId, args.id)
    if scrollIndex == 2 then
        PlaceFurniture(args.model)
    end
    OpenPlacedFurnituresMenu()
end)

function OpenPlacedFurnituresMenu()
    if lib.getOpenMenu() then return end
    options, currentEntity = {}, nil

    for k, v in pairs(CurrentPropertyFurnitures) do
        table.insert(options, {
            label = Config.PropsNames[v.model] or v.model,
            values = {L('Delete'), L('ChangePos')},
            args = {
                id = k,
                model = v.model,
                entity = v.obj
            },
        })
    end
    lib.setMenuOptions('placedFurnituresMenu', options)
    lib.showMenu('placedFurnituresMenu')
end