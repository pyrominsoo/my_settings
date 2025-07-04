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
    local str = [[grep! "TODO .*<]] .. base .. [["]]
    vim.cmd(str)
    str = [[grepa! "\[ \] .*]] .. base .. [["]]
    vim.cmd(str)
    vim.cmd("cw")
end

function SearchTomo()
    local timeshift = 24 * 60 * 60
    local base = os.date('%Y-%m-%d', os.time() + timeshift)
    local str = [[grep! "TODO .*<]] .. base .. [["]]
    vim.cmd(str)
    str = [[grepa! "\[ \] .*]] .. base .. [["]]
    vim.cmd(str)
    vim.cmd("cw")
end

function SearchNodate()
    local str = [[grep! "TODO .*"]]
    vim.cmd(str)
    str = [[grepa! "\[ \] .*"]]
    vim.cmd(str)
    str = [[grepa! "TONO .*"]]
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

