local constants = require('constants')
local utils = require('utils')
local files = require('files')

local function find_love()
  if utils.is_unix() then
    error('Not implemented')
    local handle = io.popen('which love', 'r')
    if handle == nil then
      error('Could not find love executable. Please specify where to find love.app')
    end

    local result = handle:read("l")
    handle:close()

    print(result)
  else
    error('MacOS love.app location must be specified when building for MacOS on another platform')
  end
end

local function update_plist(location)
  local plist_file = io.open(location, "r");

  if plist_file == nil then
    error('Could not open Info.plist')
  end

  local plist_lines = {}
  for line in plist_file:lines() do
    print(line)
    table.insert(plist_lines, line);
  end

  local bundle_identifier_key = 'CFBundleIdentifier'
  local bundle_name_key = 'CFBundleName'
  local type_declarations_key = 'UTExportedTypeDeclarations'
  local string_value_pattern = '<string>.+</string>'

  for index = 1, #plist_lines, 1 do
    local current_line = plist_lines[index]

    if current_line:match('<key>' .. bundle_identifier_key .. '</key>') then
      index = index + 1
      plist_lines[index] = plist_lines[index]:gsub(string_value_pattern, '<string>' .. 'test_id' .. '</string>')
    elseif current_line:match('<key>' .. bundle_identifier_key .. '</key>') then
      index = index + 1
      plist_lines[index] = plist_lines[index]:gsub(string_value_pattern, '<string>' .. 'test_name' .. '</string>')
    elseif current_line:match('<key>' .. type_declarations_key .. '</key>') then
      index = index + 1

      while not plist_lines[index]:match('</array>') do
        plist_lines[index] = nil
        index = index + 1
      end

      plist_lines[index] = nil
    end
  end

  local new_plist_lines = {}

  for _, line in ipairs(plist_lines) do
    local index = 1
    if line ~= nil then
      new_plist_lines[index] = line
      index = index + 1
    end
  end

  for _, line in ipairs(new_plist_lines) do
    print(line)
  end

  error('Not implemented')
end

local function build(file_name, love_file_path, love_location, output_location)
  love_location = love_location or find_love()
  -- copy the love app to the temp dir
  files.copy(love_location, constants.TEMP_DIR_NAME)

  local game_app_file_path = utils.path(constants.TEMP_DIR_NAME, file_name .. '.app')

  -- rename it to the desired name
  files.rename(
    utils.path(constants.TEMP_DIR_NAME, 'love.app'),
    game_app_file_path
  )

  -- move the raw love file inside
  files.move(
    love_file_path,
    utils.path(game_app_file_path, 'Contents', 'Resources')
  )

  -- update Info.plist
  local plist_location = utils.path(game_app_file_path, 'Contents', 'Info.plist')
  update_plist(plist_location)

  -- move the finished app file to the desired output location
  files.move(game_app_file_path, output_location)
end

return build
