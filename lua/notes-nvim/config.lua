local M = {}

local defaults = {
  rootDir = os.getenv("XDG_DOCUMENTS_DIR") or os.getenv("HOME") .. "/Documents",
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts)

  vim.api.nvim_create_user_command("NotesNew", function()
    require("notes-nvim").create_note()
  end, {
    nargs = "*",
    -- complete = function(...)
    --   return require("trouble.command").complete(...)
    -- end,
    desc = "Create Note",
  })
  vim.api.nvim_create_user_command("NotesListAll", function()
    require("notes-nvim").list_notes()
  end, {
    nargs = "*",
    desc = "List Note",
  })
  vim.api.nvim_create_user_command("NotesOpen", function()
    require("notes-nvim").open_note()
  end, {
    nargs = "*",
    desc = "List Note",
  })
  vim.api.nvim_create_user_command("NotesCreateNewWeek", function()
    require("notes-nvim").create_new_week_dir()
  end, {
    nargs = "*",
    desc = "Notes Create New Week",
  })
end

return M
