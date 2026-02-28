Config = Config or {}

ESX = exports['es_extended']:getSharedObject()
Config.ox_inventory = 'ox_inventory'

Config.lang = 'fr'

Config.Job = Config.Job or {}
Config.Job.name = 'immo'

Config.maxFurnitures = 500

Config.Storage = {
  weight = 50000,
  slots = 50 -- Set to 0 to disable
}

Config.Items = {
  ['wherehouse'] = 'immo_wherehouse',
  ['small'] = 'immo_small',
  ['medium'] = 'immo_medium',
  ['big'] = 'immo_big'
}