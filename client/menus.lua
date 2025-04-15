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
            title = L('LockUnlock'),
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
    lib.showContext('propertyMenu')
end

lib.registerMenu({
    id = 'furnitureMenu',
    title = L('FurnitureMenuTitle'),
    options = {
        {
            label = L('PreviewFurnitures'),
            checked = false
        }
    },
    canClose = true,
    onCheck = function (selected, checked, args)
        print(selected, checked, args)
    end
}, function(selected, scrollIndex, args)
    print(selected, scrollIndex, args)
end)

function OpenFurnitureMenu()
    lib.showMenu('furnitureMenu')
end