local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>ps', builtin.git_files, {})
vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>pt', builtin.tags, {})
vim.keymap.set('n', '<leader>ph', builtin.help_tags, {})
vim.keymap.set('n', '<leader>pb', builtin.buffers, {})
vim.keymap.set('n', '<leader>po', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>pc', builtin.commands, {})
vim.keymap.set('n', '<leader>pm', builtin.man_pages, {})
vim.keymap.set('n', '<leader>pj', builtin.jumplist, {})
vim.keymap.set('n', '<leader>pl', builtin.loclist, {})
vim.keymap.set('n', '<leader>pz', builtin.colorscheme, {})
vim.keymap.set('n', '<leader>pq', builtin.quickfixhistory, {})
vim.keymap.set('n', '<leader>pr', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

