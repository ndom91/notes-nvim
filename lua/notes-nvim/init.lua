local Config = require("notes-nvim.config")
local Parse = require("notes-nvim.parse")

local M = {}

function M.setup(opts)
  -- vim.api.nvim_echo({
  --   {
  --     "Loading notes-nvim\n\n",
  --     "DiagnosticInfo",
  --   },
  -- }, true, {})

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

  vim.ui.select(notes, {
    prompt = "Open Note",
  }, function(selected)
    vim.cmd("e " .. selected)
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
  local note = vim.fn.input("Enter note name: ")
  if note == "" then
    return
  end

  local available_categories = M.parse_available_categories()

  vim.ui.select(available_categories, {
    prompt = "Select Category",
  }, function(selected_category)
    local available_subcategories = M.parse_available_subcategories(selected_category)

    vim.ui.select(available_subcategories, {
      prompt = "Select Subcategory",
    }, function(selected_subcategory)
      local week_number = "W" .. os.date("%V")
      -- Try to create dir just in case
      os.execute("mkdir -p " .. selected_subcategory .. "/" .. week_number)

      local notePath = selected_subcategory .. "/" .. week_number .. "/" .. note .. ".md"

      os.execute("touch " .. notePath)
      vim.cmd("e " .. notePath)
    end)
  end)
end

function M.parse_available_categories()
  local rootDir = Config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No categories found in rootDir")
    return
  end

  for line in handle:lines() do
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

function M.parse_available_subcategories(category)
  local notes = {}
  local cmd = "find " .. category .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No subcategories found")
    return
  end

  for line in handle:lines() do
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

M.setup()

return M
