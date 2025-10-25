-- state.lua - Minimal state management for zenterm.nvim
local M = {}

-- Global state - just track the last terminal
M.state = {
  last_term_buf = nil, -- Last terminal buffer
  last_term_win = nil, -- Last terminal window
}

-- Update last terminal
function M.set_last_term(buf, win)
  M.state.last_term_buf = buf
  M.state.last_term_win = win
end

-- Get last terminal
function M.get_last_term()
  return M.state.last_term_buf, M.state.last_term_win
end

-- Clear state
function M.clear()
  M.state.last_term_buf = nil
  M.state.last_term_win = nil
end

return M
