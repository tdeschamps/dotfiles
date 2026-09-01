-- Treesitter gives syntax highlighting, indentation and text objects for every
-- language the old config pulled a separate plugin for (vim-ruby, vim-rails,
-- vim-go, vim-elixir, vim-javascript, vim-jsx, vim-jsx-typescript, rust.vim,
-- vim-slim, vim-fish).
--
-- This targets the `main` branch, which is a full rewrite requiring Neovim
-- 0.12+. It installs parsers and queries only: highlighting, folding and
-- indentation come from Neovim itself and have to be switched on per buffer.

local languages = {
  "bash",
  "css",
  "diff",
  "dockerfile",
  "eex",
  "elixir",
  "embedded_template",
  "fish",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "heex",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "ruby",
  "rust",
  "scss",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- the main branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Asynchronous; a no-op for parsers that are already installed.
      require("nvim-treesitter").install(languages)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true }),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
          if not lang or not pcall(vim.treesitter.language.add, lang) then
            return
          end

          -- Highlighting
          pcall(vim.treesitter.start, event.buf, lang)

          -- Indentation (marked experimental upstream)
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          -- Folding, left fully open (see foldlevelstart in options.lua)
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = { ["@function.outer"] = "V" },
        },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      local textobjects = {
        ["f"] = "function",
        ["c"] = "class",
        ["a"] = "parameter",
      }

      for key, name in pairs(textobjects) do
        vim.keymap.set({ "x", "o" }, "a" .. key, function()
          select.select_textobject("@" .. name .. ".outer", "textobjects")
        end, { desc = "Select outer " .. name })

        vim.keymap.set({ "x", "o" }, "i" .. key, function()
          select.select_textobject("@" .. name .. ".inner", "textobjects")
        end, { desc = "Select inner " .. name })
      end

      for key, name in pairs({ f = "function", c = "class" }) do
        vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
          move.goto_next_start("@" .. name .. ".outer", "textobjects")
        end, { desc = "Next " .. name .. " start" })

        vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
          move.goto_previous_start("@" .. name .. ".outer", "textobjects")
        end, { desc = "Previous " .. name .. " start" })
      end
    end,
  },
}
