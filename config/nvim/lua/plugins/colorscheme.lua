-- Replaces vim-solarized8 / morhetz-gruvbox. gruvbox.nvim is the Lua rewrite
-- with treesitter and LSP highlight support.
return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      contrast = "hard", -- matches the old g:gruvbox_contrast_dark = 'hard'
      transparent_mode = false,
      italic = { strings = false, comments = true },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")
    end,
  },
}
