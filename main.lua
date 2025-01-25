local is_unix = package.config:sub(1, 1) == '/'
local debug_flag = false

TEMP_DIR_NAME = 'temp'

local Target = {
  raw = {},
  linux = {},
  macos = {},
  windows = {},
}

local function exec(command)
  if debug_flag then
    print(command)
    return os.execute(command)
  else
    return os.execute(command .. ' > /dev/null')
  end
end

local function zip(root_dir, file_name)
  if is_unix then
    exec('zip -9 -r ' .. file_name .. '.love ' .. root_dir)
  else
    error('Not implemented')
  end
end

local function make_temp_dir()
  if is_unix then
    exec('mkdir '.. TEMP_DIR_NAME)
  else
    error('Not implemented')
  end
end

local function cleanup_temp_dir()
  if is_unix then
    exec('rm -rf '.. TEMP_DIR_NAME)
  else
    error('Not implemented')
  end
end


local function create_love_file(root_dir, file_name)
  if is_unix then
    zip(root_dir, TEMP_DIR_NAME .. '/' .. file_name)
  else
    error('Not implemented')
  end
end

local function build(root_dir, target, file_name, love_location)
  -- create temp directory
  make_temp_dir()

  -- create the raw love file in the temp directory
  create_love_file(root_dir, file_name)

  if target == Target.raw then
    -- move the raw love file to the specified output location
    error('Not implemented')
  elseif target == Target.linux then
    error('Not implemented')
  elseif target == Target.macos then
    -- copy the love app to the temp dir
    exec('cp -R ' .. love_location .. ' ' .. TEMP_DIR_NAME .. '/')
    -- rename it to the desired name
    exec('mv ' .. TEMP_DIR_NAME .. '/love.app ' .. TEMP_DIR_NAME .. '/' .. file_name .. '.app')
    -- move the raw love file inside
    exec('mv ' .. TEMP_DIR_NAME .. '/' .. file_name .. '.love ' .. TEMP_DIR_NAME .. '/' .. file_name .. '.app/Contents/Resources/')
    -- update Info.plist
    error('Not implemented')
    -- move the finished app file to the desired output location
    error('Not implemented')
  elseif target == Target.windows then
    error('Not implemented')
  end

  -- cleanup temp directory
  -- maybe have a flag to leave artefacts?
  cleanup_temp_dir()
end

local function parseTarget(target_string)
  if target_string == 'raw' then
    return Target.raw
  elseif target_string == 'linux' then
    return Target.linux
  elseif target_string == 'macos' then
    return Target.macos
  elseif target_string == 'windows' then
    return Target.windows
  else
    error('Invalid build target: ' .. target_string)
  end
end

local function find_love()
  if is_unix then
    error('Not implemented')
    local handle = io.popen('which love', 'r')
    if handle == nil then
      error('Could not find love executable')
    end

    local result = handle:read("l")
    handle:close()

    print(result)
  else
    error('Not implemented')
  end
end

local function run()
  -- input dir, target, output filename, love location, debug
  local root_dir = arg[1] or '.'
  local target = parseTarget(arg[2])
  local file_name = arg[3] or 'game'
  local love_location = arg[4] or '/Applications/love.app' -- find_love()
  debug_flag = true -- arg[5] == 'debug'

  build(root_dir, target, file_name, love_location)
end

run()
