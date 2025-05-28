-- config.lua
cfg = {}

cfg.Menus = {
  Phone = {
    { label = "Contacts",     eventName = "phoneAction",   isServer = false, args = {} },
    { label = "Inventory", eventName = "openInventory", isServer = true,  args = {} },
  },
}

return cfg