-- integrations/tmux.lua - Tmux integration for zenterm.nvim
local M = {}

-- Check if running inside tmux
function M.is_in_tmux()
  return os.getenv("TMUX") ~= nil
end

-- Get tmux version
function M.get_tmux_version()
  if not M.is_in_tmux() then
    return nil
  end

  local handle = io.popen("tmux -V 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+$", "")
  end
  return nil
end

-- Execute tmux command
local function exec_tmux_cmd(cmd)
  local handle = io.popen("tmux " .. cmd .. " 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+$", "")
  end
  return nil
end

-- Create tmux pane
function M.create_tmux_pane(direction, size)
  if not M.is_in_tmux() then
    local utils = require("zenterm.utils")
    utils.notify_error("Not running inside tmux")
    return nil
  end

  direction = direction or "horizontal"
  size = size or nil

  -- Build split command
  local split_cmd
  if direction == "horizontal" then
    split_cmd = "split-window -v"
  elseif direction == "vertical" then
    split_cmd = "split-window -h"
  else
    local utils = require("zenterm.utils")
    utils.notify_error("Invalid direction: " .. direction)
    return nil
  end

  -- Add size if specified
  if size then
    split_cmd = split_cmd .. " -l " .. tostring(size)
  end

  -- Add print format to get pane ID
  split_cmd = split_cmd .. " -P -F '#{pane_id}'"

  -- Execute command
  local pane_id = exec_tmux_cmd(split_cmd)

  if pane_id and pane_id ~= "" then
    local utils = require("zenterm.utils")
    utils.debug("Created tmux pane: " .. pane_id)
    return pane_id
  end

  return nil
end

-- Send keys/command to tmux pane
function M.send_to_tmux_pane(pane_id, cmd)
  if not M.is_in_tmux() then
    local utils = require("zenterm.utils")
    utils.notify_error("Not running inside tmux")
    return false
  end

  if not pane_id or pane_id == "" then
    local utils = require("zenterm.utils")
    utils.notify_error("Invalid pane ID")
    return false
  end

  -- Escape single quotes in command
  cmd = cmd:gsub("'", "'\\''")

  -- Send command with Enter
  local send_cmd = string.format("send-keys -t %s '%s' C-m", pane_id, cmd)
  local result = exec_tmux_cmd(send_cmd)

  return result ~= nil
end

-- Select/focus tmux pane
function M.select_tmux_pane(pane_id)
  if not M.is_in_tmux() then
    return false
  end

  local result = exec_tmux_cmd("select-pane -t " .. pane_id)
  return result ~= nil
end

-- List tmux panes
function M.list_tmux_panes()
  if not M.is_in_tmux() then
    return {}
  end

  local result = exec_tmux_cmd("list-panes -F '#{pane_id}:#{pane_current_command}:#{pane_active}'")

  if not result or result == "" then
    return {}
  end

  local panes = {}
  for line in result:gmatch("[^\r\n]+") do
    local id, cmd, active = line:match("([^:]+):([^:]+):([^:]+)")
    if id then
      table.insert(panes, {
        id = id,
        command = cmd,
        active = active == "1",
      })
    end
  end

  return panes
end

-- Get current tmux pane ID
function M.get_current_pane_id()
  if not M.is_in_tmux() then
    return nil
  end

  return exec_tmux_cmd("display-message -p '#{pane_id}'")
end

-- Kill tmux pane
function M.kill_tmux_pane(pane_id)
  if not M.is_in_tmux() then
    return false
  end

  local result = exec_tmux_cmd("kill-pane -t " .. pane_id)
  return result ~= nil
end

-- Setup tmux navigation sync (vim-tmux-navigator style)
function M.setup_navigation_sync()
  local utils = require("zenterm.utils")

  if not M.is_in_tmux() then
    utils.notify_warn("Not in tmux, skipping navigation sync")
    return false
  end

  -- Create keymaps for seamless navigation
  local function navigate(direction)
    local tmux_direction = {
      h = "L",
      j = "D",
      k = "U",
      l = "R",
    }

    -- Try to move in vim first
    local current_win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. direction)
    local new_win = vim.api.nvim_get_current_win()

    -- If didn't move in vim, try tmux
    if current_win == new_win then
      exec_tmux_cmd("select-pane -" .. tmux_direction[direction])
    end
  end

  -- Setup keymaps
  vim.keymap.set("n", "<C-h>", function()
    navigate("h")
  end, { silent = true, desc = "Navigate left (vim/tmux)" })

  vim.keymap.set("n", "<C-j>", function()
    navigate("j")
  end, { silent = true, desc = "Navigate down (vim/tmux)" })

  vim.keymap.set("n", "<C-k>", function()
    navigate("k")
  end, { silent = true, desc = "Navigate up (vim/tmux)" })

  vim.keymap.set("n", "<C-l>", function()
    navigate("l")
  end, { silent = true, desc = "Navigate right (vim/tmux)" })

  utils.notify("Tmux navigation sync enabled")
  return true
end

-- Open terminal in tmux instead of nvim
function M.open_in_tmux(direction, cmd)
  local utils = require("zenterm.utils")

  if not M.is_in_tmux() then
    utils.notify_error("Not running inside tmux")
    return nil
  end

  -- Create pane
  local pane_id = M.create_tmux_pane(direction)

  if not pane_id then
    utils.notify_error("Failed to create tmux pane")
    return nil
  end

  -- Send command if provided
  if cmd then
    vim.defer_fn(function()
      M.send_to_tmux_pane(pane_id, cmd)
    end, 100) -- Small delay to ensure pane is ready
  end

  return pane_id
end

-- Get tmux session info
function M.get_session_info()
  if not M.is_in_tmux() then
    return nil
  end

  local name = exec_tmux_cmd("display-message -p '#{session_name}'")
  local windows = exec_tmux_cmd("display-message -p '#{session_windows}'")

  return {
    name = name,
    windows = tonumber(windows) or 0,
  }
end

return M

