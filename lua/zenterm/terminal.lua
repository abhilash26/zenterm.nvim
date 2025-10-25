-- terminal.lua - Minimal terminal management leveraging Neovim defaults
local config = require("zenterm.config")
local state = require("zenterm.state")
local utils = require("zenterm.utils")

local M = {}

-- Create or toggle terminal
function M.toggle(mode)
  local conf = config.get()
  mode = mode or "float"

  local buf, win = state.get_last_term()

  -- If terminal window exists and is visible, hide it
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    state.set_last_term(buf, nil)
    return
  end

  -- If buffer exists and is valid, reuse it
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    -- Create new terminal buffer
    buf = vim.api.nvim_create_buf(false, true)

    -- Let Neovim handle terminal options by default
    vim.bo[buf].buflisted = false
  end

  -- Create window based on mode
  if mode == "float" then
    local float_conf = utils.get_float_config(
      conf.float.width,
      conf.float.height,
      conf.float.border
    )
    win = vim.api.nvim_open_win(buf, true, float_conf)
  elseif mode == "hsplit" then
    local size = utils.get_split_size("horizontal", conf.split.size)
    vim.cmd(string.format("botright %dsplit", size))
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
  elseif mode == "vsplit" then
    local size = utils.get_split_size("vertical", conf.split.size)
    vim.cmd(string.format("botright %dvsplit", size))
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
  end

  -- Set minimal window options
  if win and vim.api.nvim_win_is_valid(win) then
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
  end

  -- Start terminal if not already started
  if vim.bo[buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell, {
      on_exit = function()
        if conf.close_on_exit then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
            state.clear()
          end)
        end
      end,
    })
  end

  -- Auto insert mode
  if conf.auto_insert then
    vim.cmd("startinsert")
  end

  -- Update state
  state.set_last_term(buf, win)

  return buf, win
end

return M
