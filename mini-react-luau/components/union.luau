-- Gets the union of A u B

return function<T>(a: T, b: T): T
	for key, value in b do
		a[key] = value
	end
	
	return a
end