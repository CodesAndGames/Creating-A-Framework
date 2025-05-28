-- client.lua

local defaultMenus = {
  main = {
    { 
			label = "Phone",     
			eventName = "phoneAction",  
			 isServer = false, 
			 args = {} 
			},
    { 
			label = "Inventory", 
			eventName = "openInventory", 
			isServer = false,  
			args = {'contacts', 'messages'} 
		},
  },
	phone = {
		{
			label = 'Contacts',
			eventName = 'openContacts',
			isServer = true,
			args = {}
		},
		{
			label = 'Messages',
			eventName = 'openMessages',
			isServer = true,
			args = {}
		},
	}

}

local menuStack = {}

local function openMenu(key)
  menuStack[#menuStack+1] = key
  SetNuiFocus(true, true)
  SendNUIMessage({
    type    = "openMenu",
    data = {
      menuKey = key,
      menus   = defaultMenus
    }
  })
end

RegisterCommand("+showMenu", function()
  openMenu("main")
end, false)
RegisterKeyMapping('+showMenu', 'Opens menu', 'KEYBOARD', 'G')

-- handle back
RegisterNUICallback("selectMenuItem", function(data, cb)
  if data.eventName == "menuBack" then
    table.remove(menuStack)          -- pop current
    local prev = menuStack[#menuStack] or "main"
    openMenu(prev)
  else
    if data.isServer then
      TriggerServerEvent(data.eventName, table.unpack(data.args or {}))
    else
      TriggerEvent(data.eventName, table.unpack(data.args or {}))
    end
  end
  cb("ok")
end)


--handle close
RegisterNUICallback('close', function(_,cb)
	SetNuiFocus(false, false)
	SendNUIMessage({type='close'})
end)

-- Events

RegisterNetEvent('openInventory', function(...)
	local args = {...}
	print('oop', json.encode(args))
	openMenu('phone')
end)
