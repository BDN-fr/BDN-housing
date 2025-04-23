Locales = {
    fr = {
        CreateProperty = 'Créer une propriété',
        PlaceEnter = 'Placer l\'entrée',
        InteriorType = 'Type d\'interrieur',
        CantCarryKey = 'Vous n\'avez pas la place de porter la clé',
        CreationCanceled = 'Création de la propriété annulée',
        JobMenuTitle = 'Menu Agent immo',
        Property = 'Propriété',
        PropertyEnterText = '[E] - Entrer  \n[G] - Sonner  \n[H] - Vérouiller / Dévérouiller',
        OpenMenu = 'Ouvrir le menu',
        PropertyMenuTitle = 'Menu de la propriété',
        Exit = 'Sortir',
        LockedProperty = 'La propriété est vérouillée',
        DontHaveKey = 'Vous n\'avez pas la clé',
        OpenedDoor = 'Vous avez ouvert la porte',
        ClosedDoor = 'Vous avez fermé la porte',
        FurnitureMenuTitle = 'Menu d\'ameublement',
        PreviewFurnitures = 'Prévisualiser les meubles',
        PlacedFurnitures = 'Meubles placés',
        PlaceFurniture = 'Placer le meuble',
        PlaceCustomModel = 'Placer un modèle',
        Model = 'Modèle',
        InvalidModel = 'Modèle invalide',
        PreviewValidationText = '[E] - Valider  \n[X] - Annuler',
        ToggleLock = 'Vérouiller / Dévérouiller',
        FurnituresLimitReached = 'Limite de meubles atteinte',
        YouNeedToBeInside = 'Vous devez être en interieur pour ouvrir ce menu',
        Delete = 'Supprimer',
        Deleted = 'Supprimé',
        ChangePos = 'Changer la position',
        GetKey = 'Récupérer une clé',
        CantGetKey = 'Vous devez avoir une clé de la propriété pour récupérer une autre clé'
    }
}

function L(id)
    return Locales[Config.lang]?[id] or ('Locale '..id..' undefined')
end