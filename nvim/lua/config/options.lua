-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable line wrapping by default.
vim.wo.wrap = true

-- For lua/plugins/avante.lua GPT API KEY.
-- NOTE: 不建议在这里配置 API KEY，建议在 ~/.zshrc.private 中配置, 比如：export DEEPSEEK_API_KEY=""
-- vim.env.DEEPSEEK_API_KEY = ""
-- vim.env.SILICONFLOW_API_KEY = ""
-- vim.env.OPENAI_API_KEY = ""
