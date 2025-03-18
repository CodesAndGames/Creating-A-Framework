Framework = class('Framework')
Framework.modules = {}
function Framework:__construct()
	print('Framework has started.')
	self.queries = {}
end

function Framework.log(msg, level)
	if not (msg or level) then return end

	if level == 'info' then
		print('^3[INFO] '..msg.."^0")
	elseif level == 'error' then
		print('^1[ERROR] '..msg.."^0")
	else
		print('Cannot log. Invalid level')
	end
end

function Framework:RegisterModule(name, tbl)
	if not Framework.modules[name] then
		Framework.modules[name] = tbl
		if IsDuplicityVersion() then
			print('Registered class: '..name..' on server')
		else
			print('Registered class: '..name..' on client')
		end
	end
end

function Framework:query(name, query)
	if not (name or query) then
		return error('unable to create query due to invalid data passed.')
	end

	if not self.queries[name] then
		self.queries[name] = {
			query = query,
		}
	end
end

function Framework:execute(name, data)
	if not (name or self.queries[name]) then
		return error('unable to execute query. Does it exist?')
	end

	local query = self.queries[name].query
	local result

	if data then
		result = exports['oxmysql']:executeSync(query, data)
	else
		result = exports['oxmysql']:executeSync(query)
	end
	return result
end

return Framework
