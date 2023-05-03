return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        tsserver = {},
        jsonls = {},
      },
    },
  },
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "html", "css", "javascript", "json" })
      end
    end,
  },
}
