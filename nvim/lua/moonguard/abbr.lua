vim.cmd('iab <expr> dts strftime("%F")')

vim.api.nvim_create_user_command("Attach", function(opts)
  local src = vim.fn.expand(opts.args) -- Accept full path, expand ~ etc.
  if src == "" then
    vim.notify("No source file path provided!", vim.log.levels.ERROR)
    return
  end

  -- Get the filename from the path
  local filename = vim.fn.fnamemodify(src, ":t")

  -- Destination: $CURR_DIR/$SUBDIR/filename
  local curr_file_noext = vim.fn.expand("%:t:r") -- current file name without extension
  local curr_dir = vim.fn.expand("%:p:h") -- directory of current file
  local dst_dir = curr_dir .. "/" .. curr_file_noext
  local dst = dst_dir .. "/" .. filename

  -- Check if source file exists
  if vim.fn.filereadable(src) == 0 then
    vim.notify("Source file does not exist: " .. src, vim.log.levels.ERROR)
    return
  end

  -- Ensure destination directory exists
  vim.fn.mkdir(dst_dir, "p")

  -- Check if destination file already exists
  if vim.fn.filereadable(dst) ~= 0 then
    vim.notify("A file named '" .. filename .. "' already exists in the destination directory (" .. dst_dir .. "). Attach aborted.", vim.log.levels.WARN)
    return
  end

  -- Move file using os.execute
  local ok = os.execute(string.format('mv "%s" "%s"', src, dst))
  if not ok then
    vim.notify("Failed to move file.", vim.log.levels.ERROR)
    return
  end

  -- Insert at cursor: [[./filename]]
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local insert_str = string.format("[[./%s]]", filename)
  local new_line = line:sub(1, col) .. insert_str .. line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, {row, col + #insert_str})

  vim.notify("Moved " .. filename .. " to " .. dst_dir .. " and inserted link.", vim.log.levels.INFO)
end, {
  nargs = 1,
  complete = "file",
  desc = "Move file from given path to $CURR_DIR/$SUBDIR and insert link as [[./filename]], abort if file exists"
})


vim.api.nvim_create_user_command("Bttach", function(opts)
  local src = vim.fn.expand(opts.args) -- Accept full path, expand ~ etc.
  if src == "" then
    vim.notify("No source file path provided!", vim.log.levels.ERROR)
    return
  end

  -- Get the filename and extension from the path
  local filename = vim.fn.fnamemodify(src, ":t")
  local name_noext = vim.fn.fnamemodify(filename, ":r")
  local ext = vim.fn.fnamemodify(filename, ":e")

  -- Destination: $CURR_DIR/$SUBDIR/filename
  local curr_file_noext = vim.fn.expand("%:t:r") -- current file name without extension
  local curr_dir = vim.fn.expand("%:p:h") -- directory of current file
  local dst_dir = curr_dir .. "/" .. curr_file_noext

  -- Ensure destination directory exists
  vim.fn.mkdir(dst_dir, "p")

  -- Find the next available filename
  local dst = dst_dir .. "/" .. filename
  local final_filename = filename
  if vim.fn.filereadable(dst) ~= 0 then
    local i = 1
    while true do
      local candidate = string.format("%s_%d.%s", name_noext, i, ext)
      local candidate_path = dst_dir .. "/" .. candidate
      if vim.fn.filereadable(candidate_path) == 0 then
        dst = candidate_path
        final_filename = candidate
        break
      end
      i = i + 1
    end
    vim.notify(string.format(
      "File '%s' exists. Moving as '%s' instead.", filename, final_filename
    ), vim.log.levels.WARN)
  end

  -- Check if source file exists
  if vim.fn.filereadable(src) == 0 then
    vim.notify("Source file does not exist: " .. src, vim.log.levels.ERROR)
    return
  end

  -- Move file using os.execute
  local ok = os.execute(string.format('mv "%s" "%s"', src, dst))
  if not ok then
    vim.notify("Failed to move file.", vim.log.levels.ERROR)
    return
  end

  -- Insert at cursor: [[./final_filename]]
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local insert_str = string.format("[[./%s]]", final_filename)
  local new_line = line:sub(1, col) .. insert_str .. line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, {row, col + #insert_str})

  vim.notify(string.format(
    "Moved '%s' to '%s' and inserted link as [[./%s]].",
    filename, dst_dir, final_filename
  ), vim.log.levels.INFO)
end, {
  nargs = 1,
  complete = "file",
  desc = "Move file from given path to $CURR_DIR/$SUBDIR and insert link as [[./filename]] or [[./filename_N.ext]]"
})


vim.api.nvim_create_user_command("Cttach", function(opts)
  local src = vim.fn.expand(opts.args) -- Accept full path, expand ~ etc.
  if src == "" then
    vim.notify("No source file path provided!", vim.log.levels.ERROR)
    return
  end

  -- Get the filename and extension from the path
  local filename = vim.fn.fnamemodify(src, ":t")
  local name_noext = vim.fn.fnamemodify(filename, ":r")
  local ext = vim.fn.fnamemodify(filename, ":e")

  -- Destination: $CURR_DIR/$SUBDIR/filename
  local curr_file_noext = vim.fn.expand("%:t:r") -- current file name without extension
  local curr_dir = vim.fn.expand("%:p:h") -- directory of current file
  local dst_dir = curr_dir .. "/" .. curr_file_noext

  -- Ensure destination directory exists
  vim.fn.mkdir(dst_dir, "p")

  -- Find the next available filename
  local dst = dst_dir .. "/" .. filename
  local final_filename = filename
  if vim.fn.filereadable(dst) ~= 0 then
    local i = 1
    while true do
      local candidate = string.format("%s_%d.%s", name_noext, i, ext)
      local candidate_path = dst_dir .. "/" .. candidate
      if vim.fn.filereadable(candidate_path) == 0 then
        dst = candidate_path
        final_filename = candidate
        break
      end
      i = i + 1
    end
    vim.notify(string.format(
      "File '%s' exists. Copying as '%s' instead.", filename, final_filename
    ), vim.log.levels.WARN)
  end

  -- Check if source file exists
  if vim.fn.filereadable(src) == 0 then
    vim.notify("Source file does not exist: " .. src, vim.log.levels.ERROR)
    return
  end

  -- Copy file using os.execute
  local ok = os.execute(string.format('cp "%s" "%s"', src, dst))
  if not ok then
    vim.notify("Failed to copy file.", vim.log.levels.ERROR)
    return
  end

  -- Insert at cursor: [[./final_filename]]
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local insert_str = string.format("[[./%s]]", final_filename)
  local new_line = line:sub(1, col) .. insert_str .. line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, {row, col + #insert_str})

  vim.notify(string.format(
    "Copied '%s' to '%s' and inserted link as [[./%s]].",
    filename, dst_dir, final_filename
  ), vim.log.levels.INFO)
end, {
  nargs = 1,
  complete = "file",
  desc = "Copy file from given path to $CURR_DIR/$SUBDIR and insert link as [[./filename]] or [[./filename_N.ext]]"
})

vim.keymap.set('n', '<leader>;a', ':Attach ', { noremap = true })
vim.keymap.set('n', '<leader>;b', ':Bttach ', { noremap = true })
vim.keymap.set('n', '<leader>;c', ':Cttach ', { noremap = true })

