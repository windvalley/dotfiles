return {
  {
    -- Mange LSP, DAP, Linter, Formatter
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- ****** formatter *****
        "stylua", -- default
        "shfmt", -- default
        "beautysh", -- for zsh
        -- "isort", -- for python import 合理自动分组, 会和ruff冲突，导致格式化错误，暂时注释
        "goimports-reviser", -- Go import 合理自动分组
        -- "golines",
        -- "impl", -- for go
        -- "gomodifytags",
        -- "clang-format",
        -- "sql-formatter",
        -- "standardjs",
        -- "yamlfix",
        --
        -- --- ****** linter *****
        -- "shellcheck",
        -- "golangci-lint",
        -- "nilaway", -- for go
        -- "cpplint",
        -- "gitlint",
        -- "yamllint",
        -- "stylelint", -- for css, sass, scss, less
        --
        -- --- ****** LSP *****
        -- "clangd",
        -- "gopls",
        -- "golangci-lint-langserver",
        -- "python-lsp-server",
        -- "bash-language-server",
        -- "awk-language-server",
        -- "dockerfile-language-server",
        -- "json-lsp",
        -- "markdown-oxide", -- or remark-language-server
        -- "vetur-vls", -- for vue
        -- "vue-language-server",
        -- "eslint-lsp",
        -- "yaml-language-server",
      },
    },
  },
}
