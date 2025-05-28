RegisterNetEvent('jaxmenu:callExport', function(resource, exportName, ...)
  local fn = exports[resource] and exports[resource][exportName]
  if fn then
    fn(...)
  else
    print(("menu: missing server export %s in resource %s"):format(exportName, resource))
  end
end)