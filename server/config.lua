Config = Config or {}

---@diagnostic disable-next-line: duplicate-set-field
Config.Notify = function (playerId, message, type)
    TriggerClientEvent('Housing:c:Notify', playerId, message, type)
end