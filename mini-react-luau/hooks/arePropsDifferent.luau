return function(propA: any, propB: any): boolean
	for name, value in propA do
		if propB[name] ~= value then
			return true
		end
	end

	return false
end