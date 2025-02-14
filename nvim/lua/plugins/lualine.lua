return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          return "󰘦 " .. vim.api.nvim_call_function("codeium#GetStatusString", {})
        end,
      })
    end,
  },
}
