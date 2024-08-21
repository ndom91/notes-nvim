local a = require("notes-nvim.async")
local Config = require("notes-nvim.config")
local Parse = require("notes-nvim.parse")

local M = {}

function M.setup(opts)
  vim.api.nvim_echo({
    {
      "Loading notes-nvim\n\n",
      "DiagnosticInfo",
    },
  }, true, {})

  Config.setup(opts)
end

function M.list_notes()
  local rootDir = Config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. " -type f -name '*.md'"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No notes found in rootDir: " .. rootDir)
    return
  end

  for line in handle:lines() do
    table.insert(notes, line)
  end
  handle:close()
  return notes
end

function M.open_note()
  local notes = M.list_notes()
  -- local note = vim.fn.inputlist(notes)
  -- if note == 0 then
  --   return
  -- end

  local selected_note = ""
  vim.ui.select(notes, {
    prompt = "Open Note",
  }, function(selected)
    selected_note = selected
    vim.cmd("e " .. selected_note)
  end)
end

function M.create_new_week_dir()
  local rootDir = Config.options.rootDir
  local cats = Parse.select_category_dirs()
  local week_number = "W" .. os.date("%V")

  local week_path = rootDir .. "/" .. cats.category .. "/" .. cats.subcategory .. "/" .. week_number

  if vim.fn.isdirectory(week_path) == 1 then
    print("Week " .. week_number .. " directory already exists")
    return
  end

  local note_path = week_path .. "/" .. "TODO.md"

  os.execute("mkdir -p " .. week_path)
  os.execute("touch " .. note_path)

  vim.cmd("e " .. note_path)
end

function M.create_note()
  local rootDir = Config.options.rootDir
  local note = vim.fn.input("Enter note name: ")
  if note == "" then
    return
  end

  local cats
  cats = a.wait(Parse.select_category_dirs())
  print("Parsed Categories:")
  print(vim.inspect(cats))
  -- select_category_dirs is an async function
  -- wait on its results before proceeding

  local week_number = "W" .. os.date("%V")

  local notePath = rootDir
    .. "/"
    .. cats.category
    .. "/"
    .. cats.subcategory
    .. "/"
    .. week_number
    .. "/"
    .. note
    .. ".md"

  local cmd = "touch " .. notePath
  os.execute(cmd)
  vim.cmd("e " .. notePath)
end

M.setup()

return M
