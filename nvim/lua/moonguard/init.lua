require("moonguard.set")
require("moonguard.remap")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local MoonguardGroup = augroup('Moonguard', {})
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

autocmd({"BufWritePre"}, {
    group = MoonguardGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.cmd(':autocmd FileType qf wincmd J')
vim.cmd('source ~/.config/nvim/netrw_mapping.vim')
vim.cmd('source ~/.config/nvim/gdb.vim')

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

-- disable autocomment
vim.cmd([[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]])
