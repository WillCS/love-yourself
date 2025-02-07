local module = {}

module.ArgParser = {}

local function validate_arg_matcher(opts)
  if opts.type == nil then
    error('Attempted to register an arg without a type')
  end

  if opts.name == nil then
    error('Attempted to register an arg without a name')
  end
end

local function match_arg(arg, arg_matchers)
  local name_pattern = '^%-%-'
  local alias_pattern = '^%-'

  if arg:match(name_pattern) then
    local name = string.sub(arg, 3)
    for _, arg_matcher in ipairs(arg_matchers) do
      if arg_matcher.name == name then
        return arg_matcher
      end
    end
  elseif arg:match(alias_pattern) then
    local alias = string.sub(arg, 2)
    for _, arg_matcher in ipairs(arg_matchers) do
      if arg_matcher.alias == alias then
        return arg_matcher
      end
    end
  end

  error('Unknown argument: ' .. arg)
end

local function contains_key(table, key)
  for k, _ in pairs(table) do
    if k == key then
      return true
    end
  end

  return false
end

---comment
---@return table
function module.ArgParser:new(use_default_help_matcher)
  local new_instance = {}
  setmetatable(new_instance, self)
  self.__index = self
  return new_instance
end

-- arg = {
--   type = 'flag', -- flag, string
--   name = 'something', -- --flagName
--   alias = 's', -- -s
--   description = 'This is a flag',
--   validator = function () end
-- }

---
--- Parse the given list of arguments according to the parameters specified
--- for this ArgParser
--- @param args string[]
--- @return table
function module.ArgParser:parse(args)
  local current_index = 1

  local parsed_args = {}

  while current_index <= #args do
    local current_arg = args[current_index]
    local arg_matcher = match_arg(current_arg, self.arg_matchers)

    if contains_key(parsed_args, arg_matcher) then
      error('Duplicate argument: ' .. current_arg)
    end

    if arg_matcher.type == 'flag' then
      parsed_args[arg_matcher.name] = true

      current_index = current_index + 1
    elseif arg_matcher.type == 'string' then
      if #args < current_index + 1 then
        error('Expected a value for argument ' .. current_arg)
      end

      local value = args[current_index + 1]

      if arg_matcher.validator ~= nil then
        if arg_matcher.validator(value) then
          parsed_args[arg_matcher.name] = value
        else
          error('Invalid value ' .. value .. ' for argument ' .. current_arg)
        end
      end

      current_index = current_index + 2
    end
  end

  return parsed_args
end

---
--- Register a type of argument, allowing the ArgParser to recognise it
--- @param arg_matcher table
function module.ArgParser:register_arg_matcher(arg_matcher)
  if self.arg_matchers == nil then
    self.arg_matchers = {}
  end

  validate_arg_matcher(arg_matcher)

  self.arg_matchers[#self.arg_matchers + 1] = arg_matcher
end

function module.ArgParser:generate_help_message()
  local help_message = ''

  for _, arg_matcher in ipairs(self.arg_matchers) do
    help_message = help_message .. '--' .. arg_matcher.name .. ' (' .. '-' .. arg_matcher.alias .. '): ' .. arg_matcher.description .. '\n'
  end

  return help_message
end

return module
