-- state.lua - Global state management for zenterm.nvim
local M = {}

-- Global state
M.state = {
  terminals = {}, -- Map of terminal_id -> terminal_obj
  default_terminal = nil, -- Default terminal ID
  last_terminal = nil, -- Last active terminal ID
  counter = 0, -- Counter for generating unique IDs
}

-- Generate unique terminal ID
function M.generate_id()
  M.state.counter = M.state.counter + 1
  return string.format("zenterm_%d_%d", os.time(), M.state.counter)
end

-- Add terminal to state
function M.add_terminal(terminal)
  if not terminal or not terminal.id then
    return false
  end

  M.state.terminals[terminal.id] = terminal

  -- Set as default if none exists
  if not M.state.default_terminal then
    M.state.default_terminal = terminal.id
  end

  -- Update last terminal
  M.state.last_terminal = terminal.id

  return true
end

-- Get terminal by ID
function M.get_terminal(id)
  if not id then
    -- Return default or last terminal
    id = M.state.last_terminal or M.state.default_terminal
  end

  return M.state.terminals[id]
end

-- Remove terminal from state
function M.remove_terminal(id)
  if not id or not M.state.terminals[id] then
    return false
  end

  M.state.terminals[id] = nil

  -- Update default terminal if removed
  if M.state.default_terminal == id then
    M.state.default_terminal = next(M.state.terminals)
  end

  -- Update last terminal if removed
  if M.state.last_terminal == id then
    M.state.last_terminal = M.state.default_terminal
  end

  return true
end

-- Get all terminals
function M.list_terminals()
  local terminals = {}
  for _, terminal in pairs(M.state.terminals) do
    table.insert(terminals, terminal)
  end
  return terminals
end

-- Get terminal count
function M.count()
  local count = 0
  for _ in pairs(M.state.terminals) do
    count = count + 1
  end
  return count
end

-- Set last active terminal
function M.set_last_terminal(id)
  if M.state.terminals[id] then
    M.state.last_terminal = id
  end
end

-- Get next terminal ID
function M.get_next_terminal(current_id)
  local terminals = M.list_terminals()
  if #terminals == 0 then
    return nil
  end

  -- Find current terminal index
  local current_index = nil
  for i, terminal in ipairs(terminals) do
    if terminal.id == current_id then
      current_index = i
      break
    end
  end

  -- Get next terminal (wrap around)
  if current_index then
    local next_index = (current_index % #terminals) + 1
    return terminals[next_index].id
  else
    return terminals[1].id
  end
end

-- Get previous terminal ID
function M.get_prev_terminal(current_id)
  local terminals = M.list_terminals()
  if #terminals == 0 then
    return nil
  end

  -- Find current terminal index
  local current_index = nil
  for i, terminal in ipairs(terminals) do
    if terminal.id == current_id then
      current_index = i
      break
    end
  end

  -- Get previous terminal (wrap around)
  if current_index then
    local prev_index = ((current_index - 2) % #terminals) + 1
    return terminals[prev_index].id
  else
    return terminals[#terminals].id
  end
end

-- Clear all terminals
function M.clear()
  M.state.terminals = {}
  M.state.default_terminal = nil
  M.state.last_terminal = nil
end

-- Setup cleanup hooks
function M.setup_cleanup()
  -- Clean up on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("ZenTermCleanup", { clear = true }),
    callback = function()
      -- Close all terminals
      for id, terminal in pairs(M.state.terminals) do
        if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
          pcall(vim.api.nvim_buf_delete, terminal.buf, { force = true })
        end
      end
      M.clear()
    end,
  })
end

return M

