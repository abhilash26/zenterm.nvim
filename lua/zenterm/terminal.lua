-- terminal.lua - Core terminal logic for zenterm.nvim
local config = require("zenterm.config")
local state = require("zenterm.state")
local window = require("zenterm.window")
local utils = require("zenterm.utils")

local M = {}

-- Create a new terminal
function M.create_terminal(opts)
  opts = opts or {}

  local conf = config.get()
  local terminal_id = state.generate_id()

  -- Determine mode
  local mode = opts.mode or "float"

  -- Get options based on mode
  local float_opts = vim.tbl_deep_extend("force", conf.float, opts.float or {})
  local split_opts = vim.tbl_deep_extend("force", conf.split, opts.split or {})

  -- Determine CWD
  local cwd = opts.cwd or utils.get_cwd()

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  if not buf then
    utils.notify_error("Failed to create terminal buffer")
    return nil
  end

  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, "term://" .. terminal_id)

  -- Set buffer options
  utils.set_terminal_buf_options(buf)

  -- Prepare terminal command
  local cmd = opts.cmd or conf.shell

  -- Terminal object
  local terminal = {
    id = terminal_id,
    buf = buf,
    win = nil,
    name = opts.name or terminal_id,
    mode = mode,
    cmd = cmd,
    cwd = cwd,
    float_opts = float_opts,
    split_opts = split_opts,
    job_id = nil,
    created_at = os.time(),
  }

  -- Start terminal job
  local job_id = vim.fn.termopen(cmd, {
    cwd = cwd,
    on_exit = function(_, exit_code, _)
      M.on_terminal_exit(terminal, exit_code)
    end,
  })

  if job_id <= 0 then
    utils.notify_error("Failed to start terminal")
    utils.safe_buf_delete(buf, true)
    return nil
  end

  terminal.job_id = job_id

  -- Create window based on mode
  local win
  if mode == "float" then
    win = window.create_float(buf, float_opts)
  elseif mode == "hsplit" then
    win = window.create_split(buf, "horizontal", split_opts)
  elseif mode == "vsplit" then
    win = window.create_split(buf, "vertical", split_opts)
  else
    -- Default to float
    win = window.create_float(buf, float_opts)
    terminal.mode = "float"
  end

  if not win then
    utils.notify_error("Failed to create terminal window")
    utils.safe_buf_delete(buf, true)
    return nil
  end

  terminal.win = win

  -- Add to state
  state.add_terminal(terminal)

  -- Setup buffer autocommands
  M.setup_terminal_autocmds(terminal)

  -- Start in insert mode if configured
  utils.maybe_start_insert(conf)

  utils.debug("Created terminal: " .. terminal_id)

  return terminal
end

-- Get terminal by ID or return default/last
function M.get_terminal(id)
  return state.get_terminal(id)
end

-- Toggle terminal visibility
function M.toggle_terminal(id)
  local terminal = M.get_terminal(id)

  if not terminal then
    -- Create new terminal if none exists
    terminal = M.create_terminal()
    return terminal
  end

  -- Toggle window
  local is_open = window.toggle_window(terminal)

  if is_open then
    -- Focus and enter insert mode
    window.focus_window(terminal.win)
    utils.maybe_start_insert(config.get())
    state.set_last_terminal(terminal.id)
  end

  return terminal
end

-- Close terminal
function M.close_terminal(id, force)
  local terminal = M.get_terminal(id)

  if not terminal then
    utils.notify_warn("Terminal not found")
    return false
  end

  -- Close window
  if terminal.win then
    utils.safe_win_close(terminal.win, true)
    terminal.win = nil
  end

  -- Delete buffer if force or not persisting
  local conf = config.get()
  if force or not conf.persist then
    utils.safe_buf_delete(terminal.buf, true)
    state.remove_terminal(terminal.id)
    utils.debug("Closed terminal: " .. terminal.id)
  end

  return true
end

-- Close all terminals
function M.close_all_terminals(force)
  local terminals = state.list_terminals()

  for _, terminal in ipairs(terminals) do
    M.close_terminal(terminal.id, force)
  end

  return true
end

-- Send command to terminal
function M.send_command(id, cmd)
  local terminal = M.get_terminal(id)

  if not terminal or not terminal.job_id then
    utils.notify_error("Terminal not found or job not running")
    return false
  end

  -- Send command
  vim.fn.chansend(terminal.job_id, cmd .. "\n")
  return true
end

-- Handle terminal exit
function M.on_terminal_exit(terminal, exit_code)
  utils.debug("Terminal exited: " .. terminal.id .. " with code " .. exit_code)

  local conf = config.get()

  -- Auto-close if configured
  if conf.auto_close then
    vim.schedule(function()
      M.close_terminal(terminal.id, true)
    end)
  end
end

-- Setup terminal-specific autocommands
function M.setup_terminal_autocmds(terminal)
  local group = vim.api.nvim_create_augroup("ZenTerm_" .. terminal.id, { clear = true })

  -- Track window close
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(terminal.win),
    callback = function()
      terminal.win = nil
    end,
  })

  -- Auto insert mode when entering terminal window
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    buffer = terminal.buf,
    callback = function()
      local conf = config.get()
      utils.maybe_start_insert(conf)
      state.set_last_terminal(terminal.id)
    end,
  })

  -- Cleanup on buffer delete
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    buffer = terminal.buf,
    callback = function()
      state.remove_terminal(terminal.id)
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })
end

-- List all terminals
function M.list_terminals()
  return state.list_terminals()
end

-- Switch to next terminal
function M.next_terminal()
  local current_id = state.state.last_terminal
  local next_id = state.get_next_terminal(current_id)

  if next_id then
    M.toggle_terminal(next_id)
  end
end

-- Switch to previous terminal
function M.prev_terminal()
  local current_id = state.state.last_terminal
  local prev_id = state.get_prev_terminal(current_id)

  if prev_id then
    M.toggle_terminal(prev_id)
  end
end

return M

