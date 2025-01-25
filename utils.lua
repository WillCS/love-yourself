local module

function module:init ()
    setmetatable(_G, {
        __newindex = function (_, n)
            error("attempt to write to undeclared variable " .. n, 2)
        end,
        __index = function (_, n)
            error("attempt to read undeclared variable " .. n, 2)
        end,
    })
end

function module:declare (name, value)
    rawset(_G, name, value)
end

return module
