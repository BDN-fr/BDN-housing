Config = Config or {}

Config.Shells = {
    ['shell_michael'] = {
        label = 'Maison de richou $$$',
        door = vec3(-8.914551, 5.559937, -4.064697)
    }
}

if IsDuplicityVersion() then return end
for model, v in pairs(Config.Shells) do
    if not IsModelValid(v.model) then
        Config.Shells[model] = nil
        lib.print.warn(('Shell model %s is invalid, it got removed from the shell list. To remove this message, remove the model from the shells'):format(model))
    end
end