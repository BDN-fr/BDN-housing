Config = Config or {}

Config.defaultRoutingBucket = 0

Config.Storage = {
    weight = 50000,
    slots = 50
}

---@diagnostic disable-next-line: duplicate-set-field
Config.Notify = function (playerId, message, type)
    -- Possible types : 'inform', 'success', 'error', 'warning'
    TriggerClientEvent('Housing:c:Notify', playerId, message, type)
end