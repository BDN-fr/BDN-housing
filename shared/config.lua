Config = Config or {}

ESX = exports['es_extended']:getSharedObject()
Config.ox_inventory = 'ox_inventory'

Config.lang = 'fr'

Config.Job = Config.Job or {}
Config.Job.name = 'immo'

Config.maxFurnitures = 500

Config.Storage = {
  weight = 50000,
  slots = 0 -- Set to 0 to disable
}

Config.Items = {
  ['small'] = 'immo_small',
  ['medium'] = 'immo_medium',
  ['large'] = 'immo_large',
  ['xl'] = 'immo_xl',
}

Config.visit = vector3(-861.3554, -355.8356, 38.6807)