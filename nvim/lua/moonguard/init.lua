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
    local str = [[grep! -g "*.txt" "\[ \] .*]] .. base .. [["]]
    vim.cmd(str)
    vim.cmd("cw")
end

function SearchTomo()
    local timeshift = 24 * 60 * 60
    local base = os.date('%Y-%m-%d', os.time() + timeshift)
    local str = [[grep! -g "*.txt" "\[ \] .*]] .. base .. [["]]
    vim.cmd(str)
    vim.cmd("cw")
end

function SearchNodate()
    local str = [[grep! -g "*.txt" "\[ \] .*"]]
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



-- Function to format a task string
local function format_task(text)
  local date = os.date("%Y-%m-%d")
  return string.format("[ ] %s <%s", text, date)
end

-- <leader>;t: smart task creator
vim.keymap.set('n', '<leader>;t', function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*$") then
    -- Line is empty or whitespace: prompt for input and insert below
    vim.ui.input({ prompt = "Task: " }, function(input)
      if input and #input > 0 then
        local task = format_task(input)
        vim.api.nvim_put({task}, "c", true, true)
      end
    end)
  else
    -- Line has content: replace entire line with formatted task
    local task = format_task(line)
    vim.api.nvim_buf_set_lines(0, row-1, row, false, {task})
  end
end, { desc = "Create new task or replace line as task" })







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
  -- Prefer wslview if available, else xdg-open
  local opener = vim.fn.executable("wslview") == 1 and "wslview"
                or (vim.fn.executable("xdg-open") == 1 and "xdg-open")
  if opener then
    vim.fn.jobstart({opener, filepath}, {detach = true})
  else
    vim.notify("No suitable opener found (wslview or xdg-open)", vim.log.levels.ERROR)
  end
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

-- Commented out as its functionality was merged with <leader>;g
-- -- Key mapping: <leader>;o in normal mode
-- vim.keymap.set('n', '<leader>;o', open_delimited_filename, { noremap = true, silent = true, desc = "Open [[FILENAME]] or {{FILENAME}} under cursor" })





vim.keymap.set('n', '<leader>;f', function()
  local filename_matches = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Helper to check if a string is a FILENAME
  local function is_filename(str)
    return str:sub(1, 1) == "." or
           str:find("[/\\]") or
           str:find("%.[^./\\]+$")
  end

  for lnum, line in ipairs(lines) do
    -- Find all [[...]] links
    for link in line:gmatch("%[%[([^%]]+)%]%]") do
      if is_filename(link) then
        table.insert(filename_matches, {
          bufnr = bufnr,
          lnum = lnum,
          col = line:find("%[%[" .. vim.pesc(link) .. "%]%]"),
          text = line
        })
      end
    end
    -- Find all {{...}} links
    for link in line:gmatch("%{%{(.-)%}%}") do
      if is_filename(link) then
        table.insert(filename_matches, {
          bufnr = bufnr,
          lnum = lnum,
          col = line:find("{{" .. vim.pesc(link) .. "}}"),
          text = line
        })
      end
    end
  end

  if #filename_matches == 0 then
    vim.notify("No [[FILENAME]] or {{FILENAME}} links found.", vim.log.levels.INFO)
  else
    vim.fn.setqflist({}, ' ', {
      title = 'FILENAME links',
      items = vim.tbl_map(function(m)
        return {
          bufnr = m.bufnr,
          lnum = m.lnum,
          col = m.col or 1,
          text = m.text,
        }
      end, filename_matches)
    })
    vim.cmd('copen')
  end
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
  -- Prefer wslview if available, else xdg-open
  local opener = vim.fn.executable("wslview") == 1 and "wslview"
                or (vim.fn.executable("xdg-open") == 1 and "xdg-open")
  if opener then
    vim.fn.jobstart({opener, dirpath}, {detach = true})
    vim.notify("Opened directory with wslview: " .. dirpath, vim.log.levels.INFO)
  else
    vim.notify("No suitable opener found (wslview or xdg-open)", vim.log.levels.ERROR)
  end
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
        -- Create the directory if it does not exist
        if vim.fn.isdirectory(startdir) == 0 then
          local ok, err = pcall(vim.fn.mkdir, startdir, "p")
          if not ok then
            vim.notify("Failed to create directory: " .. (err or startdir), vim.log.levels.ERROR)
            return
          end
        end
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

-- Commented out as it was merged with <leader>;o
-- vim.keymap.set('n', '<leader>;g', open_pagename_under_cursor, { noremap = true, silent = true, desc = "Open [[PAGENAME]] as file" })




local function create_link_from_path_under_cursor()
  local cwd = vim.fn.getcwd()
  local currfile = vim.api.nvim_buf_get_name(0)
  local curr_rel = vim.fn.fnamemodify(currfile, ":.")
  local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")
  -- Get current line and cursor position
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = col + 1 -- Lua strings are 1-based

  -- Find a .txt relative path under the cursor (match word chars, /, _, -, and .txt at the end)
  local pattern = "([%w%-%._/]+%.txt)"
  local s, e, path_under_cursor = string.find(line, pattern)
  local found = false
  while s do
    if cursor_pos >= s and cursor_pos <= e then
      found = true
      break
    end
    s, e, path_under_cursor = string.find(line, pattern, e + 1)
  end

  if not found or not path_under_cursor then
    vim.notify("No relative .txt file path under cursor", vim.log.levels.ERROR)
    return
  end

  -- Make both paths absolute for comparison
  local abs_under_cursor = vim.fn.fnamemodify(path_under_cursor, ":p")
  local abs_currfile = vim.fn.fnamemodify(currfile, ":p")

  -- Get the relative paths to cwd
  local rel_under_cursor = vim.fn.fnamemodify(abs_under_cursor, ":.")
  local rel_currfile = vim.fn.fnamemodify(abs_currfile, ":.")

  -- Split paths into components
  local function split_path(p)
    local t = {}
    for part in string.gmatch(p, "[^/]+") do
      table.insert(t, part)
    end
    return t
  end

  local parts1 = split_path(rel_under_cursor)
  local parts2 = split_path(rel_currfile)

  -- Find common prefix
  local i = 1
  while parts1[i] and parts2[i] and parts1[i] == parts2[i] do
    i = i + 1
  end

  -- Remove common prefix
  local remaining = {}
  for j = i, #parts1 do
    table.insert(remaining, parts1[j])
  end

  if #remaining == 0 then
    vim.notify("The two files are the same or no unique path found.", vim.log.levels.ERROR)
    return
  end

  -- If the remaining path starts with $NAME/, replace with +
  local pagename
  if #remaining >= 2 and remaining[1] == name_no_ext then
    -- Remove the $NAME/ prefix and replace with +
    table.remove(remaining, 1)
    pagename = "+" .. table.concat(remaining, "/")
  else
    pagename = table.concat(remaining, "/")
  end

  -- Replace / with :, remove .txt, wrap with [[ ]]
  pagename = pagename:gsub("/", ":")
  pagename = pagename:gsub("%.txt$", "")
  local link = "[[" .. pagename .. "]]"

  -- Replace the path under cursor with the link string
  local newline = line:sub(1, s - 1) .. link .. line:sub(e + 1)
  vim.api.nvim_set_current_line(newline)
  -- Move cursor to the start of the new link
  vim.api.nvim_win_set_cursor(0, {row, s - 1})

  vim.notify("Replaced path with link: " .. link, vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>;l', create_link_from_path_under_cursor, { noremap = true, silent = true, desc = "Replace .txt path under cursor with [[PAGENAME]] link" })




local function grep_and_sort_dates()
  -- Regex: [ ] ... <YYYY-MM-DD
  local rg_pattern = [[\[ \].*<\d{4}-\d{2}-\d{2}]]
  local grep_cmd

  if vim.fn.executable("rg") == 1 then
    -- rg outputs: filename:line:text
    grep_cmd = "rg --type-add 'txt:*.txt' --type txt -n -e '" .. rg_pattern .. "' --no-heading"
  else
    -- grep outputs: filename:line:text
    grep_cmd = "grep -r -n -E '" .. [[\[ \].*<([0-9]{4}-[0-9]{2}-[0-9]{2})]] .. "' --include='*.txt' ."
  end

  local handle = io.popen(grep_cmd)
  if not handle then
    vim.notify("Failed to run grep command!", vim.log.levels.ERROR)
    return
  end
  local result = handle:read("*a")
  handle:close()

  -- Parse lines and extract date for sorting
  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    -- Extract filename, line number, and text
    local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
    if filename and lnum and text then
      -- Extract the first <YYYY-MM-DD found in the line
      local date = text:match("<(%d%d%d%d%-%d%d%-%d%d)")
      -- Ensure [ ] comes before the date
      local pos_checkbox = text:find("%[ %]")
      local pos_date = text:find("<%d%d%d%d%-%d%d%-%d%d")
      if date and pos_checkbox and pos_date and pos_checkbox < pos_date then
        table.insert(lines, {date = date, filename = filename, lnum = tonumber(lnum), text = text})
      end
    end
  end

  -- Sort by date (chronological)
  table.sort(lines, function(a, b) return a.date < b.date end)

  -- Prepare quickfix list
  local qf = {}
  for _, entry in ipairs(lines) do
    table.insert(qf, {
      filename = entry.filename,
      lnum = entry.lnum,
      col = 1,
      text = entry.text
    })
  end

  if #qf == 0 then
    vim.notify("No lines with [ ] before <YYYY-MM-DD found in .txt files.", vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, ' ', {title = "Lines with [ ] before <YYYY-MM-DD", items = qf})
  vim.cmd("copen")
  vim.notify("Sorted results loaded in quickfix window.", vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>;k', grep_and_sort_dates, { noremap = true, silent = true, desc = "Grep [ ] ... <YYYY-MM-DD in .txt files and sort chronologically" })




local function open_file_page_or_url()
  -- Get the string under cursor, stripping [[ ]]
  local cword = vim.fn.expand("<cWORD>")
  local str = cword:gsub("^%[%[", ""):gsub("%]%]$", "")

  -- URL detection regex (matches http(s)://, ftp://, etc.)
  if str:match("^[a-zA-Z]+://%S+$") then
    -- Prefer wslview if available, else xdg-open
    local opener = vim.fn.executable("wslview") == 1 and "wslview"
                or (vim.fn.executable("xdg-open") == 1 and "xdg-open")
    if opener then
      vim.fn.jobstart({opener, str}, {detach = true})
      vim.notify("Opened URL: " .. str, vim.log.levels.INFO)
    else
      vim.notify("No suitable URL opener found (wslview or xdg-open)", vim.log.levels.ERROR)
    end
    return
  end

  -- If it starts with a dot, treat as file
  if str:sub(1, 1) == "." then
    open_delimited_filename()
    return
  end

  -- If it contains a slash (forward or back) or has an extension, treat as file
  if str:find("[/\\]") or str:find("%.[^./\\]+$") then
    open_delimited_filename()
    return
  end

  -- Otherwise, treat as page name
  open_pagename_under_cursor()
end

vim.keymap.set('n', '<leader>;o', open_file_page_or_url, { noremap = true, silent = true, desc = "Open file, page, or URL under cursor" })





local function capitalize_sentences_in_line(line)
  line = line:lower()
  line = line:gsub("^%s*([a-z])", function(c) return c:upper() end)
  line = line:gsub("([%.!?][\"')%]]*%s+)([a-z])", function(punct, c)
    return punct .. c:upper()
  end)
  line = line:gsub("(%W)i(%W)", function(a, b)
    return a .. "I" .. b
  end)
  line = line:gsub("^i(%W)", "I%1")
  line = line:gsub("(%W)i$", "%1I")
  line = line:gsub("^i$", "I")
  return line
end


local function capitalize_sentences_in_visual()
  -- Get visual selection range
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    vim.notify("No visual selection active.", vim.log.levels.INFO)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_row = start_pos[2] - 1
  local end_row = end_pos[2] - 1

  -- Get and transform lines
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  for i, line in ipairs(lines) do
    lines[i] = capitalize_sentences_in_line(line)
  end
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, lines)
  vim.notify("Capitalized sentences in selection.", vim.log.levels.INFO)
end


local TextCapGroup = vim.api.nvim_create_augroup("TextCapGroup", {})
vim.api.nvim_create_autocmd("FileType", {
  group = TextCapGroup,
  pattern = "text",
  callback = function()
    -- Normal mode: current line
    vim.keymap.set("n", "<leader>;g", function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local orig_line = vim.api.nvim_get_current_line()
      local new_line = capitalize_sentences_in_line(orig_line)
      if new_line ~= orig_line then
        vim.api.nvim_set_current_line(new_line)
        vim.notify("Line capitalized.", vim.log.levels.INFO)
      else
        vim.notify("No changes made; line already capitalized.", vim.log.levels.INFO)
      end
    end, { buffer = true, noremap = true, silent = true, desc = "Capitalize sentences in line" })

    -- Visual mode: selection
    vim.keymap.set("v", "<leader>;g", capitalize_sentences_in_visual, { buffer = true, noremap = true, silent = true, desc = "Capitalize sentences in selection" })
  end,
})

