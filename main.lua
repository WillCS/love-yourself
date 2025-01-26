local debug_flag = false

local constants = require('constants')
local unix_utils = require('unix')
local utils = require('utils')
local cli = require ('cli')

local Target = {
  raw = {},
  linux = {},
  macos = {},
  windows = {},
}

local function zip(root_dir, file_name)
  if utils.is_unix() then
    unix_utils.exec('zip -9 -r ' .. file_name .. ' ' .. root_dir)
  else
    error('Not implemented')
  end
end

local function make_temp_dir()
  if utils.is_unix() then
    unix_utils.exec('mkdir '.. constants.TEMP_DIR_NAME)
  else
    error('Not implemented')
  end
end

local function cleanup_temp_dir()
  if utils.is_unix() then
    unix_utils.exec('rm -rf '.. constants.TEMP_DIR_NAME)
  else
    error('Not implemented')
  end
end


local function create_love_file(root_dir, file_name)
  if utils.is_unix() then
    local love_file_name = utils.path(constants.TEMP_DIR_NAME, file_name .. '.love')
    print(love_file_name)
    zip(root_dir, love_file_name)
    return love_file_name
  else
    error('Not implemented')
  end
end

local function build(root_dir, target, file_name, love_location)
  -- create temp directory
  make_temp_dir()

  -- create the raw love file in the temp directory
  local love_file_path = create_love_file(root_dir, file_name)

  if target == Target.raw then
    -- move the raw love file to the specified output location
    error('Not implemented')
  elseif target == Target.linux then
    error('Not implemented')
  elseif target == Target.macos then
    local build_macos = require('macos')

    build_macos(file_name, love_file_path, love_location)
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
  if utils.is_unix() then
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

local function parse_args()
  local arg_parser = cli.ArgParser:new()

  arg_parser:register_arg_matcher({
    type = 'flag',
    name = 'help',
    alias = 'h',
    description = 'Show this help message',
  })

  arg_parser:register_arg_matcher({
    type = 'string',
    name = 'game_root',
    alias = 'r',
    description = 'The root directory for your love2d game',
  })

  arg_parser:register_arg_matcher({
    type = 'string',
    name = 'target',
    values = { 'raw', 'linux', 'macos', 'windows' },
    alias = 't',
    description = 'The platform to build for. Must be one of: raw, linux, macos, windows',
    validator = function (value)
      return value == 'raw' or value == 'linux' or value == 'macos' or value == 'windows'
    end
  })

  arg_parser:register_arg_matcher({
    type = 'string',
    name = 'name',
    alias = 'n',
    description = 'The name of the output file, before a file extension is added',
  })

  arg_parser:register_arg_matcher({
    type = 'string',
    name = 'output',
    alias = 'o',
    description = 'The directory to output the build to',
  })

  arg_parser:register_arg_matcher({
    type = 'string',
    name = 'love',
    alias = 'l',
    description = 'The location of the love app, on macos. If not provided, will attempt to find it',
  })

  arg_parser:register_arg_matcher({
    type = 'flag',
    name = 'debug',
    alias = 'd',
    description = 'Enable debug mode',
  })

  local status, result = pcall(function () return arg_parser:parse(arg) end)

  if status then
    for k in pairs(result) do
      if (k == 'help') then
        print(arg_parser:generate_help_message())
        os.exit(0)
      end
    end

    return result
  else
    print(result)
    print('Run with --help for usage information')
    os.exit(1)
  end
end

local function run()
  utils.init()

  local runtime_params = parse_args()

  -- input dir, target, output filename, love location, debug
  local root_dir = arg[1] or '.'
  local target = parseTarget(arg[2])
  local file_name = arg[3] or 'game'
  local love_location = arg[4] or '/Applications/love.app' -- find_love()
  utils.declare('debug_flag', false)
  -- debug_flag = arg[5] == 'debug'

  build(root_dir, target, file_name, love_location)
end

parse_args()
