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
        }
    }
})

function OpenPropertyMenu(propertyId)
    lib.showContext('propertyMenu')
end