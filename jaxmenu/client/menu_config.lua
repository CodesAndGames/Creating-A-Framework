globalMenus = {}

function RegisterMenu(name, items)
  globalMenus[name] = items
end

function GetMenu(name)
  return globalMenus[name] or {}
end

-- register your default menus:
RegisterMenu('main', {
	{ 
		label	= "Clothes",		 
		menu	= "clothesMenu"    
	},
	{
		label			= "Change Menu", 
		eventName	= "changeMenu", 
		isServer  = false,
		args			= {'main','Clothes', 'Test'}
	},
})

function UpdateMenuLabel(menuName, oldLabel, newLabel)
  local menu = globalMenus[menuName]
  if not menu then return end
  for _, item in ipairs(menu) do
    if item.label == oldLabel then
      item.label = newLabel
      return
    end
  end
end

-- usage:
RegisterNetEvent('changeMenu', function(...)
	local args = {...}
	UpdateMenuLabel(args[1], args[2], args[3])
	SendNUIMessage({
		type='openMenu',
		data = {
			menuKey = args[1],
			menus = globalMenus
		}
	})
end)