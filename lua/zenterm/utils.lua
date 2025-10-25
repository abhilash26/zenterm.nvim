-- utils.lua - Minimal utility functions for zenterm.nvim
local M = {}

-- Calculate centered position for float window
function M.get_float_config(width_ratio, height_ratio, border)
  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return { width = 80, height = 24, row = 0, col = 0, border = border }
  end

  local width = math.floor(ui.width * width_ratio)
  local height = math.floor(ui.height * height_ratio)
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = border or "rounded",
  }
end

-- Calculate split size
function M.get_split_size(direction, size_ratio)
  if direction == "horizontal" then
    return math.floor(vim.o.lines * size_ratio)
  else
    return math.floor(vim.o.columns * size_ratio)
  end
end

-- Notify with plugin prefix
function M.notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[zenterm] " .. msg, level)
end

return M
