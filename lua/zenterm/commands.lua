-- commands.lua - User commands for zenterm.nvim
local terminal = require("zenterm.terminal")
local utils = require("zenterm.utils")

local M = {}

-- Setup user commands
function M.setup()
  -- ZenTermFloat - Open/toggle floating terminal
  vim.api.nvim_create_user_command("ZenTermFloat", function(opts)
    local term_opts = {
      mode = "float",
      name = opts.args ~= "" and opts.args or nil,
    }
    terminal.create_terminal(term_opts)
  end, {
    nargs = "?",
    desc = "Open/toggle floating terminal",
  })

  -- ZenTermSplit - Open terminal in horizontal split
  vim.api.nvim_create_user_command("ZenTermSplit", function(opts)
    local term_opts = {
      mode = "hsplit",
      name = opts.args ~= "" and opts.args or nil,
    }
    terminal.create_terminal(term_opts)
  end, {
    nargs = "?",
    desc = "Open terminal in horizontal split",
  })

  -- ZenTermVSplit - Open terminal in vertical split
  vim.api.nvim_create_user_command("ZenTermVSplit", function(opts)
    local term_opts = {
      mode = "vsplit",
      name = opts.args ~= "" and opts.args or nil,
    }
    terminal.create_terminal(term_opts)
  end, {
    nargs = "?",
    desc = "Open terminal in vertical split",
  })

  -- ZenTermToggle - Toggle last terminal
  vim.api.nvim_create_user_command("ZenTermToggle", function()
    terminal.toggle_terminal()
  end, {
    desc = "Toggle last terminal",
  })

  -- ZenTermNew - Create new named terminal
  vim.api.nvim_create_user_command("ZenTermNew", function(opts)
    local name = opts.args ~= "" and opts.args or nil
    terminal.create_terminal({ name = name })
  end, {
    nargs = "?",
    desc = "Create new named terminal",
  })

  -- ZenTermClose - Close current/specified terminal
  vim.api.nvim_create_user_command("ZenTermClose", function(opts)
    local id = opts.args ~= "" and opts.args or nil
    terminal.close_terminal(id, false)
  end, {
    nargs = "?",
    desc = "Close current/specified terminal",
  })

  -- ZenTermCloseAll - Close all terminals
  vim.api.nvim_create_user_command("ZenTermCloseAll", function(opts)
    local force = opts.bang
    terminal.close_all_terminals(force)
  end, {
    bang = true,
    desc = "Close all terminals (use ! to force)",
  })

  -- ZenTermSend - Send command to current terminal
  vim.api.nvim_create_user_command("ZenTermSend", function(opts)
    if opts.args == "" then
      utils.notify_error("No command specified")
      return
    end
    terminal.send_command(nil, opts.args)
  end, {
    nargs = "+",
    desc = "Send command to current terminal",
  })

  -- ZenTermList - List all terminals
  vim.api.nvim_create_user_command("ZenTermList", function()
    local terminals = terminal.list_terminals()

    if #terminals == 0 then
      utils.notify("No terminals open")
      return
    end

    print("=== ZenTerm Terminals ===")
    for _, term in ipairs(terminals) do
      local status = term.win and "visible" or "hidden"
      print(string.format("  [%s] %s - %s (%s)", term.id, term.name, term.mode, status))
    end
  end, {
    desc = "List all terminals",
  })

  -- ZenTermNext - Switch to next terminal
  vim.api.nvim_create_user_command("ZenTermNext", function()
    terminal.next_terminal()
  end, {
    desc = "Switch to next terminal",
  })

  -- ZenTermPrev - Switch to previous terminal
  vim.api.nvim_create_user_command("ZenTermPrev", function()
    terminal.prev_terminal()
  end, {
    desc = "Switch to previous terminal",
  })

  -- Lazygit commands
  vim.api.nvim_create_user_command("ZenTermLazygit", function(opts)
    local dir = opts.args ~= "" and opts.args or nil
    local lazygit = require("zenterm.integrations.lazygit")
    lazygit.toggle_lazygit(dir)
  end, {
    nargs = "?",
    desc = "Toggle lazygit",
  })

  vim.api.nvim_create_user_command("ZenTermLazygitCurrentFile", function()
    local lazygit = require("zenterm.integrations.lazygit")
    lazygit.open_lazygit_current_file()
  end, {
    desc = "Open lazygit focused on current file",
  })

  -- Tmux commands
  vim.api.nvim_create_user_command("ZenTermTmuxSplit", function(opts)
    local direction = opts.args ~= "" and opts.args or "horizontal"
    if direction ~= "horizontal" and direction ~= "vertical" and direction ~= "h" and direction ~= "v" then
      utils.notify_error("Invalid direction. Use 'horizontal', 'vertical', 'h', or 'v'")
      return
    end
    -- Normalize direction
    if direction == "h" then
      direction = "horizontal"
    elseif direction == "v" then
      direction = "vertical"
    end
    local tmux = require("zenterm.integrations.tmux")
    tmux.open_in_tmux(direction)
  end, {
    nargs = "?",
    desc = "Create tmux pane split",
  })

  vim.api.nvim_create_user_command("ZenTermTmuxSend", function(opts)
    if opts.args == "" then
      utils.notify_error("No command specified")
      return
    end
    local tmux = require("zenterm.integrations.tmux")
    local current_pane = tmux.get_current_pane_id()
    if current_pane then
      tmux.send_to_tmux_pane(current_pane, opts.args)
    else
      utils.notify_error("Could not get current tmux pane")
    end
  end, {
    nargs = "+",
    desc = "Send command to tmux pane",
  })

  vim.api.nvim_create_user_command("ZenTermTmuxList", function()
    local tmux = require("zenterm.integrations.tmux")
    local panes = tmux.list_tmux_panes()

    if #panes == 0 then
      utils.notify("No tmux panes found or not in tmux")
      return
    end

    print("=== Tmux Panes ===")
    for _, pane in ipairs(panes) do
      local status = pane.active and "*" or " "
      print(string.format("  [%s] %s - %s", status, pane.id, pane.command))
    end
  end, {
    desc = "List tmux panes",
  })

  vim.api.nvim_create_user_command("ZenTermTmuxNav", function()
    local tmux = require("zenterm.integrations.tmux")
    tmux.setup_navigation_sync()
  end, {
    desc = "Enable tmux navigation sync",
  })

  utils.debug("Commands setup complete")
end

return M

