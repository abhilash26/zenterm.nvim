# zenterm.nvim

> An extremely performant, minimal terminal plugin for Neovim with floating and split terminal support.

## ✨ Features

- 🚀 **Performant**: Lazy-loaded, minimal overhead, efficient buffer management
- 🎯 **Simple**: Clean API, intuitive defaults, minimal configuration
- 🪟 **Flexible**: Float, horizontal split, and vertical split modes
- 🔄 **Smart**: Multiple independent terminals, session management
- 🎨 **Beautiful**: Rounded borders, customizable styling
- 🔧 **Extensible**: Lazygit integration, tmux support (coming soon)

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "abhilash26/zenterm.nvim",
  config = function()
    require("zenterm").setup({
      -- your configuration here (optional)
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "abhilash26/zenterm.nvim",
  config = function()
    require("zenterm").setup()
  end
}
```

## 🚀 Quick Start

```lua
-- Basic setup with defaults
require("zenterm").setup()

-- Toggle terminal
vim.keymap.set("n", "<C-\\>", "<cmd>ZenTermToggle<cr>")

-- Or use Lua API
vim.keymap.set("n", "<C-\\>", function()
  require("zenterm").toggle()
end)
```

## ⚙️ Configuration

Default configuration with all options:

```lua
require("zenterm").setup({
  -- Window settings
  float = {
    relative = "editor",
    width = 0.8,      -- 80% of editor width
    height = 0.8,     -- 80% of editor height
    row = 0.1,        -- 10% from top
    col = 0.1,        -- 10% from left
    border = "rounded",
    winblend = 0,
  },
  split = {
    direction = "horizontal", -- or "vertical"
    size = 0.3,              -- 30% of editor
  },

  -- Terminal settings
  shell = vim.o.shell,
  auto_close = true,         -- Close window on job exit
  persist = false,           -- Keep terminal after window close
  start_in_insert = true,    -- Start in insert mode

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
```

## 📖 Usage

### Commands

```vim
:ZenTermFloat             " Open floating terminal
:ZenTermSplit             " Open horizontal split terminal
:ZenTermVSplit            " Open vertical split terminal
:ZenTermToggle            " Toggle last terminal
:ZenTermNew [name]        " Create new named terminal
:ZenTermClose             " Close current terminal
:ZenTermCloseAll          " Close all terminals
:ZenTermSend {cmd}        " Send command to terminal
:ZenTermList              " List all terminals
:ZenTermNext              " Switch to next terminal
:ZenTermPrev              " Switch to previous terminal
```

### Lua API

```lua
local zenterm = require("zenterm")

-- Toggle terminal
zenterm.toggle()

-- Open terminal with specific mode
zenterm.open("float")
zenterm.open("hsplit")
zenterm.open("vsplit")

-- Close terminal
zenterm.close()
zenterm.close_all()

-- Send commands
zenterm.send(nil, "ls -la")

-- List terminals
local terminals = zenterm.list()

-- Navigate between terminals
zenterm.next()
zenterm.prev()

-- Lazygit integration
zenterm.lazygit()
```

## 🎯 Lazygit Integration

ZenTerm includes built-in lazygit support:

```vim
" Toggle lazygit (opens in git root)
:ZenTermLazygit

" Or use keymap
<leader>gg
```

```lua
-- Lua API
require("zenterm").lazygit()
require("zenterm").lazygit("/path/to/repo")
```

## ⌨️ Default Keymaps

When configured with default mappings:

| Mode | Key | Action |
|------|-----|--------|
| Normal/Terminal | `<C-\>` | Toggle terminal |
| Normal | `<leader>tn` | New terminal |
| Normal | `<leader>tc` | Close terminal |
| Normal | `<leader>]t` | Next terminal |
| Normal | `<leader>[t` | Previous terminal |
| Normal | `<leader>gg` | Toggle lazygit |

## 🎨 Examples

### Multiple Named Terminals

```lua
-- Create different terminals for different purposes
vim.keymap.set("n", "<leader>ts", function()
  require("zenterm").open("float", { name = "server" })
end)

vim.keymap.set("n", "<leader>tt", function()
  require("zenterm").open("float", { name = "tests" })
end)
```

### Custom Float Size

```lua
require("zenterm").setup({
  float = {
    width = 0.95,  -- 95% width
    height = 0.95, -- 95% height
    border = "double",
  },
})
```

### Persistent Terminals

```lua
require("zenterm").setup({
  persist = true,  -- Keep terminals after closing window
  auto_close = false, -- Don't close on job exit
})
```

## 🔧 Tips & Tricks

### Exit Terminal Mode

In terminal mode, press `<C-\><C-n>` to return to normal mode.

### Send Selection to Terminal

```lua
-- Send visual selection to terminal
vim.keymap.set("v", "<leader>ts", function()
  local lines = vim.fn.getline("'<", "'>")
  local cmd = table.concat(lines, "\n")
  require("zenterm").send(nil, cmd)
end)
```

### Quick Terminal Toggle

Add this to your config for super quick access:

```lua
vim.keymap.set({"n", "t"}, "<C-\\>", function()
  require("zenterm").toggle()
end, { silent = true })
```

## 🚧 Roadmap

- [x] Basic floating terminal
- [x] Split terminals (horizontal/vertical)
- [x] Multiple terminal management
- [x] Lazygit integration
- [ ] Tmux integration
- [ ] Session persistence
- [ ] Terminal layouts
- [ ] Send commands from buffer
- [ ] Telescope integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- Built for the Neovim community

---

**Made with ❤️ for Neovim users who love minimal, performant plugins**
