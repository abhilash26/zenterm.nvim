-- init.lua - Minimal entry point for zenterm.nvim
local M = {}

-- Version
M.version = "0.2.0"

-- Lazy-load modules
local terminal = nil
local config = nil
local commands = nil

local function ensure_loaded()
  if not terminal then
    config = require("zenterm.config")
    terminal = require("zenterm.terminal")
    commands = require("zenterm.commands")
  end
end

-- Setup function
function M.setup(opts)
  ensure_loaded()

  -- Setup configuration
  config.setup(opts)

  -- Setup commands
  commands.setup()

  -- Setup keymap if provided
  local conf = config.get()
  if conf.mappings and conf.mappings.toggle then
    vim.keymap.set({ "n", "t" }, conf.mappings.toggle, function()
      M.toggle()
    end, { desc = "Toggle terminal", silent = true })
  end

  return M
end

-- Public API - minimal and focused
function M.toggle(mode)
  ensure_loaded()
  return terminal.toggle(mode)
end

-- Aliases for convenience
M.float = function()
  return M.toggle("float")
end

M.hsplit = function()
  return M.toggle("hsplit")
end

M.vsplit = function()
  return M.toggle("vsplit")
end

return M
