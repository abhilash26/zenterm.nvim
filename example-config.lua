-- Example configuration for zenterm.nvim
-- Copy this to your Neovim config and customize as needed

return {
  "abhilash26/zenterm.nvim",
  config = function()
    require("zenterm").setup({
      -- Window settings
      float = {
        relative = "editor",
        width = 0.8,
        height = 0.8,
        border = "rounded",
        winblend = 0,
      },
      split = {
        direction = "horizontal",
        size = 0.3,
      },

      -- Terminal settings
      shell = vim.o.shell,
      auto_close = true,
      persist = false,
      start_in_insert = true,

      -- Lazygit integration
      lazygit = {
        enabled = true,
        float = {
          width = 0.9,
          height = 0.9,
          border = "rounded",
        },
        cmd = "lazygit",
        on_exit = "close",
      },

      -- Keymaps
      mappings = {
        toggle = "<C-\\>",
        new = "<leader>tn",
        close = "<leader>tc",
        next = "<leader>]t",
        prev = "<leader>[t",
        lazygit = "<leader>gg",
      },
    })

    -- Additional custom keymaps (optional)
    local zenterm = require("zenterm")

    -- Quick terminal commands
    vim.keymap.set("n", "<leader>tf", function()
      zenterm.open("float")
    end, { desc = "Float terminal" })

    vim.keymap.set("n", "<leader>th", function()
      zenterm.open("hsplit")
    end, { desc = "Horizontal split terminal" })

    vim.keymap.set("n", "<leader>tv", function()
      zenterm.open("vsplit")
    end, { desc = "Vertical split terminal" })

    -- Send visual selection to terminal
    vim.keymap.set("v", "<leader>ts", function()
      local lines = vim.fn.getline("'<", "'>")
      local cmd = table.concat(lines, "\n")
      zenterm.send(nil, cmd)
    end, { desc = "Send selection to terminal" })

    -- Named terminals for different purposes
    vim.keymap.set("n", "<leader>tg", function()
      zenterm.lazygit()
    end, { desc = "Lazygit" })
  end,
}

