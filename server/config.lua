Config = Config or {}

---@diagnostic disable-next-line: duplicate-set-field
Config.Notify = function (playerId, message, type)
    print(playerId, message, type)
end