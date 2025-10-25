-- init.lua - Main entry point and public API for zenterm.nvim
local M = {}

-- Lazy-load modules
local config = nil
local state = nil
local terminal = nil
local commands = nil

-- Load modules on first use
local function ensure_loaded()
  if not config then
    config = require("zenterm.config")
    state = require("zenterm.state")
    terminal = require("zenterm.terminal")
    commands = require("zenterm.commands")
  end
end

-- Setup function
function M.setup(opts)
  ensure_loaded()

  -- Setup configuration
  config.setup(opts)

  -- Setup state management and cleanup hooks
  state.setup_cleanup()

  -- Setup user commands
  commands.setup()

  -- Setup keymaps if provided
  if opts and opts.mappings then
    M.setup_keymaps(opts.mappings)
  end

  return M
end

-- Setup keymaps
function M.setup_keymaps(mappings)
  ensure_loaded()

  if mappings.toggle then
    vim.keymap.set({ "n", "t" }, mappings.toggle, function()
      M.toggle()
    end, { desc = "Toggle terminal", silent = true })
  end

  if mappings.new then
    vim.keymap.set("n", mappings.new, function()
      M.open("float")
    end, { desc = "New terminal", silent = true })
  end

  if mappings.close then
    vim.keymap.set("n", mappings.close, function()
      M.close()
    end, { desc = "Close terminal", silent = true })
  end

  if mappings.next then
    vim.keymap.set("n", mappings.next, function()
      M.next()
    end, { desc = "Next terminal", silent = true })
  end

  if mappings.prev then
    vim.keymap.set("n", mappings.prev, function()
      M.prev()
    end, { desc = "Previous terminal", silent = true })
  end

  if mappings.lazygit then
    vim.keymap.set("n", mappings.lazygit, function()
      M.lazygit()
    end, { desc = "Toggle lazygit", silent = true })
  end
end

-- Public API functions

-- Toggle terminal
function M.toggle(id)
  ensure_loaded()
  return terminal.toggle_terminal(id)
end

-- Open terminal with specific mode
function M.open(mode, opts)
  ensure_loaded()
  opts = opts or {}
  opts.mode = mode or "float"
  return terminal.create_terminal(opts)
end

-- Close terminal
function M.close(id, force)
  ensure_loaded()
  return terminal.close_terminal(id, force)
end

-- Close all terminals
function M.close_all(force)
  ensure_loaded()
  return terminal.close_all_terminals(force)
end

-- Send command to terminal
function M.send(id, cmd)
  ensure_loaded()
  return terminal.send_command(id, cmd)
end

-- List all terminals
function M.list()
  ensure_loaded()
  return terminal.list_terminals()
end

-- Get terminal by ID
function M.get(id)
  ensure_loaded()
  return terminal.get_terminal(id)
end

-- Next terminal
function M.next()
  ensure_loaded()
  return terminal.next_terminal()
end

-- Previous terminal
function M.prev()
  ensure_loaded()
  return terminal.prev_terminal()
end

-- Lazygit integration
function M.lazygit(dir)
  ensure_loaded()
  local lazygit = require("zenterm.integrations.lazygit")
  return lazygit.toggle_lazygit(dir)
end

-- Lazygit for current file
function M.lazygit_current_file()
  ensure_loaded()
  local lazygit = require("zenterm.integrations.lazygit")
  return lazygit.open_lazygit_current_file()
end

-- Tmux integration
M.tmux = {}

-- Check if in tmux
function M.tmux.is_in_tmux()
  ensure_loaded()
  local tmux = require("zenterm.integrations.tmux")
  return tmux.is_in_tmux()
end

-- Create tmux pane
function M.tmux.create_pane(direction, size)
  ensure_loaded()
  local tmux = require("zenterm.integrations.tmux")
  return tmux.create_tmux_pane(direction, size)
end

-- Send to tmux pane
function M.tmux.send(pane_id, cmd)
  ensure_loaded()
  local tmux = require("zenterm.integrations.tmux")
  return tmux.send_to_tmux_pane(pane_id, cmd)
end

-- List tmux panes
function M.tmux.list_panes()
  ensure_loaded()
  local tmux = require("zenterm.integrations.tmux")
  return tmux.list_tmux_panes()
end

-- Setup navigation sync
function M.tmux.setup_navigation()
  ensure_loaded()
  local tmux = require("zenterm.integrations.tmux")
  return tmux.setup_navigation_sync()
end

-- Open in tmux
function M.tmux.open(direction, cmd)
  ensure_loaded()
  local tmux = require("zenterm.integrations.tmux")
  return tmux.open_in_tmux(direction, cmd)
end

-- Version info
M.version = "0.1.0"

return M

