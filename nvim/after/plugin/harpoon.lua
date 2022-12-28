local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>af", mark.add_file)
vim.keymap.set("n", "<leader>ae", ui.toggle_quick_menu)

vim.keymap.set("n", "<leader>aj", function() ui.nav_next() end)
vim.keymap.set("n", "<leader>ak", function() ui.nav_prev() end)
