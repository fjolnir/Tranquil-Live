function class(superClass)
	local class = {}
	local classMt = { __index = class }

	-- The base constructor, should be wrapped by a new() that does initialization
	function class:create()
		local instance = {}
		setmetatable(instance, classMt)
		return instance
	end

	-- Inherit
	if superClass ~= nil then
		setmetatable(class, {__index=superClass})
	end

	-- Introspection
	function class:class()
		return class
	end

	function class:super()
		return superClass
	end

	function class:isa(aClass)
		local currClass = aClass
		while (currClass ~= nil) and (isa == false) do
			if currClass  == aClass then
				return true
			else
				currClass = currClass:superClass()
			end
		end
		return false
	end

	return class
end

