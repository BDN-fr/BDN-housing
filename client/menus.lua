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
    options = {},
    canClose = true,
    onCheck = function (selected, checked, args)
        if args.type == 'preview' then
            isPreviewActive = checked
            -- if checked then
            --     -- StartPreview()
            -- else
            --     -- StopPreview()
            -- end
            if not checked then
                StopPreview()
            end
        end
    end,
    onClose = function (keyPressed)
        if isPreviewActive and keyPressed then
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
        if args.action == 'OpenPlacedFurnituresMenu' then
            OpenPlacedFurnituresMenu()
        end
        if args.action == 'OpenCategory' then
            OpenCategory(args.category)
        end
        if args.action == 'OpenLayouts' then
            LayoutsMenu()
        end
    end
end)

function OpenFurnitureMenu()
    if not CurrentPropertyId then
        Config.Notify(L('YouNeedToBeInside'), 'error')
        return
    end
    if lib.getOpenMenu() then return end

    local count = 0
    for k, v in pairs(CurrentPropertyFurnitures) do
        count += 1
    end
    local options = {
        {
            label = L('PlacedFurnitures')..(' | %s/%s'):format(count, Config.maxFurnitures),
            args = {
                action = 'OpenPlacedFurnituresMenu'
            }
        },
        {
            label = L('PreviewFurnitures'),
            checked = isPreviewActive,
            args = {
                type = 'preview'
            }
        },
        {
            label = L('Layouts'),
            args = {
                action = 'OpenLayouts'
            }
        },
        {
            label = L('PlaceCustomModel'),
            args = {
                action = 'askModel'
            }
        },
        {
            label = L('Separator')
        }
    }
    for k, v in pairs(Config.Props) do
        table.insert(options, {
            label = k,
            args = {
                action = 'OpenCategory',
                category = k
            }
        })
    end
    lib.setMenuOptions('furnitureMenu', options)
    lib.showMenu('furnitureMenu')
end
RegisterCommand('housing-furniture-menu', function ()
    OpenFurnitureMenu()
end, false)
RegisterKeyMapping('housing-furniture-menu', L('FurnitureMenuTitle'), 'keyboard', Config.furnitureMenuKey)

lib.registerMenu({
    id = 'furnitureCategoryMenu',
    title = L('FurnitureMenuTitle'),
    options = {},
    canClose = true,
    onClose = function (keyPressed)
        if isPreviewActive then
            StopPreview()
        end
        OpenFurnitureMenu()
    end,
    onSelected = function (selected, secondary, args)
        if isPreviewActive then
            PreviewProp(args.model)
        end
    end
}, function (selected, scrollIndex, args)
    if isPreviewActive then
        isPreviewActive = false
        StopPreview()
    end
    PlaceFurniture(args.model)
end)

function OpenCategory(category)
    local options = {}
    for i, v in ipairs(Config.Props[category]) do
        table.insert(options, {
            label = v.label,
            args = {
                model = v.model
            }
        })
    end
    lib.setMenuOptions('furnitureCategoryMenu', options)
    lib.showMenu('furnitureCategoryMenu')
end

local currentEntity
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
        if not args.entity then return end
        if currentEntity then
            SetEntityDrawOutline(currentEntity, false)
        end
        currentEntity = args.entity
        SetEntityDrawOutline(currentEntity, true)
    end
}, function(selected, scrollIndex, args)
    if not args.entity then return end
    SetEntityDrawOutline(args.entity, false)
    DeleteFurniture(CurrentPropertyId, args.id)
    if scrollIndex == 2 then
        PlaceFurniture(args.model)
    end
    OpenPlacedFurnituresMenu()
end)

function OpenPlacedFurnituresMenu()
    if lib.getOpenMenu() then return end
    local options = {}
    currentEntity = nil

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
    if #options == 0 then
        table.insert(options, {
            label = L('NoFurnitures')
        })
    end
    lib.setMenuOptions('placedFurnituresMenu', options)
    lib.showMenu('placedFurnituresMenu')
end

lib.registerMenu({
    id = 'layouts',
    title = L('Layouts'),
    options = {},
    canClose = true,
    onClose = function (keyPressed)
        if keyPressed then
            OpenFurnitureMenu()
        end
    end
}, function (selected, scrollIndex, args)
    if args?.action == 'saveLayout' then
        SavePropertyLayout()
    else
        if scrollIndex == 1 then
            LoadPropertyLayout(args.id)
        elseif scrollIndex == 2 then
            lib.callback.await('Housing:s:DeleteLayout', 1000, args.id)
            LayoutsMenu()
        end
    end
end)

function LayoutsMenu()
    local options = {
        {
            label = L('SaveLayout'),
            args = {
                action = 'saveLayout'
            }
        }
    }
    local layouts = lib.callback.await('Housing:s:GetPlayerLayouts', 1000)
    for i, v in ipairs(layouts) do
        if v.shell == Properties[CurrentPropertyId].shell then
            table.insert(options, {
                label = v.name,
                values = {
                    {label = L('Load'), description = L('LoadWaring')},
                    {label = L('Delete')}
                },
                args = {
                    id = v.id
                }
            })
        end
    end
    lib.setMenuOptions('layouts', options)
    lib.showMenu('layouts')
end