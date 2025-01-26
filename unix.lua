local module = {}

function module.exec(command)
  debug_flag = debug_flag or false

  if debug_flag then
    print(command)
    return os.execute(command)
  else
    return os.execute(command .. ' > /dev/null')
  end
end

return module
