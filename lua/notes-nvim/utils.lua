local M = {}

--- Checks if a file exists. False for directories.
---@param path string
---@return boolean
function M.exists(path)
  return vim.fn.filereadable(vim.fn.expand(path)) == 1
end

--- Checks if a directory exists
---@param path string
---@return boolean
function M.dir_exists(path)
  return vim.fn.isdirectory(path) ~= 0
end

---@param paths string[]
---@return string
function M.join_paths(paths)
  return vim.fs.normalize(vim.fn.simplify(table.concat(paths, "/")))
end

-- Get parent dir
---@param dir string
---@return string
function M.parent(dir)
  return vim.fs.normalize(vim.fn.fnamemodify(dir, ":h"))
end

-- Get cwd
---@return string
function M.current_working_directory()
  return vim.fs.normalize(vim.fn.getcwd())
end

-- Get current file's directory
---@return string
function M.current_file_directory()
  return vim.fs.normalize(vim.fn.expand("%:p:h"))
end

-- Get current file
---@return string
function M.current_file()
  return vim.fs.normalize(vim.fn.expand("%:p"))
end

-- Get current buffer lines
---@param bufnr number
---@return string[]
function M.lines(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)
end

return M
