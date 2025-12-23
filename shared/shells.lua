Config = Config or {}

Config.Shells = {
    ['shell_michael'] = {
        label = 'Maison de michael',
        door = vec3(-8.914551, 5.559937, -4.064697),
        itemType = 'big'
    },
    ['shell_garagem'] = {
        label = 'Garage',
        door = vec3(13.3,1.55,-0.78),
        itemType = 'wherehouse'
    }
}

if IsDuplicityVersion() then return end
for model, v in pairs(Config.Shells) do
    if not IsModelValid(model) then
        Config.Shells[model] = nil
        lib.print.warn(('Shell model %s is invalid, it got removed from the shell list. To remove this message, remove the model from the shells'):format(model))
    end
end