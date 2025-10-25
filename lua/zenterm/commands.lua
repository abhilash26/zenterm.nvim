-- commands.lua - Minimal user commands for zenterm.nvim
local terminal = require("zenterm.terminal")

local M = {}

-- Setup user commands
function M.setup()
  -- Main toggle command
  vim.api.nvim_create_user_command("ZenTerm", function(opts)
    local mode = opts.args ~= "" and opts.args or "float"
    terminal.toggle(mode)
  end, {
    nargs = "?",
    complete = function()
      return { "float", "hsplit", "vsplit" }
    end,
    desc = "Toggle terminal (float|hsplit|vsplit)",
  })

  -- Shorthand commands
  vim.api.nvim_create_user_command("ZenTermFloat", function()
    terminal.toggle("float")
  end, { desc = "Toggle floating terminal" })

  vim.api.nvim_create_user_command("ZenTermHSplit", function()
    terminal.toggle("hsplit")
  end, { desc = "Toggle horizontal split terminal" })

  vim.api.nvim_create_user_command("ZenTermVSplit", function()
    terminal.toggle("vsplit")
  end, { desc = "Toggle vertical split terminal" })
end

return M
