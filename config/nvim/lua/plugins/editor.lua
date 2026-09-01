return {
  -- File explorer (replaces NERDTree). <C-n> keeps the old toggle mapping.
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<leader>fe", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in explorer" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true, -- the old NERDTreeShowHidden = 1
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", ".bundle", "node_modules" },
        },
      },
      window = { width = 32 },
    },
  },

  -- Fuzzy finder (replaces ctrlp.vim, ack.vim and the fzf.vim wiring)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
    },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { preview_width = 0.6 },
        file_ignore_patterns = { "^.git/", "node_modules/", "^target/", "^tmp/", "^log/" },
      },
      pickers = { find_files = { hidden = true } },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Git signs in the gutter (replaces vim-gitgutter)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Previous hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  -- Git commands (replaces vim-fugitive; fugitive itself is still fine, this is
  -- the same author's modern companion set kept for :Git)
  { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gblame" } },

  -- Commenting (replaces nerdcommenter; Neovim ships built-in gc since 0.10,
  -- this only adds context-aware commenting for embedded languages like JSX)
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
      vim.g.skip_ts_context_commentstring_module = true
    end,
  },

  -- Surround (replaces vim-surround)
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- Auto-pairs (replaces auto-pairs)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true, fast_wrap = {} },
  },

  -- Auto-close `end` in Ruby, Lua, Elixir. nvim-treesitter-endwise still calls
  -- require('nvim-treesitter').define_modules, which the treesitter main-branch
  -- rewrite removed, so this stays on tpope's original.
  { "tpope/vim-endwise", event = "InsertEnter" },

  -- Jump anywhere (replaces vim-easymotion)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- Multiple cursors (replaces vim-multiple-cursors, which is unmaintained)
  { "mg979/vim-visual-multi", event = "VeryLazy", init = function() vim.g.VM_maps = { ["Find Under"] = "<C-d>" } end },

  -- Project-wide search and replace (replaces ack.vim's workflow)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = { { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and replace in project" } },
  },

  -- Emmet for HTML/CSS/JSX (replaces emmet-vim)
  {
    "olrtg/nvim-emmet",
    ft = { "html", "css", "scss", "javascriptreact", "typescriptreact", "eruby", "slim" },
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>ce", require("nvim-emmet").wrap_with_abbreviation, {
        desc = "Emmet: wrap with abbreviation",
      })
    end,
  },
}
