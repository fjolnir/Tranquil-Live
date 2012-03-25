_print = print
print = function(input)
    _print(input)
    Logger:sharedLogger():log(tostring(input).."\n")
end
