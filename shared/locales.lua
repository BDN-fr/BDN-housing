Locales = {
    fr = {
        CreateProperty = 'Créer une propriété',
        PlaceEnter = 'Placer l\'entrée',
        InteriorType = 'Type d\'interrieur',
        CantCarryKey = 'Vous n\'avez pas la place de porter la clé',
        CreationCanceled = 'Création de la propriété annulée',
        JobMenuTitle = 'Menu Agent immo',
        Property = 'Propriété'
    }
}

function L(id)
    return Locales[Config.lang]?[id] or 'Locale '+ id +' undefined'
end