-- integrations/lazygit.lua - Lazygit integration for zenterm.nvim
local M = {}

-- Check if lazygit is available
function M.is_lazygit_available()
  local handle = io.popen("command -v lazygit 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result ~= ""
  end
  return false
end

-- Get git root directory
function M.get_git_root(path)
  path = path or vim.loop.cwd()

  local git_dir = vim.fn.finddir(".git", path .. ";")
  if git_dir ~= "" then
    return vim.fn.fnamemodify(git_dir, ":h")
  end

  -- Try using git command
  local handle = io.popen("cd " .. path .. " && git rev-parse --show-toplevel 2>/dev/null")
  if handle then
    local result = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    if result ~= "" then
      return result
    end
  end

  return nil
end

-- Check if path is in a git repository
function M.is_git_repo(path)
  return M.get_git_root(path) ~= nil
end

-- Open lazygit
function M.open_lazygit(dir, opts)
  local utils = require("zenterm.utils")
  local config = require("zenterm.config")
  local terminal = require("zenterm.terminal")

  local conf = config.get()

  -- Check if lazygit is enabled
  if not conf.lazygit.enabled then
    utils.notify_warn("Lazygit integration is disabled")
    return nil
  end

  -- Check if lazygit is available
  if not M.is_lazygit_available() then
    utils.notify_error("Lazygit command not found: " .. conf.lazygit.cmd)
    return nil
  end

  -- Find git root
  local git_root = dir or M.get_git_root()
  if not git_root then
    utils.notify_error("Not in a git repository")
    return nil
  end

  -- Prepare terminal options
  opts = opts or {}
  local lazygit_opts = vim.tbl_deep_extend("force", {
    mode = "float",
    name = "lazygit",
    cmd = conf.lazygit.cmd,
    cwd = git_root,
    float = conf.lazygit.float,
  }, opts)

  -- Create terminal
  local term = terminal.create_terminal(lazygit_opts)

  if term then
    utils.debug("Opened lazygit in: " .. git_root)
  end

  return term
end

-- Toggle lazygit
function M.toggle_lazygit(dir)
  local state = require("zenterm.state")
  local terminal = require("zenterm.terminal")
  local utils = require("zenterm.utils")

  -- Check if lazygit terminal already exists
  local terminals = state.list_terminals()
  local lazygit_term = nil

  for _, term in ipairs(terminals) do
    if term.name == "lazygit" then
      lazygit_term = term
      break
    end
  end

  if lazygit_term then
    -- Toggle existing lazygit terminal
    terminal.toggle_terminal(lazygit_term.id)
    return lazygit_term
  else
    -- Open new lazygit terminal
    return M.open_lazygit(dir)
  end
end

-- Open lazygit focused on current file
function M.open_lazygit_current_file()
  local utils = require("zenterm.utils")
  local config = require("zenterm.config")
  local terminal = require("zenterm.terminal")

  local conf = config.get()

  -- Get current file
  local current_file = vim.fn.expand("%:p")
  if current_file == "" then
    utils.notify_error("No file in current buffer")
    return nil
  end

  -- Get file directory
  local file_dir = vim.fn.fnamemodify(current_file, ":h")

  -- Find git root
  local git_root = M.get_git_root(file_dir)
  if not git_root then
    utils.notify_error("Current file is not in a git repository")
    return nil
  end

  -- Get relative path of file
  local relative_path = vim.fn.fnamemodify(current_file, ":.")

  -- Prepare lazygit command with file filter
  local cmd = string.format("%s -f %s", conf.lazygit.cmd, vim.fn.shellescape(relative_path))

  -- Prepare terminal options
  local lazygit_opts = {
    mode = "float",
    name = "lazygit_file",
    cmd = cmd,
    cwd = git_root,
    float = conf.lazygit.float,
  }

  -- Create terminal
  local term = terminal.create_terminal(lazygit_opts)

  if term then
    utils.debug("Opened lazygit for file: " .. relative_path)
  end

  return term
end

-- Get lazygit status
function M.get_lazygit_version()
  local handle = io.popen("lazygit --version 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+$", "")
  end
  return nil
end

return M

