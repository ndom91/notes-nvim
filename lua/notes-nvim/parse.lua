local a = require("notes-nvim.async")
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
  local rootDir = Config.options.rootDir
  local notes = {}
  local cmd = "find " .. rootDir .. "/" .. category .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No subcategories found")
    return
  end

  -- local ok, out = pcall(vim.fn.system, {
  --   "find",
  --   rootDir .. "/" .. category .. " -mindepth 1 -maxdepth 1 -type d",
  -- })
  --
  -- print('SUBCATEO')
  --
  -- if not ok or vim.v.shell_error ~= 0 then
  --   vim.api.nvim_echo({
  --     { "Error: No subcategories found\n", "ErrorMsg" },
  --   }, true, {})
  --   vim.fn.getchar()
  --   return
  -- end

  for line in handle:lines() do
    -- table.insert(notes, M.parse_note_path(line))
    table.insert(notes, line)
  end
  handle:close()

  return notes
end

local select_category_dirs = a.sync(function()
  local available_categories = M.parse_available_categories()
  print("available_categories" .. vim.inspect(available_categories))

  local categories = {
    category = "",
    subcategory = "",
  }

  vim.ui.select(available_categories, {
    prompt = "Select Category",
  }, function(selected_category)
    print("selected_category" .. selected_category)
    local available_subcategories = M.parse_available_subcategories(selected_category)

    print("available_subcategories" .. vim.inspect(available_subcategories))
    categories.subcategory = vim.ui.select(available_subcategories, {
      prompt = "Select Subcategory",
    }, function(selected_subcategory)
      print("selected_subcategory" .. selected_subcategory)
      return {
        category = selected_category,
        subcategory = selected_subcategory,
      }
    end)
  end)

  -- vim.ui.select(available_categories, {
  --   prompt = "Select Category",
  -- }, function(selected_category)
  --   local available_subcategories = M.parse_available_subcategories(selected_category)
  --   print("available_subcategories" .. vim.inspect(available_subcategories))
  --
  --   vim.ui.select(available_subcategories, {
  --     prompt = "Select Subcategory",
  --   }, function(selected_subcategory)
  --     return {
  --       category = selected_category,
  --       subcategory = selected_subcategory,
  --     }
  --   end)
  -- end)
  return categories
end)
M.select_category_dirs = select_category_dirs

return M
