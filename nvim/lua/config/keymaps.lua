-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
-- Add this date insertion keymap
vim.keymap.set("i", "<leader>dt", function()
  return os.date("%Y-%m-%d")
end, { expr = true, desc = "Insert current date" })
