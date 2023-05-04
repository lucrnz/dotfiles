return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        hls = {},
      },
    },
  },
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "haskell" })
      end
    end,
  },
}
