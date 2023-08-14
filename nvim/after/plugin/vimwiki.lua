
vim.cmd.hi([[VimwikiHeader1 guifg=#FF0000]])
vim.cmd.hi([[VimwikiHeader2 guifg=#FF00FF]])
vim.cmd.hi([[VimwikiHeader3 guifg=#FFFF00]])
vim.cmd.hi([[VimwikiHeader4 guifg=#00FF00]])
vim.cmd.hi([[VimwikiHeader5 guifg=#00FFFF]])
vim.cmd.hi([[VimwikiHeader6 guifg=#0000FF]])

function FormatForZim()
    vim.cmd([[silent! %s/^===== \(.\+\) =====/FORMATFORZIM= \1 =/]])
    vim.cmd([[silent! %s/^==== \(.\+\) ====/FORMATFORZIM== \1 ==/]])
    vim.cmd([[silent! %s/^== \(.\+\) ==/FORMATFORZIM==== \1 ====/]])
    vim.cmd([[silent! %s/^= \(.\+\) =/FORMATFORZIM===== \1 =====/]])
    vim.cmd("silent! %s/DONE/FORMATFORZIM[*]/")
    vim.cmd("silent! %s/PONE/FORMATFORZIM[*]/")
    vim.cmd("silent! %s/TODO/FORMATFORZIM[ ]/")
    vim.cmd("silent! %s/^\\[\\*\\]/DONE")
    vim.cmd("silent! %s/^\\[ \\]/TODO")
    vim.cmd("silent! %s/\\s\\[\\*\\]/DONE")
    vim.cmd("silent! %s/\\s\\[ \\]/TODO")
    vim.cmd([[silent! %s/FORMATFORZIM//]])
end

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

local Moonguard_Vimwiki = vim.api.nvim_create_augroup("Moonguard_Vimwiki", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd({"BufEnter", "BufWinEnter"}, {
    group = Moonguard_Vimwiki,
    pattern = "*.wiki",
    callback = function()
        vim.keymap.set("n", "<leader>wt", vim.cmd.VimwikiTOC)
        vim.keymap.set("n", "<leader>wz", FormatForZim)

        vim.keymap.set("n", "<leader>td", SearchToday)
        vim.keymap.set("n", "<leader>tm", SearchTomo)
        vim.keymap.set("n", "<leader>tn", SearchNodate)
    end,
})


