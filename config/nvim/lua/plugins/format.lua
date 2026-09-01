-- conform.nvim + nvim-lint replace ALE. The formatter list mirrors the old
-- g:ale_fixers, and format-on-save keeps g:ale_fix_on_save = 1 behaviour.
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        css = { "prettier" },
        elixir = { "mix" },
        fish = { "fish_indent" },
        go = { "goimports", "gofmt" },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "ruff_format", "ruff_organize_imports" },
        ruby = { "rubocop" },
        rust = { "rustfmt" },
        scss = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function(bufnr)
        -- Let `:noautocmd w` and a buffer-local flag opt out.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "Disable format on save (! for current buffer only)", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Re-enable format on save" })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        ruby = { "rubocop" },
        python = { "ruff" },
        fish = { "fish" },
        markdown = { "markdownlint" },
      }

      -- nvim-lint raises ENOENT when a linter is not installed, which is
      -- noisy on machines that only have some of these. Run the ones present.
      local function lint_buffer()
        local names = lint.linters_by_ft[vim.bo.filetype]
        if not names then
          return
        end

        local available = {}
        for _, name in ipairs(names) do
          local linter = lint.linters[name]
          local cmd = type(linter) == "table" and linter.cmd or name
          if type(cmd) == "function" then
            cmd = cmd()
          end
          if vim.fn.executable(cmd) == 1 then
            table.insert(available, name)
          end
        end

        if #available > 0 then
          lint.try_lint(available)
        end
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("dotfiles_lint", { clear = true }),
        callback = lint_buffer,
      })

      vim.api.nvim_create_user_command("Lint", lint_buffer, { desc = "Lint the current buffer" })
    end,
  },
}
