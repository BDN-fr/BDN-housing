Config = Config or {}

Config.Props = {
    Plantes = {
        {
            model = 'prop_pot_plant_01c',
            label = 'Plante de fou'
        }
    },
    Outils = {
        {
            model = 'prop_tool_pickaxe',
            label = 'Pioche miam miam'
        },
        {
            model = 'prop_tool_fireaxe';
            label = 'Hache de bucheron qui coupe du bois'
        },
        {
            model = 'prop_tool_broom',
            label = 'Le balais que t\'as dans le cul'
        }
    }
}

-- Don't touch this
Config.PropsNames = {}
if IsDuplicityVersion() then return end
for k, c in pairs(Config.Props) do
    for i, v in ipairs(c) do
        
        if IsModelValid(v.model) then
            Config.PropsNames[v.model] = v.label
        else
            lib.print.warn(('Model %s is invalid, it didn\'t being added in the menu. To remove this message, remove the model from the props'):format(v.model))
        end
    end
end