--!strict

type UnionType<T> = {[any]: T}

-- Gets the union of A u B
return function<T>(a: UnionType<T>, b: UnionType<T>): UnionType<T>
	for key, value in b do
		a[key] = value
	end
	
	return a
end
