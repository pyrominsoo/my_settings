require("moonguard.set")
require("moonguard.headers")
require("moonguard.remap")
require("moonguard.abbr")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
-- local MoonguardGroup = augroup('Moonguard', {})
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- autocmd({"BufWritePre"}, {
--     group = MoonguardGroup,
--     pattern = "*",
--     command = [[%s/\s\+$//e]],
-- })

autocmd('InsertLeave', {
    pattern = '*',
    callback = function()
        vim.cmd('set nopaste')
    end,
})

vim.cmd(':autocmd FileType qf wincmd J')
vim.cmd('source ~/.config/nvim/netrw_mapping.vim')
vim.cmd('source ~/.config/nvim/gdb.vim')
vim.cmd('source ~/.config/nvim/quickfix.vim')

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_altv = 1

vim.api.nvim_create_user_command(
    'Tag',
    '!./tag.sh',
    {}
)

vim.api.nvim_create_user_command(
    'W',
    'w',
    {}
)
vim.api.nvim_create_user_command(
    'Wq',
    'wq',
    {}
)
vim.api.nvim_create_user_command(
    'WQ',
    'wq',
    {}
)

vim.cmd([[set grepprg=rg\ --vimgrep\ --no-heading]])
vim.cmd([[set grepformat=%f:%l:%c:%m,%f:%l:%m]])
vim.cmd([[set listchars=tab:>~,nbsp:_,trail:.]])

-- disable autocomment
vim.cmd([[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]])


function SearchToday()
    local base = os.date('%Y-%m-%d')
    str = [[grep! "\[ \] .*]] .. base .. [["]]
    vim.cmd(str)
    vim.cmd("cw")
end

function SearchTomo()
    local timeshift = 24 * 60 * 60
    local base = os.date('%Y-%m-%d', os.time() + timeshift)
    str = [[grep! "\[ \] .*]] .. base .. [["]]
    vim.cmd(str)
    vim.cmd("cw")
end

function SearchNodate()
    str = [[grep! "\[ \] .*"]]
    vim.cmd(str)
    vim.cmd("cw")
end

local TextTasks = vim.api.nvim_create_augroup("TextTasks", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd({"BufEnter", "BufWinEnter"}, {
    group = TextTasks,
    pattern = "*.txt",
    callback = function()
        vim.keymap.set("n", "<leader>td", SearchToday)
        vim.keymap.set("n", "<leader>tm", SearchTomo)
        vim.keymap.set("n", "<leader>tn", SearchNodate)
    end,
})

-- Function to create a task at the cursor
local function CreateTask(sentence)
  local date = os.date("%Y-%m-%d")
  local task = string.format("[ ] %s <%s", sentence, date)
  vim.api.nvim_put({task}, "c", true, true)
end

-- User command: :CreateTask Your task here
vim.api.nvim_create_user_command("Task", function(opts)
  CreateTask(opts.args)
end, { nargs = "+" })

-- Keymap: <leader>;t prompts for a task and inserts it
vim.keymap.set('n', '<leader>;t', function()
  vim.ui.input({ prompt = "Task: " }, function(input)
    if input and #input > 0 then
      CreateTask(input)
    end
  end)
end, { desc = "Create new task" })

vim.keymap.set('n', '<leader>;h', function()
  -- Get current file name without extension
  local filename = vim.fn.expand("%:t:r")
  -- ISO 8601 date/time with timezone
  local datetime = os.date("%Y-%m-%dT%H:%M:%S") .. "-07:00"
  -- "Created" line, e.g., "Created Friday 04 July 2025"
  local created = os.date("Created %A %d %B %Y")
  local header = string.format(
    "Content-Type: text/x-zim-wiki\nWiki-Format: zim 0.6\nCreation-Date: %s",
    datetime
  )
  local lines = vim.split(header, "\n")
  table.insert(lines, "")  -- blank line
  table.insert(lines, string.format("====== %s ======", filename))
  table.insert(lines, created)
  vim.api.nvim_put(lines, "c", true, true)
end, { desc = "Insert Zim Wiki header and section with filename" })




-- Helper: Open a file with the system default application
local function open_with_default(filepath)
  vim.fn.jobstart({'xdg-open', filepath}, {detach = true})
end

-- Main function for <leader>;o
local function open_delimited_filename()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = col + 1 -- Lua strings are 1-based

  -- Patterns for [[FILENAME]] and {{FILENAME}}
  local patterns = {
    {pattern = "%[%[(.-)%]%]"},
    {pattern = "%{%{(.-)%}%}"},
  }

  for _, pat in ipairs(patterns) do
    local search_start = 1
    while true do
      local s, e, fname = string.find(line, pat.pattern, search_start)
      if not s then break end
      if cursor_pos >= s and cursor_pos <= e then
        -- Get the current file's directory and name (without extension)
        local currfile = vim.api.nvim_buf_get_name(0)
        local currdir = vim.fn.fnamemodify(currfile, ":h")
        local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")

        -- Expand FILENAME if it starts with ./ or .\
        local expanded = fname
        if fname:sub(1,2) == "./" or fname:sub(1,2) == ".\\" then
          expanded = currdir .. "/" .. name_no_ext .. "/" .. fname:sub(3)
        end

        open_with_default(expanded)
        return
      end
      search_start = e + 1
    end
  end

  vim.notify("No [[FILENAME]] or {{FILENAME}} under cursor", vim.log.levels.ERROR)
end

-- Key mapping: <leader>;o in normal mode
vim.keymap.set('n', '<leader>;o', open_delimited_filename, { noremap = true, silent = true, desc = "Open [[FILENAME]] or {{FILENAME}} under cursor" })





vim.keymap.set('n', '<leader>;f', function()
  -- Properly escape and quote the pattern for vimgrep!
  local pattern = [[/\[\[.\{-}\]\]\|{{.\{-}}}/]]
  -- Run vimgrep! with the pattern on the current file
  vim.cmd('vimgrep! ' .. pattern .. ' %')
  -- Open the quickfix window if there are matches
  vim.cmd('cw')
end, { noremap = true, silent = true, desc = "List all [[FILENAME]] and {{FILENAME}} in quickfix" })





local function DeleteFile()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = col + 1 -- Lua strings are 1-based

  -- Patterns for [[FILENAME]] and {{FILENAME}}
  local patterns = {
    {pattern = "%[%[(.-)%]%]"},
    {pattern = "%{%{(.-)%}%}"},
  }

  for _, pat in ipairs(patterns) do
    local search_start = 1
    while true do
      local s, e, fname = string.find(line, pat.pattern, search_start)
      if not s then break end
      if cursor_pos >= s and cursor_pos <= e then
        -- Get the current file's directory and name (without extension)
        local currfile = vim.api.nvim_buf_get_name(0)
        local currdir = vim.fn.fnamemodify(currfile, ":h")
        local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")

        -- Expand FILENAME if it starts with ./ or .\
        local expanded = fname
        if fname:sub(1,2) == "./" or fname:sub(1,2) == ".\\" then
          expanded = currdir .. "/" .. name_no_ext .. "/" .. fname:sub(3)
        end

        -- Prompt for confirmation
        vim.ui.input({ prompt = "Delete file '" .. expanded .. "'? (yes/no): " }, function(input)
          if input and (input == "yes" or input == "y") then
            local ok, err = os.remove(expanded)
            if ok then
              -- Remove the matched pattern from the line
              local new_line = line:sub(1, s - 1) .. line:sub(e + 1)
              vim.api.nvim_set_current_line(new_line)
              -- Move cursor to the start of the removed pattern
              vim.api.nvim_win_set_cursor(0, {row, s - 1})
              vim.notify("Deleted: " .. expanded, vim.log.levels.INFO)
            else
              vim.notify("Failed to delete: " .. (err or expanded), vim.log.levels.ERROR)
            end
          else
            vim.notify("Aborted delete", vim.log.levels.INFO)
          end
        end)
        return
      end
      search_start = e + 1
    end
  end

  vim.notify("No [[FILENAME]] or {{FILENAME}} under cursor", vim.log.levels.ERROR)
end

-- Example key mapping for DeleteFile: <leader>;d
vim.keymap.set('n', '<leader>;d', DeleteFile, { noremap = true, silent = true, desc = "Delete file under [[FILENAME]] or {{FILENAME}} and remove the pattern" })


-- Helper: Open a directory with the system default file explorer
local function open_directory(dirpath)
  vim.fn.jobstart({'xdg-open', dirpath}, {detach = true})
  vim.notify("Opened directory with xdg-open: " .. dirpath, vim.log.levels.INFO)
end

local function open_current_file_dir()
  local currfile = vim.api.nvim_buf_get_name(0)
  if currfile == "" then
    vim.notify("No file is currently open.", vim.log.levels.ERROR)
    return
  end
  local currdir = vim.fn.fnamemodify(currfile, ":h")
  local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")
  local target_dir = currdir .. "/" .. name_no_ext

  if vim.fn.isdirectory(target_dir) == 0 then
    vim.ui.input({ prompt = "Directory '" .. target_dir .. "' does not exist. Create it? (yes/no): " }, function(input)
      if input and (input == "yes" or input == "y") then
        local ok, err = pcall(vim.fn.mkdir, target_dir, "p")
        if ok then
          vim.notify("Created directory: " .. target_dir, vim.log.levels.INFO)
          open_directory(target_dir)
        else
          vim.notify("Failed to create directory: " .. (err or target_dir), vim.log.levels.ERROR)
        end
      else
        vim.notify("Aborted: Directory not created.", vim.log.levels.INFO)
      end
    end)
  else
    open_directory(target_dir)
  end
end

vim.keymap.set('n', '<leader>;e', open_current_file_dir, { noremap = true, silent = true, desc = "Open $CURRDIR/$NAME/ in file explorer" })




local function open_pagename_under_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = col + 1 -- Lua strings are 1-based

  -- Find [[PAGENAME]] under cursor
  local s, e, pagename = string.find(line, "%[%[([^%]]-)%]%]")
  while s do
    if cursor_pos >= s and cursor_pos <= e then
      local orig_pagename = pagename
      local currfile = vim.api.nvim_buf_get_name(0)
      local currdir = vim.fn.fnamemodify(currfile, ":h")
      local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")
      local relpath, startdir, fullpath

      -- Transform PAGENAME: replace : with /, space with _, append .txt
      local function transform_pagename(pn)
        return pn:gsub(":", "/"):gsub(" ", "_") .. ".txt"
      end

      -- If first character is '+'
      if pagename:sub(1, 1) == "+" then
        pagename = pagename:sub(2)
        relpath = transform_pagename(pagename)
        startdir = currdir .. "/" .. name_no_ext
        fullpath = startdir .. "/" .. relpath
        vim.cmd.edit(fullpath)
        return
      else
        relpath = transform_pagename(pagename)
        local session_root = vim.fn.getcwd()
        local search_dir = currdir
        local found = false

        -- Helper: normalize path (remove trailing /)
        local function normpath(path)
          return path:gsub("/+$", "")
        end

        -- Search upwards for the file, stopping at session root
        while true do
          local candidate = normpath(search_dir) .. "/" .. relpath
          if vim.fn.filereadable(candidate) == 1 then
            startdir = search_dir
            fullpath = candidate
            found = true
            break
          end
          if normpath(search_dir) == normpath(session_root) then
            break
          end
          local parent = vim.fn.fnamemodify(search_dir, ":h")
          if parent == search_dir then
            break
          end
          search_dir = parent
        end

        if not found then
          vim.notify("Cannot find file for [[" .. orig_pagename .. "]] in current or parent directories up to session root.", vim.log.levels.ERROR)
          return
        end

        vim.cmd.edit(fullpath)
        return
      end
    end
    -- Look for next match on the line
    s, e, pagename = string.find(line, "%[%[([^%]]-)%]%]", e + 1)
  end
  vim.notify("No [[PAGENAME]] under cursor", vim.log.levels.ERROR)
end

vim.keymap.set('n', '<leader>;g', open_pagename_under_cursor, { noremap = true, silent = true, desc = "Open [[PAGENAME]] as file" })

