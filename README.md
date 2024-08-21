# 📓 notes-nvim

Neovim plugin to manage my personal notes.

## ⚡️ Requirements

- Neovim >= **0.8.0**

## 📦 Installation

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "ndom91/notes-nvim",
  requires = { "nvim-lua/plenary.nvim" },
  config = function()
    require('notes-nvim').setup({
      rootDir = "/home/ndo/Documents/notebook",
    })
  end
}
```

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
  "ndom91/notes-nvim",
  lazy = false,
  opts = {
    rootDir = "/home/ndo/Documents/notebook"
  }
  keys = {
    {
      "<leader>no",
      function() require("notes-nvim").notes_open() end,
      mode = { "n", "v" },
      desc = "[N]otes [O]pen",
      noremap = true,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

## 🏗️ Usage

The idea is that my notes are organised in my `rootDir` under (1) a category, (2) a subcategory and then (3) directories by week number.

So for example, using the `rootDir = "/home/ndo/Documents/notebook"`, I would create an initial category called `work` and then a subcategory directory for each employer. So a final note may land somewhere like `/home/ndo/Documents/notebook/work/gitbutler/34/todo.md`.


### Options

```lua
{
  rootDir = "/home/user/Documents/notebook"
}
```

## 📝 License

MIT
