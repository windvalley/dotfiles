return {
  {
    "ibhagwan/fzf-lua",
    -- doc: https://github.com/ibhagwan/fzf-lua
    opts = function(_, opts)
      opts.previewers = {
        builtin = {
          syntax = true, -- preview syntax highlight?
          syntax_limit_l = 0, -- syntax limit (lines), 0=nolimit
          syntax_limit_b = 1024 * 1024, -- syntax limit (bytes), 0=nolimit
          limit_b = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
          -- previewer treesitter options:
          -- enable specific filetypes with: `{ enabled = { "lua" } }
          -- exclude specific filetypes with: `{ disabled = { "lua" } }
          -- disable `nvim-treesitter-context` with `context = false`
          -- disable fully with: `treesitter = false` or `{ enabled = false }`
          treesitter = {
            enabled = true,
            disabled = {},
            -- nvim-treesitter-context config options
            context = { max_lines = 1, trim_scope = "inner" },
          },
          -- By default, the main window dimensions are calculated as if the
          -- preview is visible, when hidden the main window will extend to
          -- full size. Set the below to "extend" to prevent the main window
          -- from being modified when toggling the preview.
          toggle_behavior = "default",
          -- Title transform function, by default only displays the tail
          -- title_fnamemodify = function(s) vim.fn.fnamemodify(s, ":t") end,
          -- preview extensions using a custom shell command:
          -- for example, use `viu` for image previews
          -- will do nothing if `viu` isn't executable
          extensions = {
            -- neovim terminal only supports `viu` block output
            ["png"] = { "viu", "-b" },
            -- by default the filename is added as last argument
            -- if required, use `{file}` for argument positioning
            ["svg"] = { "chafa", "{file}" },
            ["jpg"] = { "viu", "-b" },
          },
          -- if using `ueberzug` in the above extensions map
          -- set the default image scaler, possible scalers:
          --   false (none), "crop", "distort", "fit_contain",
          --   "contain", "forced_cover", "cover"
          -- https://github.com/seebye/ueberzug
          ueberzug_scaler = "cover",
          -- Custom filetype autocmds aren't triggered on
          -- the preview buffer, define them here instead
          -- ext_ft_override = { ["ksql"] = "sql", ... },
          -- render_markdown.nvim integration, enabled by default for markdown
          render_markdown = { enabled = true, filetypes = { ["markdown"] = true } },
        },
      }

      opts.winopts = {
        preview = {
          border = "rounded",
        },
      }
    end,
  },
}
