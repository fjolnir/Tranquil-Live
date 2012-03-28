objc_loadClass("Logger")
local _print = print
function print(...)
	_print(...)
	local output = ""
	for i,arg in pairs({...}) do
		if i == 1 then
			output = tostring(arg)
		else
			output = output .. ",   " .. tostring(arg)
		end
	end
    Logger.sharedLogger().log_(objc_strToObj(output))
end
