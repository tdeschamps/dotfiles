-- Neovim configuration entry point.
-- Layout:
--   lua/config/*   editor settings, keymaps, autocmds, lazy.nvim bootstrap
--   lua/plugins/*  one file per plugin group, auto-imported by lazy.nvim

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
