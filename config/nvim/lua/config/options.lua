local opt = vim.opt

-- Appearance
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorcolumn = true -- kept from the old vimrc: helps with indentation-based markup
opt.colorcolumn = "80"
opt.showmode = false -- lualine already shows it
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣", extends = "→", precedes = "←" }
opt.fillchars = { eob = " " }
opt.scrolloff = 4
opt.sidescrolloff = 8

-- Indentation: 2 spaces, as before
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split" -- live preview for :s

-- Folding (treesitter-driven, but everything starts open)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Files
opt.hidden = true
opt.autoread = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undolevels = 10000

-- Behaviour
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.updatetime = 200
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.wrap = false
opt.showmatch = true
opt.history = 1000

-- Grep with ripgrep
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

opt.wildignore:append({ "*/node_modules/*", "*/target/*", "*/log/*", "*/tmp/*", "*/.bundle/*" })

-- Diagnostics
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})
