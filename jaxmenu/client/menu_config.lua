globalMenus = {}

function RegisterMenu(name, items)
  globalMenus[name] = items
	print('menu registered '..name)
end

function GetMenu(name)
  return globalMenus[name] or {}
end


function UpdateMenuLabel(menuName, oldLabel, newLabel)
  local menu = globalMenus[menuName]
  if not menu then return end
  for _, item in ipairs(menu) do
    if item.label == oldLabel then
      item.label = newLabel
			print(item.label, newLabel..' | '..oldLabel)
			SendNUIMessage({
				type='openMenu',
				data = {
					menuKey = menuName,
					menus = globalMenus
				}
			})
      return
    end
  end
end


exports("RegisterMenu", function(name, items)	RegisterMenu(name,items)end)
exports("GetMenu",function(name)	GetMenu(name)end)
exports("UpdateMenuLabel", function(menuName, oldLabel, newLabel) UpdateMenuLabel(menuName, oldLabel, newLabel) end)
