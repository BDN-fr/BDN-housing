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
RegisterKeyMapping('housing-job-menu', L('JobMenuTitle'), 'keyboard', 'F6')

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
            label = L('PlacedFurnitureList'),
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
                        if key == 51 then
                            PlaceFurnitureInProperty(CurrentPropertyId, input[1])
                        end
                    end)
                else
                    PlaceFurnitureInProperty(CurrentPropertyId, input[1])
                end
            else
                Config.Notify(L('InvalidModel'))
                if isPreviewActive then
                    StopPreview()
                end
            end
            OpenFurnitureMenu()
        end
    end
end)

function OpenFurnitureMenu()
    lib.showMenu('furnitureMenu')
end