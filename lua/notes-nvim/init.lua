local config = require("notes-nvim.config")
local util = require("notes-nvim.utils")

local M = {}

function M.setup(opts)
  config.setup(opts)
end

-- Return table of all notes
---@return string[]
function M.list_notes()
  local rootDir = config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. " -type f -name '*.md'"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No notes found in rootDir: " .. rootDir)
    return {}
  end

  for line in handle:lines() do
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

-- Open note via fuzzy-find list
function M.open_note()
  local notes = M.list_notes()

  vim.ui.select(notes, {
    prompt = "Open Note",
  }, function(selected)
    vim.cmd("e " .. selected)
  end)
end

-- Create a new note in the selected category and subcategory
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

      if not util.dir_exists(selected_subcategory .. "/" .. week_number) then
        os.execute("mkdir -p " .. selected_subcategory .. "/" .. week_number)
      end

      local notePath = selected_subcategory .. "/" .. week_number .. "/" .. note .. ".md"

      os.execute("touch " .. notePath)
      vim.cmd("e " .. notePath)
    end)
  end)
end

-- Parse available top-level categories in rootDir
---@return string[]
function M.parse_available_categories()
  local rootDir = config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No categories found in rootDir")
    return {}
  end

  for line in handle:lines() do
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

-- Parse available subcategories in a category
---@param category string
---@return string[]
function M.parse_available_subcategories(category)
  local notes = {}
  local cmd = "find " .. category .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No subcategories found")
    return {}
  end

  for line in handle:lines() do
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

M.setup()

return M
