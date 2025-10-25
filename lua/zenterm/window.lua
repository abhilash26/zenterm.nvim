-- window.lua - Window/float management for zenterm.nvim
local utils = require("zenterm.utils")

local M = {}

-- Create floating window
function M.create_float(buf, opts)
  if not utils.is_buf_valid(buf) then
    return nil
  end

  opts = opts or {}

  -- Calculate position
  local pos = utils.calculate_float_position(opts.width or 0.8, opts.height or 0.8)

  -- Window configuration
  local win_config = {
    relative = opts.relative or "editor",
    width = pos.width,
    height = pos.height,
    row = pos.row,
    col = pos.col,
    style = "minimal",
    border = opts.border or "rounded",
    zindex = opts.zindex or 50,
  }

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  if not win then
    utils.notify_error("Failed to create floating window")
    return nil
  end

  -- Set window options
  utils.set_terminal_win_options(win)

  -- Set winblend if specified
  if opts.winblend then
    vim.api.nvim_win_set_option(win, "winblend", opts.winblend)
  end

  return win
end

-- Create split window
function M.create_split(buf, direction, opts)
  if not utils.is_buf_valid(buf) then
    return nil
  end

  opts = opts or {}
  direction = direction or "horizontal"

  -- Calculate size
  local size = utils.calculate_split_size(direction, opts.size or 0.3)

  -- Create split
  if direction == "horizontal" then
    vim.cmd(string.format("botright %dsplit", size))
  elseif direction == "vertical" then
    vim.cmd(string.format("botright %dvsplit", size))
  else
    utils.notify_error("Invalid split direction: " .. direction)
    return nil
  end

  -- Get the newly created window
  local win = vim.api.nvim_get_current_win()

  -- Set buffer in window
  vim.api.nvim_win_set_buf(win, buf)

  -- Set window options
  utils.set_terminal_win_options(win)

  return win
end

-- Toggle window visibility
function M.toggle_window(terminal)
  if not terminal then
    return false
  end

  -- Check if window is currently visible
  if terminal.win and utils.is_win_valid(terminal.win) then
    -- Window is visible, close it
    utils.safe_win_close(terminal.win, true)
    terminal.win = nil
    return false
  else
    -- Window is not visible, open it
    if not utils.is_buf_valid(terminal.buf) then
      utils.notify_error("Terminal buffer is invalid")
      return false
    end

    -- Determine mode and create window
    local win
    if terminal.mode == "float" then
      win = M.create_float(terminal.buf, terminal.float_opts)
    elseif terminal.mode == "hsplit" then
      win = M.create_split(terminal.buf, "horizontal", terminal.split_opts)
    elseif terminal.mode == "vsplit" then
      win = M.create_split(terminal.buf, "vertical", terminal.split_opts)
    else
      -- Default to float
      win = M.create_float(terminal.buf, terminal.float_opts)
    end

    if win then
      terminal.win = win
      return true
    end
  end

  return false
end

-- Close window
function M.close_window(win)
  if utils.is_win_valid(win) then
    utils.safe_win_close(win, true)
    return true
  end
  return false
end

-- Check if window is visible
function M.is_window_visible(terminal)
  return terminal and terminal.win and utils.is_win_valid(terminal.win)
end

-- Focus window
function M.focus_window(win)
  if utils.is_win_valid(win) then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

-- Resize floating window
function M.resize_float(win, width_ratio, height_ratio)
  if not utils.is_win_valid(win) then
    return false
  end

  local pos = utils.calculate_float_position(width_ratio, height_ratio)

  local config = {
    relative = "editor",
    width = pos.width,
    height = pos.height,
    row = pos.row,
    col = pos.col,
  }

  vim.api.nvim_win_set_config(win, config)
  return true
end

-- Get window mode (float, hsplit, vsplit)
function M.get_window_mode(win)
  if not utils.is_win_valid(win) then
    return nil
  end

  local config = vim.api.nvim_win_get_config(win)
  if config.relative and config.relative ~= "" then
    return "float"
  end

  -- Check if it's a split
  local win_width = vim.api.nvim_win_get_width(win)
  local win_height = vim.api.nvim_win_get_height(win)
  local total_width = vim.o.columns
  local total_height = vim.o.lines

  if win_width < total_width * 0.9 then
    return "vsplit"
  elseif win_height < total_height * 0.9 then
    return "hsplit"
  end

  return "unknown"
end

return M

