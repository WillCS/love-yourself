local module = {}

function module.exec(command)
  if debug then
    print(command)
    return os.execute(command)
  else
    return os.execute(command .. ' > /dev/null')
  end
end

return module
