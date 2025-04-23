Config = Config or {}

Config.Props = {
    Plantes = {
        {
            model = 'prop_pot_plant_01c',
            label = 'Plante de fou'
        }
    }
}

-- Don't touch this
Config.PropsNames = {}
for k, c in pairs(Config.Props) do
    for i, v in ipairs(c) do
        Config.PropsNames[v.model] = v.label
    end
end