local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>aa", mark.add_file)
vim.keymap.set("n", "<leader>ae", ui.toggle_quick_menu)

vim.keymap.set("n", "<leader>ah", function() ui.nav_file(1) end)
vim.keymap.set("n", "<leader>as", function() ui.nav_file(2) end)
vim.keymap.set("n", "<leader>at", function() ui.nav_file(3) end)
