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
    week = week,
  }
end

-- Parse all available directories directly below rootDir
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
  -- local rootDir = Config.options.rootDir
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

-- Currently unused as not sure how to await this function
-- and use coroutines / async programming in lua :shrug:
M.select_category_dirs = function()
  local available_categories = M.parse_available_categories()
  print("available_categories" .. vim.inspect(available_categories))

  vim.ui.select(available_categories, {
    prompt = "Select Category",
  }, function(selected_category)
    print("selected_category" .. selected_category)
    local available_subcategories = M.parse_available_subcategories(selected_category)

    print("available_subcategories" .. vim.inspect(available_subcategories))
    vim.ui.select(available_subcategories, {
      prompt = "Select Subcategory",
    }, function(selected_subcategory)
      print("selected_subcategory" .. selected_subcategory)
      return {
        category = selected_category,
        subcategory = selected_subcategory,
      }
    end)
  end)
end

return M
