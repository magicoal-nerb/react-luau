local React = require("../React")

type Element = React.Element
return function(callback: () -> ())
	local id = React:getHookIndex()
	local new = React.hookFiber :: Element
	local old = new.previous :: Element
	
	if old then
		-- The event was already created
		return
	end
	
	local function destroyed()
		if table.isfrozen(new) then
			-- We know that this is already removed
			-- because the table was frozen
			callback()
		end
	end
	
	React.pendingQueue:enqueue(function()
		local dom = assert(new.dom)
		print(new)
		table.insert(
			new.events,
			dom.Destroying:Connect(destroyed)
		)
	end)
end