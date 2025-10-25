-- config.lua - Configuration management for zenterm.nvim
local M = {}

-- Default configuration
M.defaults = {
  -- Window settings
  float = {
    relative = "editor",
    width = 0.8, -- 80% of editor width
    height = 0.8, -- 80% of editor height
    row = 0.1, -- 10% from top
    col = 0.1, -- 10% from left
    border = "rounded",
    winblend = 0,
    zindex = 50,
  },
  split = {
    direction = "horizontal", -- "horizontal" or "vertical"
    size = 0.3, -- 30% of editor
  },

  -- Terminal settings
  shell = vim.o.shell,
  auto_close = true, -- Close window on job exit
  persist = false, -- Keep terminal after window close
  start_in_insert = true, -- Start in insert mode

  -- Lazygit integration
  lazygit = {
    enabled = true,
    float = {
      width = 0.9,
      height = 0.9,
      border = "rounded",
    },
    cmd = "lazygit", -- Command to run
    on_exit = "close", -- "close" | "keep"
  },

  -- Tmux integration
  tmux = {
    enabled = false, -- Auto-detect tmux
    create_panes = false, -- Create tmux panes instead of nvim windows
    sync_navigation = false, -- Sync tmux/nvim navigation
    bindings = {
      prefix = "<C-a>", -- Tmux-style prefix
      split_v = "|",
      split_h = "-",
    },
  },

  -- Keymaps
  mappings = {
    toggle = "<C-\\>",
    new = "<leader>tn",
    close = "<leader>tc",
    next = "<leader>]t",
    prev = "<leader>[t",
    lazygit = "<leader>gg", -- Lazygit toggle
  },
}

-- Current configuration
M.options = {}

-- Deep merge two tables
local function deep_merge(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" and type(target[key]) == "table" then
      deep_merge(target[key], value)
    else
      target[key] = value
    end
  end
  return target
end

-- Setup configuration
function M.setup(user_opts)
  user_opts = user_opts or {}

  -- Start with defaults
  M.options = vim.deepcopy(M.defaults)

  -- Merge user options
  M.options = deep_merge(M.options, user_opts)

  -- Validate configuration
  M.validate()

  return M.options
end

-- Validate configuration
function M.validate()
  -- Validate float dimensions
  if M.options.float.width <= 0 or M.options.float.width > 1 then
    vim.notify("zenterm: float.width must be between 0 and 1", vim.log.levels.WARN)
    M.options.float.width = M.defaults.float.width
  end

  if M.options.float.height <= 0 or M.options.float.height > 1 then
    vim.notify("zenterm: float.height must be between 0 and 1", vim.log.levels.WARN)
    M.options.float.height = M.defaults.float.height
  end

  -- Validate split size
  if M.options.split.size <= 0 or M.options.split.size >= 1 then
    vim.notify("zenterm: split.size must be between 0 and 1", vim.log.levels.WARN)
    M.options.split.size = M.defaults.split.size
  end

  -- Validate split direction
  if M.options.split.direction ~= "horizontal" and M.options.split.direction ~= "vertical" then
    vim.notify("zenterm: split.direction must be 'horizontal' or 'vertical'", vim.log.levels.WARN)
    M.options.split.direction = M.defaults.split.direction
  end

  return true
end

-- Get current configuration
function M.get()
  return M.options
end

return M

