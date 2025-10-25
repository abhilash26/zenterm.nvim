-- Minimal configuration example for zenterm.nvim
return {
  "abhilash26/zenterm.nvim",
  keys = {
    { "<C-\\>", mode = { "n", "t" } },
  },
  config = function()
    require("zenterm").setup({
      -- Window settings
      float = {
        width = 0.8,
        height = 0.8,
        border = "rounded",
      },
      split = {
        direction = "horizontal",
        size = 0.3,
      },

      -- Terminal behavior
      auto_insert = true,
      close_on_exit = true,

      -- Keymap
      mappings = {
        toggle = "<C-\\>",
      },
    })

    -- Optional: Additional keymaps
    vim.keymap.set("n", "<leader>tf", function()
      require("zenterm").float()
    end, { desc = "Float terminal" })

    vim.keymap.set("n", "<leader>th", function()
      require("zenterm").hsplit()
    end, { desc = "Horizontal split terminal" })

    vim.keymap.set("n", "<leader>tv", function()
      require("zenterm").vsplit()
    end, { desc = "Vertical split terminal" })
  end,
}
