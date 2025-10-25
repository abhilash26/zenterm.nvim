-- utils.lua - Utility functions for zenterm.nvim
local M = {}

-- Check if buffer is valid and loaded
function M.is_buf_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)
end

-- Check if window is valid
function M.is_win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

-- Get current working directory, handling errors
function M.get_cwd()
  local ok, cwd = pcall(vim.fn.getcwd)
  if ok then
    return cwd
  end
  return vim.loop.cwd()
end

-- Find git root directory
function M.find_git_root(path)
  path = path or M.get_cwd()

  local git_dir = vim.fn.finddir(".git", path .. ";")
  if git_dir ~= "" then
    return vim.fn.fnamemodify(git_dir, ":h")
  end

  return nil
end

-- Check if command exists in PATH
function M.command_exists(cmd)
  local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
  end
  return false
end

-- Calculate centered position for float window
function M.calculate_float_position(width_ratio, height_ratio)
  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return { width = 80, height = 24, row = 0, col = 0 }
  end

  local width = math.floor(ui.width * width_ratio)
  local height = math.floor(ui.height * height_ratio)
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  return {
    width = width,
    height = height,
    row = row,
    col = col,
  }
end

-- Calculate split size
function M.calculate_split_size(direction, size_ratio)
  if direction == "horizontal" then
    return math.floor(vim.o.lines * size_ratio)
  else
    return math.floor(vim.o.columns * size_ratio)
  end
end

-- Safe buffer delete
function M.safe_buf_delete(buf, force)
  if M.is_buf_valid(buf) then
    pcall(vim.api.nvim_buf_delete, buf, { force = force or false })
  end
end

-- Safe window close
function M.safe_win_close(win, force)
  if M.is_win_valid(win) then
    pcall(vim.api.nvim_win_close, win, force or false)
  end
end

-- Get buffer by terminal ID (from buffer name)
function M.get_terminal_buf(terminal_id)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_buf_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match(terminal_id) then
        return buf
      end
    end
  end
  return nil
end

-- Set buffer options for terminal
function M.set_terminal_buf_options(buf)
  if not M.is_buf_valid(buf) then
    return
  end

  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
end

-- Set window options for terminal
function M.set_terminal_win_options(win)
  if not M.is_win_valid(win) then
    return
  end

  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)
  vim.api.nvim_win_set_option(win, "signcolumn", "no")
  vim.api.nvim_win_set_option(win, "spell", false)
end

-- Enter insert mode if configured
function M.maybe_start_insert(config)
  if config and config.start_in_insert then
    vim.cmd("startinsert")
  end
end

-- Notify with plugin prefix
function M.notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[zenterm] " .. msg, level)
end

-- Notify error
function M.notify_error(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

-- Notify warning
function M.notify_warn(msg)
  M.notify(msg, vim.log.levels.WARN)
end

-- Debug print (only if debug is enabled)
function M.debug(msg)
  if vim.g.zenterm_debug then
    print("[zenterm debug] " .. msg)
  end
end

return M

