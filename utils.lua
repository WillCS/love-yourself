local module = {}

function module.is_unix()
  return package.config:sub(1, 1) == '/'
end

function module.init()
  setmetatable(_G, {
    __newindex = function(_, n)
      error("attempt to write to undeclared variable " .. n, 2)
    end,
    __index = function(_, n)
      error("attempt to read undeclared variable " .. n, 2)
    end,
  })
end

function module.declare(name, value)
  rawset(_G, name, value)
end

function module.path(...)
  local path_segments = { ... }
  if module.is_unix() then
    local path_string = ''
    for i, v in ipairs(path_segments) do
      if i == 1 then
        path_string = v
      else
        path_string = path_string .. '/' .. v
      end
    end

    return path_string
  else
    error('Not implemented')
  end
end

return module
