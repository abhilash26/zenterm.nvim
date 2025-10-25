-- config.lua - Minimal configuration for zenterm.nvim
local M = {}

-- Default configuration - simple and minimal
M.defaults = {
  -- Window settings
  float = {
    relative = "editor",
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
  split = {
    direction = "horizontal", -- "horizontal" or "vertical"
    size = 0.3,
  },

  -- Terminal settings
  auto_insert = true, -- Auto enter insert mode
  close_on_exit = true, -- Close terminal when process exits

  -- Keymaps
  mappings = {
    toggle = "<C-\\>",
  },
}

-- Current configuration
M.options = {}

-- Setup configuration
function M.setup(user_opts)
  user_opts = user_opts or {}

  -- Simple merge - user options override defaults
  M.options = vim.tbl_deep_extend("force", M.defaults, user_opts)

  return M.options
end

-- Get current configuration
function M.get()
  if vim.tbl_isempty(M.options) then
    return M.defaults
  end
  return M.options
end

return M
