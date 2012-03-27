objc_loadClass("Logger")
local _print = print
function print(...)
	_print(...)
	local output = ""
	for i,str in pairs({...}) do
		if i == 1 then
			output = str
		else
			output = output .. ",   " .. str
		end
	end
    Logger:sharedLogger():log_(objc_strToObj(output).id)
end
