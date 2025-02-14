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
        "black", -- for python
        "isort", -- for python
        "clang-format",
        "goimports",
        "goimports-reviser",
        "golines",
        "gomodifytags",
        "markdownlint-cli2",
        "sql-formatter",
        "standardjs",
        "yamlfix",

        --- ****** linter *****
        "shellcheck",
        "golangci-lint",
        "nilaway", -- for go
        "cpplint",
        "gitlint",
        "yamllint",
        "stylelint", -- for css, sass, scss, less

        --- ****** LSP *****
        "clangd",
        "gopls",
        "golangci-lint-langserver",
        "python-lsp-server",
        "bash-language-server",
        "awk-language-server",
        "dockerfile-language-server",
        "json-lsp",
        "markdown-oxide", -- or remark-language-server
        "vetur-vls", -- for vue
        "vue-language-server",
        "eslint-lsp",
        "yaml-language-server",
      },
    },
  },
}
