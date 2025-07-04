
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

-- Map <leader>h1 to <leader>h5
for i = 1, 5 do
  local eqs = string.rep("=", i)
  local str = eqs .. " temp " .. eqs
  vim.keymap.set({'n', 'i'}, "<leader>h" .. i, function() insert_at_cursor(str) end, { noremap = true, silent = true, desc = "Insert " .. str })
end

vim.keymap.set('n', '=', decorate_line_with_equals, { noremap = true, silent = true })
vim.keymap.set('n', '-', reduce_equals_decoration, { noremap = true, silent = true })

