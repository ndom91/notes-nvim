local config = require("notes-nvim.config")
local util = require("notes-nvim.utils")

local M = {}

function M.setup(opts)
  config.setup(opts)
end

M.setup()

-- Return table of all notes
---@return string[]
function M.list_notes()
  local rootDir = config.options.rootDir
  local cmd = "find " .. rootDir .. " -type f -name '*.md'"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: No notes found in rootDir: " .. rootDir)
    return {}
  end

  local notes = {}
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

-- Create a new note in the selected category and subcategory with week number
function M.create_week_note()
  local rootDir = config.options.rootDir
  local note = vim.fn.input("Enter note name: ")
  if note == "" then
    return
  end

  local available_categories = M.parse_available_directories(rootDir)

  vim.ui.select(available_categories, {
    prompt = "Select Category",
  }, function(selected_category)
    local selected_category_dir = vim.fs.basename(selected_category)
    local available_subcategories = M.parse_available_directories(util.join_paths({ rootDir, selected_category_dir }))

    if not available_subcategories then
      local new_subcategory = vim.fn.input("No subcategories found, enter new name:")
      os.execute("mkdir -p " .. util.join_paths({ rootDir, selected_category, new_subcategory }))
      available_subcategories = { new_subcategory }
    end

    vim.ui.select(available_subcategories, {
      prompt = "Select Subcategory",
    }, function(selected_subcategory)
      local selected_subcategory_dir = vim.fs.basename(selected_subcategory)
      local week_number = "W" .. os.date("%V")

      if
        not util.dir_exists(util.join_paths({ rootDir, selected_category_dir, selected_subcategory_dir, week_number }))
      then
        os.execute(
          "mkdir -p " .. util.join_paths({ rootDir, selected_category_dir, selected_subcategory_dir, week_number })
        )
      end

      local notePath =
        util.join_paths({ rootDir, selected_category_dir, selected_subcategory_dir, week_number, note .. ".md" })

      os.execute("touch " .. notePath)
      vim.cmd("e " .. notePath)
    end)
  end)
end

-- Create a new note in the selected category and subcategory
function M.create_note()
  local rootDir = config.options.rootDir
  local note = vim.fn.input("Enter note name: ")
  if note == "" then
    return
  end

  local available_categories = M.parse_available_directories(rootDir)

  vim.ui.select(available_categories, {
    prompt = "Select Category",
  }, function(selected_category)
    local selected_category_dir = vim.fs.basename(selected_category)
    local available_subcategories = M.parse_available_directories(util.join_paths({ rootDir, selected_category_dir }))

    if not available_subcategories then
      local new_subcategory = vim.fn.input("No subcategories found, enter new name:")
      os.execute("mkdir -p " .. util.join_paths({ rootDir, selected_category, new_subcategory }))
      available_subcategories = { new_subcategory }
    end

    vim.ui.select(available_subcategories, {
      prompt = "Select Subcategory",
    }, function(selected_subcategory)
      local selected_subcategory_dir = vim.fs.basename(selected_subcategory)

      if not util.dir_exists(util.join_paths({ rootDir, selected_category_dir, selected_subcategory_dir })) then
        os.execute("mkdir -p " .. util.join_paths({ rootDir, selected_category_dir, selected_subcategory_dir }))
      end

      local notePath = util.join_paths({ rootDir, selected_category_dir, selected_subcategory_dir, note .. ".md" })

      os.execute("touch " .. notePath)
      vim.cmd("e " .. notePath)
    end)
  end)
end

-- Parse available top-level categories in rootDir
---@param directory string
---@return string[]
function M.parse_available_directories(directory)
  local cmd = "find " .. directory .. " -mindepth 1 -maxdepth 1 -type d"
  local handle = io.popen(cmd)
  if not handle then
    print("Error: " .. directory .. " not found")
    return {}
  end

  local entries = {}
  for line in handle:lines() do
    table.insert(entries, line)
  end
  handle:close()

  return entries
end

return M
