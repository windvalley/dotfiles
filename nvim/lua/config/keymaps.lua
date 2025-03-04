-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 插入模式下使用 Ctrl + k/j/h/l 上下左右移动光标, 使用Ctrl+a/e移动到行首或行尾
vim.keymap.set("i", "<C-k>", "<Up>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-j>", "<Down>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-h>", "<Left>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-l>", "<Right>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-a>", "<Home>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-e>", "<End>", { noremap = true, silent = true })

-- 插件Exafunction/codeium.vim快捷键配置
--
-- 接受提示的代码
vim.keymap.set("i", "<Tab>", function()
  return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true })
-- 下一个代码提示
vim.keymap.set("i", "<C-f>", function()
  return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true })
-- 上一个代码提示
vim.keymap.set("i", "<C-b>", function()
  return vim.fn["codeium#CycleCompletions"](-1)
end, { expr = true, silent = true })
-- 清除代码提示
vim.keymap.set("i", "<C-c>", function()
  return vim.fn["codeium#Clear"]()
end, { expr = true, silent = true })
-- 手动触发代码提示
vim.keymap.set("i", "<C-t>", function()
  return vim.fn["codeium#Complete"]()
end, { expr = true, silent = true })
