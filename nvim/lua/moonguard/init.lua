require("moonguard.set")
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



vim.keymap.set('n', '<leader>tn', function()
  if vim.fn.executable("rg") == 1 then
    -- ^TONO at start of line, only in .txt files
    local tono_cmd = "rg --vimgrep -g '*.txt' 'TONO'"
    local results = vim.fn.systemlist(tono_cmd)
    vim.fn.setqflist({}, ' ', { title = 'TONO at line start (.txt)', lines = results })
    vim.cmd("copen")
  else
    vim.notify("ripgrep (rg) not found in PATH", vim.log.levels.ERROR)
  end
end, { desc = 'Grep TONO (start of line, .txt)' })




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
  local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")

  -- Get current line and cursor position
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = col + 1 -- Lua strings are 1-based

  -- Helper: split path into parts
  local function split_path(p)
    local t = {}
    for part in string.gmatch(p, "[^/]+") do
      table.insert(t, part)
    end
    return t
  end

  -- Helper: build and set link line (replaces entire line and moves cursor)
  local function set_link_line(pagename)
    -- replace '/' with ':', remove trailing .txt, wrap with [[ ]]
    pagename = pagename:gsub("/", ":")
    pagename = pagename:gsub("%.txt$", "")
    local link = "[[" .. pagename .. "]]"
    vim.api.nvim_set_current_line(link)
    vim.api.nvim_win_set_cursor(0, {row, 1})  -- start of line
    vim.notify("Replaced entire line with link: " .. link, vim.log.levels.INFO)
  end

  -- Helper: process .txt path string like behavior (1)
  local function process_txt_path(path)
    -- Make absolute
    local abs_path = vim.fn.fnamemodify(path, ":p")
    local abs_currfile = vim.fn.fnamemodify(currfile, ":p")

    -- Get relative paths to cwd
    local rel_path = vim.fn.fnamemodify(abs_path, ":.")
    local rel_currfile = vim.fn.fnamemodify(abs_currfile, ":.")

    local parts1 = split_path(rel_path)
    local parts2 = split_path(rel_currfile)

    -- Find common prefix length
    local i = 1
    while parts1[i] and parts2[i] and parts1[i] == parts2[i] do
      i = i + 1
    end

    -- Extract unique suffix
    local remaining = {}
    for j = i, #parts1 do
      table.insert(remaining, parts1[j])
    end

    if #remaining == 0 then
      vim.notify("The two files are the same or no unique path found.", vim.log.levels.ERROR)
      return false
    end

    local pagename
    if #remaining >= 2 and remaining[1] == name_no_ext then
      table.remove(remaining, 1)
      pagename = "+" .. table.concat(remaining, "/")
    else
      pagename = table.concat(remaining, "/")
    end

    set_link_line(pagename)
    return true
  end

  -- Helper: wrap string with [[+string]] like behavior (2)
  local function wrap_string(str)
    local wrapped = "[[+" .. str .. "]]"
    vim.api.nvim_set_current_line(wrapped)
    vim.api.nvim_win_set_cursor(0, {row, 1})
    vim.notify("Wrapped string with link: " .. wrapped, vim.log.levels.INFO)
  end

  -- === 3rd behavior check: empty or whitespace-only line ===
  if line:match("^%s*$") then
    local reg_str = vim.fn.getreg('"')
    if reg_str == nil or reg_str == "" or reg_str:match("^%s*$") then
      vim.notify("No string found in unnamed register to create link", vim.log.levels.ERROR)
      return
    end

    -- Check if register string ends with .txt (simple check)
    if reg_str:match("%.txt$") then
      local ok = process_txt_path(reg_str)
      if not ok then
        -- fallback if processing failed: wrap whole string
        wrap_string(reg_str)
      end
      return
    else
      -- not a .txt path, wrap string
      wrap_string(reg_str)
      return
    end
  end

  -- === Old behavior: find .txt path under cursor ===

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
    -- fallback: wrap contiguous non-whitespace string under cursor with [[+ ]]
    local start_pos, end_pos

    -- Search backward for start of string
    local i = cursor_pos
    while i > 0 do
      local c = line:sub(i, i)
      if c:match("%s") then break end
      i = i - 1
    end
    start_pos = i + 1

    -- Search forward for end of string
    i = cursor_pos
    local line_len = #line
    while i <= line_len do
      local c = line:sub(i, i)
      if c:match("%s") then break end
      i = i + 1
    end
    end_pos = i - 1

    if start_pos > end_pos then
      vim.notify("No string under cursor to wrap", vim.log.levels.ERROR)
      return
    end

    local word = line:sub(start_pos, end_pos)
    local wrapped = "[[+" .. word .. "]]"
    local newline = line:sub(1, start_pos - 1) .. wrapped .. line:sub(end_pos + 1)

    vim.api.nvim_set_current_line(newline)
    vim.api.nvim_win_set_cursor(0, {row, start_pos - 1})
    vim.notify("Wrapped string under cursor with link: " .. wrapped, vim.log.levels.INFO)
    return
  end

  -- If found .txt path, replace entire line with [[PAGENAME]] link
  process_txt_path(path_under_cursor)
end

vim.keymap.set('n', '<leader>;l', create_link_from_path_under_cursor, {
  noremap = true,
  silent = true,
  desc = "Replace .txt path under cursor with [[PAGENAME]] link or wrap string with [[ ]] or use content from register if line empty"
})






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






-- Capitalizes the first letter of sentences, and standalone i
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

-- Helper: get correct line range from visual selection in any direction
local function get_visual_selection_range()
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getpos('.')
  local start_row = start_pos[2] - 1
  local end_row = end_pos[2] - 1
  if start_row > end_row then start_row, end_row = end_row, start_row end
  return start_row, end_row
end

local function capitalize_sentences_in_visual()
  -- Ensure applicable mode
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    vim.notify("No visual selection active.", vim.log.levels.INFO)
    return
  end

  -- Get true visual selection range
  local start_row, end_row = get_visual_selection_range()

  -- Check range validity
  if start_row < 0 or end_row < 0 or start_row > end_row then
    vim.notify("Invalid visual selection range.", vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
  for i, line in ipairs(lines) do
    lines[i] = capitalize_sentences_in_line(line)
  end
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, lines)
  vim.notify("Capitalized sentences in selection.", vim.log.levels.INFO)
  -- Exit visual mode (return to normal)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

-- Autocmd to map keys only in text buffers
local TextCapGroup = vim.api.nvim_create_augroup("TextCapGroup", {})
vim.api.nvim_create_autocmd("FileType", {
  group = TextCapGroup,
  pattern = "text",
  callback = function()
    -- Normal mode mapping: capitalize current line
    vim.keymap.set("n", "<leader>;g", function()
      local orig_line = vim.api.nvim_get_current_line()
      local new_line = capitalize_sentences_in_line(orig_line)
      if new_line ~= orig_line then
        vim.api.nvim_set_current_line(new_line)
        vim.notify("Line capitalized.", vim.log.levels.INFO)
      else
        vim.notify("No changes made; line already capitalized.", vim.log.levels.INFO)
      end
    end, { buffer = true, noremap = true, silent = true, desc = "Capitalize sentences in line" })

    -- Visual mode mapping: capitalize only the selection
    vim.keymap.set("v", "<leader>;g", capitalize_sentences_in_visual,
      { buffer = true, noremap = true, silent = true, desc = "Capitalize sentences in selection" })
  end,
})










-- Copy relative path of current file to system clipboard with <leader>;r
vim.api.nvim_set_keymap('n', '<leader>;r', ':let @\" = expand("%:.")<CR>', { noremap = true, silent = true })




local function add_days(date_str, days)
  local y, m, d = date_str:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not y then return nil end
  local time = os.time{year=tonumber(y), month=tonumber(m), day=tonumber(d)}
  local added = time + days * 24 * 60 * 60
  return os.date("%Y-%m-%d", added)
end

vim.keymap.set('n', '<leader>;j', function()
  vim.ui.input({ prompt = "Days to add/subtract (DATEADD): " }, function(input)
    if not input then return end
    local dateadd = tonumber(input)
    if not dateadd then
      vim.notify("Invalid DATEADD: not an integer.", vim.log.levels.ERROR)
      return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local date_pat = "(%d%d%d%d%-%d%d%-%d%d)"
    -- Find the first date and its byte indices (start_idx, end_idx)
    local start_idx, end_idx = string.find(line, "%d%d%d%d%-%d%d%-%d%d")
    local sourcedate

    if start_idx and end_idx then
      sourcedate = line:sub(start_idx, end_idx)
    else
      sourcedate = os.date("%Y-%m-%d")
    end

    local targetdate = add_days(sourcedate, dateadd)

    if not start_idx then
      -- Insert new string with TARGETDATE below cursor
      vim.api.nvim_put({targetdate}, "c", true, true)
    else
      -- Replace the detected date with TARGETDATE
      local newline = line:sub(1, start_idx - 1) .. targetdate .. line:sub(end_idx + 1)
      vim.api.nvim_set_current_line(newline)
    end
  end)
end, { desc = "Add/subtract days to date in line or insert date" })

vim.keymap.set('v', '<leader>;j', function()
  vim.ui.input({ prompt = "Days to add/subtract (DATEADD): " }, function(input)
    if not input then return end
    local dateadd = tonumber(input)
    if not dateadd then
      vim.notify("Invalid DATEADD: not an integer.", vim.log.levels.ERROR)
      return
    end

    -- Get the range of the visual selection
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    -- Ensure start_line is the smaller number
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    -- Loop through each line in the selection
    for i = start_line, end_line do
      local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
      local start_idx, end_idx = string.find(line, "%d%d%d%d%-%d%d%-%d%d")

      if start_idx and end_idx then
        local sourcedate = line:sub(start_idx, end_idx)
        local targetdate = add_days(sourcedate, dateadd)
        if targetdate then
          local newline = line:sub(1, start_idx - 1) .. targetdate .. line:sub(end_idx + 1)
          vim.api.nvim_buf_set_lines(0, i - 1, i, false, { newline })
        end
      end
    end
    
    -- Return to Normal mode after execution
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', true)
  end)
end, { desc = "Add/subtract days to dates in visual selection" })








local function decorate_line_with_equals()
  local line = vim.api.nvim_get_current_line()
  local prefix, sentence, suffix = line:match('^(=+)%s(.-)%s(=+)$')
  if prefix and suffix then
    prefix = prefix .. "="
    suffix = suffix .. "="
    line = prefix .. " " .. sentence .. " " .. suffix
  else
    line = "= " .. line .. " ="
  end
  vim.api.nvim_set_current_line(line)
end

local function reduce_equals_decoration()
  local line = vim.api.nvim_get_current_line()
  local prefix, sentence, suffix = line:match('^(=+)%s(.-)%s(=+)$')
  if prefix and suffix then
    if #prefix == 1 then
      -- Remove decoration entirely
      line = sentence
    else
      prefix = prefix:sub(1, -2) -- remove one '='
      suffix = suffix:sub(1, -2)
      line = prefix .. " " .. sentence .. " " .. suffix
    end
    vim.api.nvim_set_current_line(line)
  end
end

-- Helper function to insert text at cursor in normal or insert mode
local function insert_at_cursor(str)
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1,1) == 'i' then
    -- Insert mode: insert text directly
    vim.api.nvim_put({str}, 'c', true, true)
  else
    -- Normal mode: insert text after cursor
    vim.api.nvim_put({str}, 'c', true, false)
  end
end


-- Helper: decorate N times
local function decorate_n_times(n)
  for _ = 1, n do
    decorate_line_with_equals()
  end
end

for i = 1, 5 do
  vim.keymap.set('n', '<leader>;'..i, function() decorate_n_times(i) end, { noremap = true, silent = true, desc = "Decorate line with "..i.." =" })
end


vim.keymap.set('n', '=', decorate_line_with_equals, { noremap = true, silent = true })
vim.keymap.set('n', '-', reduce_equals_decoration, { noremap = true, silent = true })






vim.keymap.set('n', '<leader>;m', function()
  local buf = 0
  local row = vim.api.nvim_win_get_cursor(0)[1]

  -- Get the current line text
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]

  -- Duplicate current line below
  vim.api.nvim_buf_set_lines(buf, row, row, false, {line})

  -- Move cursor to first line and call decorate_n_times(5)
  vim.api.nvim_win_set_cursor(0, {row, 0})
  decorate_n_times(5)

  -- Get second line text, remove all whitespace
  local second_line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  second_line = second_line:gsub("%s+", "")
  -- Set cleaned second line back
  vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {second_line})

  -- Move cursor to second line and call create_link_from_path_under_cursor()
  vim.api.nvim_win_set_cursor(0, {row + 1, 0})
  create_link_from_path_under_cursor()
end)




-- Global flag and tables
local lsp_enabled = true
local attached_buffers_by_client = {}
local client_configs = {}

-- Store original buf_attach_client
local original_buf_attach_client = vim.lsp.buf_attach_client

local function add_buf(client_id, buf)
  attached_buffers_by_client[client_id] = attached_buffers_by_client[client_id] or {}
  if not vim.tbl_contains(attached_buffers_by_client[client_id], buf) then
    table.insert(attached_buffers_by_client[client_id], buf)
  end
end

vim.lsp.buf_attach_client = function(bufnr, client_id)
  if not lsp_enabled then
    local client = vim.lsp.get_client_by_id(client_id)
    if client then
      add_buf(client_id, bufnr)
      vim.lsp.stop_client(client_id)
    end
    return false
  end
  return original_buf_attach_client(bufnr, client_id)
end

local function stop_all_clients()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    for buf, _ in pairs(client.attached_buffers or {}) do
      add_buf(client.id, buf)
      vim.lsp.buf_detach_client(buf, client.id)
    end
    vim.lsp.stop_client(client.id)
  end
end

local function start_all_clients()
  for client_id, bufs in pairs(attached_buffers_by_client) do
    local cfg = client_configs[client_id]
    if cfg then
      local new_client_id = vim.lsp.start_client(cfg)
      for _, buf in ipairs(bufs) do
        original_buf_attach_client(buf, new_client_id)
      end
    end
  end
  attached_buffers_by_client = {}
  client_configs = {}
end

function _G.toggle_lsp_session()
  if lsp_enabled then
    stop_all_clients()
    lsp_enabled = false
    print("LSP disabled for this session")
  else
    start_all_clients()
    lsp_enabled = true
    print("LSP enabled for this session")
  end
end

vim.api.nvim_set_keymap('n', '<leader>tl', ':lua toggle_lsp_session()<CR>', { noremap = true, silent = true })




vim.keymap.set('n', '<leader>;s', function()
  local toc_lines = {}
  table.insert(toc_lines, "TOC")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i, line in ipairs(lines) do
    local leading_eqs = line:match("^(=+)")
    local trailing_eqs = line:match("(=+)$")
    if leading_eqs and trailing_eqs and #leading_eqs == #trailing_eqs then
      local content = line:sub(#leading_eqs + 1, #line - #trailing_eqs)
      -- Trim leading/trailing whitespace from content
      content = content:gsub("^%s*(.-)%s*$", "%1")
      local tabs = string.rep("\t", 7 - #leading_eqs) -- 6 tabs for one '=', 0 for six '='
      table.insert(toc_lines, tabs .. content)
    end
  end

  -- Insert the TOC at the current line
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.api.nvim_buf_set_lines(0, row, row, false, toc_lines)
end, { desc = 'Insert table of contents for = headings at cursor' })





vim.api.nvim_create_user_command("SS", function(opts)
  local dir = opts.args
  local stat = vim.loop.fs_stat(dir)
  if not stat or stat.type ~= "directory" then
    error("Directory does not exist: " .. dir)
  end

  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    error("Failed to scan directory: " .. dir)
  end

  local files = {}
  while true do
    local name, t = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if t == "file" then
      table.insert(files, name)
    end
  end

  if #files == 0 then
    error("No files found in directory: " .. dir)
  end

  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    error("No file is open in current buffer.")
  end

  local buf_dir = vim.fn.fnamemodify(buf_path, ":p:h")
  local base_name = vim.fn.fnamemodify(buf_path, ":t:r")
  local dest_dir = buf_dir .. "/" .. base_name

  -- Create destination directory if it doesn't exist
  local dstat = vim.loop.fs_stat(dest_dir)
  if not dstat then
    local ok, err = vim.loop.fs_mkdir(dest_dir, 493) -- 0755 permissions
    if not ok then
      error("Failed to create directory " .. dest_dir .. ": " .. (err or "unknown error"))
    end
  elseif dstat.type ~= "directory" then
    error(dest_dir .. " exists but is not a directory")
  end

  -- Move files and insert simplified references
  for _, fname in ipairs(files) do
    local src = dir .. "/" .. fname
    local dst = dest_dir .. "/" .. fname
    local ok, err = os.rename(src, dst)
    if not ok then
      error("Failed to move file " .. fname .. ": " .. (err or "unknown error"))
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row, row, false, {"[[./" .. fname .. "]]"})
    vim.api.nvim_win_set_cursor(0, {row + 1, 0})
  end
end, {
  nargs = 1,
  complete = "dir",
  desc = "Move top-level files into a subdirectory named after the current buffer file and insert simplified relative references"
})

vim.keymap.set("n", "<leader>;v", function()
  vim.api.nvim_feedkeys(":SS ~/Dow", "n", false)
end, {desc = "Pre-fill :SS ~/Dow in command line"})







-- Copy the file referenced under the cursor ([[...]] or {{...}}) to a given target directory.
-- Invocation: :CopyFileToDir <target_dir>
-- Example:    :CopyFileToDir ~/Down

local function CopyFileToDir(target_dir)
  local uv = vim.loop

  -- Validate and expand "~"
  if not target_dir or target_dir == "" then
    vim.notify("Target directory is required. Usage: :CopyFileToDir <target_dir>", vim.log.levels.ERROR)
    return
  end
  local dest_root = vim.fn.expand(target_dir)

  -- Cursor & current line context
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = col + 1 -- Lua strings are 1-based

  -- Patterns like the reference function
  local patterns = {
    { pattern = "%[%[(.-)%]%]" }, -- [[FILENAME]]
    { pattern = "%{%{(.-)%}%}" }, -- {{FILENAME}}
  }

  -- Ensure destination directory (mkdir -p)
  local function ensure_dir(path)
    local stat = uv.fs_stat(path)
    if stat and stat.type == "directory" then
      return true
    end
    -- Build progressively
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
      table.insert(parts, part)
    end
    local prefix = path:sub(1, 1) == "/" and "/" or ""
    local built = prefix
    for _, p in ipairs(parts) do
      built = (built == "/" and ("/" .. p)) or (built == "" and p) or (built .. "/" .. p)
      local s = uv.fs_stat(built)
      if not s then
        local ok, err = uv.fs_mkdir(built, 493) -- 0755
        if not ok then
          return false, err
        end
      elseif s.type ~= "directory" then
        return false, "Path component is not a directory: " .. built
      end
    end
    return true
  end

  -- Utilities
  local function path_basename(p)
    return vim.fn.fnamemodify(p, ":t") -- filename.ext
  end

  local function split_name_ext(name)
    local idx = name:match("^.*()%.")
    if idx then
      return name:sub(1, idx - 1), name:sub(idx)
    else
      return name, ""
    end
  end

  local function make_unique(dest_dir, leaf_name)
    local base, ext = split_name_ext(leaf_name)
    local candidate = dest_dir .. "/" .. leaf_name
    local n = 1
    while uv.fs_stat(candidate) do
      candidate = string.format("%s/%s(%d)%s", dest_dir, base, n, ext)
      n = n + 1
    end
    return candidate
  end

  local function copy_file(src, dst)
    if uv.fs_copyfile then
      local ok, err = uv.fs_copyfile(src, dst, { excl = true })
      if not ok then return false, err end
      return true
    end
    local in_f = io.open(src, "rb")
    if not in_f then return false, "Cannot open source: " .. src end
    local out_f, err = io.open(dst, "wb")
    if not out_f then
      in_f:close()
      return false, err or ("Cannot open destination: " .. dst)
    end
    local chunk = in_f:read(4096)
    while chunk do
      out_f:write(chunk)
      chunk = in_f:read(4096)
    end
    in_f:close()
    out_f:close()
    return true
  end

  -- Find the pattern under the cursor and act
  for _, pat in ipairs(patterns) do
    local search_start = 1
    while true do
      local s, e, fname = string.find(line, pat.pattern, search_start)
      if not s then break end

      if cursor_pos >= s and cursor_pos <= e then
        -- Current buffer context (matches reference behavior)
        local currfile = vim.api.nvim_buf_get_name(0)
        local currdir = vim.fn.fnamemodify(currfile, ":h")
        local name_no_ext = vim.fn.fnamemodify(currfile, ":t:r")

        -- Expand "./" or ".\"
        local expanded = fname
        if fname:sub(1, 2) == "./" or fname:sub(1, 2) == ".\\" then
          expanded = currdir .. "/" .. name_no_ext .. "/" .. fname:sub(3)
        end

        -- Normalize path separators
        expanded = expanded:gsub("\\", "/")

        -- Check source exists
        local sstat = uv.fs_stat(expanded)
        if not sstat or sstat.type ~= "file" then
          vim.notify("Source not found or not a regular file: " .. expanded, vim.log.levels.ERROR)
          return
        end

        -- Ensure destination directory
        local ok, err = ensure_dir(dest_root)
        if not ok then
          vim.notify("Failed to ensure destination dir: " .. (err or dest_root), vim.log.levels.ERROR)
          return
        end

        -- Compute destination path (unique)
        local leaf = path_basename(expanded)
        local dest = make_unique(dest_root, leaf)

        -- Copy
        local ok2, err2 = copy_file(expanded, dest)
        if ok2 then
          vim.notify("Copied to: " .. dest, vim.log.levels.INFO)
        else
          vim.notify("Failed to copy: " .. (err2 or expanded), vim.log.levels.ERROR)
        end

        return
      end

      search_start = e + 1
    end
  end

  vim.notify("No [[FILENAME]] or {{FILENAME}} under cursor", vim.log.levels.ERROR)
end

-- Register the user command: :CopyFileToDir <target_dir>
vim.api.nvim_create_user_command(
  "CopyFileToDir",
  function(opts)
    CopyFileToDir(opts.args)
  end,
  {
    nargs = 1,           -- require exactly one argument (the target directory)
    complete = "file",   -- path-like completion in the command-line
    desc = "Copy the file referenced under cursor ([[...]] or {{...}}) to the given target directory",
  }
)

vim.keymap.set('n', '<leader>;w', ':CopyFileToDir ~/Down', { noremap = true })






local function Gcal(arg)
    local target_dates = {}

    -- 1. Determine target dates
    if arg and arg ~= "" then
        table.insert(target_dates, arg)
    else
        local today = os.date("%Y-%m-%d")
        local tomorrow = os.date("%Y-%m-%d", os.time() + 24 * 60 * 60)
        table.insert(target_dates, today)
        table.insert(target_dates, tomorrow)
    end

    -- 2. Construct Regex for rg/grep
    local date_pattern = table.concat(target_dates, "|")
    local rg_pattern = [[\[ \].*<]] .. "(" .. date_pattern .. ")"
    
    local grep_cmd
    if vim.fn.executable("rg") == 1 then
        grep_cmd = "rg --type-add 'txt:*.txt' --type txt -n -e '" .. rg_pattern .. "' --no-heading"
    else
        grep_cmd = "grep -r -n -E '" .. [[\[ \].*<]] .. "(" .. date_pattern .. ")" .. "' --include='*.txt' ."
    end

    -- 3. Run Grep
    local handle = io.popen(grep_cmd)
    if not handle then return end
    local result = handle:read("*a")
    handle:close()

    -- 4. Group tasks by date
    local tasks_by_date = {}
    for _, d in ipairs(target_dates) do tasks_by_date[d] = {} end

    for line in result:gmatch("[^\r\n]+") do
        local text = line:match("^[^:]+:%d+:(.*)$")
        if text then
            local task = text:match("%[ %]%s*(.-)%s*<")
            local date = text:match("<(%d%d%d%d%-%d%d%-%d%d)")
            if task and date and tasks_by_date[date] then
                table.insert(tasks_by_date[date], task)
            end
        end
    end

    -- 5. Helper to parse time from task string (format "TIME am/pm:")
    local function parse_task_time(task_str)
        local h, m, p = task_str:match("^(%d+):?(%d*)%s*([ap]m):")
        if not h then return nil end
        
        local hour = tonumber(h)
        local min = tonumber(m) or 0
        local period = p:lower()

        if period == "pm" and hour < 12 then hour = hour + 12 end
        if period == "am" and hour == 12 then hour = 0 end
        
        return string.format("%02d:%02d", hour, min)
    end

    -- 6. Iterate through each date and reset the clock
    local sorted_dates = {}
    for d in pairs(tasks_by_date) do table.insert(sorted_dates, d) end
    table.sort(sorted_dates)

    for _, date in ipairs(sorted_dates) do
        local current_hour = 9
        local current_min = 0
        local tasks = tasks_by_date[date]

        for _, task_name in ipairs(tasks) do
            local specified_time = parse_task_time(task_name)
            local time_to_use

            if specified_time then
                time_to_use = specified_time
            else
                time_to_use = string.format("%02d:%02d", current_hour, current_min)
                -- Only increment the default 09:00 clock for untimed tasks
                current_min = current_min + 30
                if current_min >= 60 then
                    current_min = 0
                    current_hour = current_hour + 1
                end
            end
            
            local cmd = string.format(
                'gcalcli --calendar "pyrominsoo@gmail.com" add --title "%s" --when "%s %s" --duration 30 --description "" --where "" --remind 10',
                task_name:gsub('"', '\\"'),
                date,
                time_to_use
            )

            vim.notify(string.format("Adding: [%s] %s at %s", date, task_name, time_to_use))
            
            local out = vim.fn.system(cmd)
            if vim.v.shell_error ~= 0 then
                vim.notify("Gcal Error: " .. out, vim.log.levels.ERROR)
            end
        end
    end
    
    vim.notify("Gcal sync complete.", vim.log.levels.INFO)
end

-- Create the User Command
vim.api.nvim_create_user_command('Gcal', function(opts)
    Gcal(opts.args)
end, { nargs = '?' })




local function GcalCurrentLine()
    -- 1. Grab the specific line under the cursor
    local line = vim.api.nvim_get_current_line()
    
    -- 2. Extract Task and Date
    -- task_name: matches everything between '[ ]' and the '<'
    -- date: matches the YYYY-MM-DD immediately following the '<'
    local task_name = line:match("%[ %]%s*(.-)%s*<")
    local date = line:match("<(%d%d%d%d%-%d%d%-%d%d)")

    if not task_name or not date then
        vim.notify("GcalLine: Could not find '[ ]' or '<YYYY-MM-DD' on this line.", vim.log.levels.WARN)
        return
    end

    -- 3. Internal helper to parse time (e.g., "10:30 am:")
    local function parse_task_time(task_str)
        local h, m, p = task_str:match("^(%d+):?(%d*)%s*([ap]m):")
        if not h then return nil end
        
        local hour = tonumber(h)
        local min = tonumber(m) or 0
        local period = p:lower()

        if period == "pm" and hour < 12 then hour = hour + 12 end
        if period == "am" and hour == 12 then hour = 0 end
        
        return string.format("%02d:%02d", hour, min)
    end

    -- 4. Determine time (Parsed time or default 09:00)
    local specified_time = parse_task_time(task_name)
    local time_to_use = specified_time or "09:00"

    -- 5. Construct and run the gcalcli command
    local cmd = string.format(
        'gcalcli --calendar "pyrominsoo@gmail.com" add --title "%s" --when "%s %s" --duration 30 --description "" --where "" --remind 10',
        task_name:gsub('"', '\\"'),
        date,
        time_to_use
    )

    vim.notify(string.format("Syncing: %s at %s", task_name, time_to_use))
    
    local out = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
        -- Clean up error message for the notify window
        vim.notify("Gcal Error: " .. out:gsub("\n", " "), vim.log.levels.ERROR)
    else
        vim.notify("Successfully added to Calendar.", vim.log.levels.INFO)
    end
end

-- Unique User Command
vim.api.nvim_create_user_command('GcalLine', GcalCurrentLine, {})

vim.keymap.set('n', '<leader>;c', ':GcalLine<CR>', { desc = 'Sync current line to Google Calendar' })
