local constants = require('constants')
local utils = require('utils')
local unix_utils = require('unix')


local function build(file_name, love_file_path, love_location)
  -- copy the love app to the temp dir
  unix_utils.exec('cp -R ' .. love_location .. ' ' .. constants.TEMP_DIR_NAME .. '/')

  -- rename it to the desired name
  unix_utils.exec('mv ' .. constants.TEMP_DIR_NAME .. '/love.app ' .. constants.TEMP_DIR_NAME .. '/' .. file_name .. '.app')

  -- move the raw love file inside
  unix_utils.exec('mv ' .. love_file_path .. ' ' .. constants.TEMP_DIR_NAME .. '/' .. file_name .. '.app/Contents/Resources/')

  -- update Info.plist
  local plist_location = utils.path(constants.TEMP_DIR_NAME, file_name .. '.app', 'Contents', 'Info.plist')
  local plist_file = io.open(plist_location, "r");

  if plist_file == nil then
    error('Could not open Info.plist')
  end

  local plist_lines = {}
  for line in plist_file:lines() do
    print(line)
    table.insert (plist_lines, line);
  end

  error('Not implemented')

  -- move the finished app file to the desired output location
  error('Not implemented')
end

return build
