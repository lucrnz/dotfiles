return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(
          opts.ensure_installed,
          { "git_config", "gitignore", "git_rebase", "gitcommit", "gitattributes" }
        )
      end
    end,
  },
}
