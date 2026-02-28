Config = Config or {}

Config.defaultRoutingBucket = 0

---@diagnostic disable-next-line: duplicate-set-field
Config.Notify = function (playerId, message, type)
    -- Possible types : 'info', 'success', 'error', 'warning'
    TriggerClientEvent('Housing:c:Notify', playerId, message, type)
end