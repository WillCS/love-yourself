local utils = require('utils')
local unix_utils = require('unix')

local module = {}

function module.copy(file_path, destination_path)
  if utils.is_unix() then
    unix_utils.exec('cp -R ' .. file_path .. ' ' .. destination_path)
  else
    error('Not implemented')
  end
end

function module.move(file_path, destination_path)
  if utils.is_unix() then
    unix_utils.exec('mv ' .. file_path .. ' ' .. destination_path)
  else
    error('Not implemented')
  end
end

function module.rename(file_name, new_name)
  if utils.is_unix() then
    module.move(file_name, new_name)
  else
    error('Not implemented')
  end
end

function module.create_directory(directory_path)
  if utils.is_unix() then
    unix_utils.exec('mkdir ' .. directory_path)
  else
    error('Not implemented')
  end
end

function module.delete_directory(directory_path)
  if utils.is_unix() then
    unix_utils.exec('rm -rf ' .. directory_path)
  else
    error('Not implemented')
  end
end

function module.create_archive(root_dir, file_name)
  if utils.is_unix() then
    unix_utils.exec('zip -9 -r ' .. file_name .. ' ' .. root_dir)
  else
    error('Not implemented')
  end
end

return module
