return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opt = {},
    config = function()
      require("tokyonight").setup({
        style = "moon",
        transparent = true,
        terminal_colors = true,
        -- 左侧目录树、悬浮窗口背景透明
        on_highlights = function(highlights, colors)
          highlights["NormalNC"] = { bg = "none" }
          highlights["NormalFloat"] = { bg = "none" }
        end,
        on_colors = function(colors)
          -- 状态栏背景透明
          colors.bg_statusline = colors.none -- To check if its working try something like "#ff00ff" instead of colors.none
          -- 右侧栏背景透明
          colors.bg_sidebar = colors.none
        end,
      })
    end,
  },

  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
    end,
  },

  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    config = function()
      require("dracula").setup({
        -- use transparent background
        -- 背景透明支持的不好，边栏、悬浮窗等背景无法透明.
        transparent_bg = true, -- default false
        -- show the '~' characters after the end of buffers
        show_end_of_buffer = true, -- default false
      })
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = true, -- shows the '~' characters after the end of buffers
        term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
      })
    end,
  },
}
