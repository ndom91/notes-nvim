local Config = require("notes-nvim.config")

local M = {}

-- Notes are organised in a directory structure by (1) category (2) subcategory and (3) week number
-- So that for example the directory rootDir/work/gitbutler/33 should result in a parsed table
-- where category = work, subcategory = gitbutler and week = 33
function M.parse_note_path(notePath)
  local rootDir = Config.options.rootDir
  local note = string.gsub(notePath, rootDir .. "/", "")
  local category, subcategory, week = string.match(note, "([^/]+)/([^/]+)/(%d+)")
  return {
    category = category,
    subcategory = subcategory,
    week = week
  }
end

-- Parse all available directories directly below rootDir
function M.parse_available_categories()
  local rootDir = Config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if(!handle) then
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
  local rootDir = Config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. "/" .. category .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if(!handle) then
    print("Error: No subcategories found")
    return
  end

  for line in handle:lines() do
    -- table.insert(notes, M.parse_note_path(line))
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

function M.select_category_dirs()
  local available_categories = M.parse_available_categories()
  local selected_category = ""
  vim.ui.select(available_categories, {
    prompt = "Select Category"
  },function(selected)
    selected_category = selected
  end)

  local available_subcategories = M.parse_available_subcategories(selected_category)
  local selected_subcategory = ""
  vim.ui.select(available_subcategories, {
    prompt = "Select Subcategory"
  },function(selected)
    selected_subcategory = selected
  end)

  return {
    category = selected_category,
    subcategory = selected_subcategory
  }
end

return M
