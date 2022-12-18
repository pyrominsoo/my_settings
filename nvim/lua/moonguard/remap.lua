-- From Primeagen
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("n", "q", "<nop>")
vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- My own
vim.keymap.set("i", "<S-Tab>", "<C-V><Tab>")
vim.keymap.set("i", "jj", "<esc>")

vim.keymap.set("n", "<leader>wf", "<Plug>Vimwiki2HTML")
vim.keymap.set("n", "<leader>wff", "<Plug>Vimwiki2HTMLBrowse")

vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

vim.keymap.set("n", "<leader>wj", "<C-w>j")
vim.keymap.set("n", "<leader>wk", "<C-w>k")
vim.keymap.set("n", "<leader>wh", "<C-w>h")
vim.keymap.set("n", "<leader>wl", "<C-w>l")

vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "<leader>k", "<C-u>")
vim.keymap.set("n", "<leader>j", "<C-d>")

vim.keymap.set("n", "<leader>q", ":q<cr>")

vim.keymap.set("n", "<leader>n", ":set number! relativenumber!<cr>")

vim.keymap.set("n", "<leader>/", ":nohlsearch<cr>", { silent = true })

vim.keymap.set("n", "gy", ":let @l = join([expand('%'), line('.')], ':')<cr>")
vim.keymap.set("n", "gp", [["lp]])

vim.keymap.set("n", "<leader>ws", [[:vsplit<CR>]])

vim.keymap.set("n", "<F4>", ":lw<CR>")
vim.cmd('source ~/.config/nvim/f5.vim')
vim.keymap.set("n", "<F6>", ":cd ..<CR> :pwd<CR>")
vim.keymap.set("n", "<F7>", ":cd %:p:h<CR> :pwd<CR>")
vim.keymap.set("n", "<F8>", ":set invpaste paste?<CR>")
vim.keymap.set("n", "<F9>", ":TagbarToggle<CR>")

vim.keymap.set("n", "<leader>pr", ":lgrep!<Space>")
vim.keymap.set("n", "[f", ":lprevious<CR>")
vim.keymap.set("n", "]f", ":lnext<CR>")
