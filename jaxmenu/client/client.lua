-- client.lua
local menuStack = {}

function openMenu(key)
  menuStack[#menuStack+1] = key
  SetNuiFocus(true, true)
  SendNUIMessage({
    type    = "openMenu",
    data = {
      menuKey = key,
      menus   = globalMenus
    }
  })
end

RegisterCommand("showMenu", function() openMenu("main") end, false)

-- handle back
RegisterNUICallback("selectMenuItem", function(data, cb)
  if data.menu then
    -- submenu branch
    openMenu(data.menu)
  elseif data.eventName == "menuBack" then
    -- back-button branch
    table.remove(menuStack)                       -- pop current
    local prev = menuStack[#menuStack] or "main"  -- last or fallback
    openMenu(prev)
  elseif data.eventName then
    -- event branch
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
