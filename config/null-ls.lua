local M = {}

function M.setup()
  local null_ls = require("null-ls")
  local helpers = require("null-ls.helpers")
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  null_ls.setup({
    -- you can reuse a shared lspconfig on_attach callback here
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
            -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
    end,

    sources = {
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.code_actions.eslint_d
    }
  })

  local markdownlint = {
    name = "markdownlint",
    filetypes = { "markdown" },
    method = null_ls.methods.DIAGNOSTICS,
    generator = null_ls.generator({
      command = "markdownlint",
      -- args = { "--stdin", "--disable MD013" },
      -- args = { "--stdin", "--config $HOME/.config/lvim/lua/config/.markdownlint.jsonc" },
      args = { "--stdin" },
      to_stdin = true,
      from_stderr = true,
      -- choose an output format (raw, json, or line)
      format = "line",
      check_exit_code = function(code, stderr)
        local success = code <= 1

        if not success then
          -- can be noisy for things that run often (e.g. diagnostics), but can
          -- be useful for things that run on demand (e.g. formatting)
          print(stderr)
        end

        return success
      end,
      -- use helpers to parse the output from string matchers,
      -- or parse it manually with a function
      on_output = helpers.diagnostics.from_patterns({
        {
          pattern = [[:(%d+):(%d+) ([%w-/]+) (.*)]],
          groups = { "row", "col", "code", "message" },
          overrides = { diagnostic = { severity = 2 } },
        },
        {
          pattern = [[:(%d+) ([%w-/]+) (.*)]],
          groups = { "row", "code", "message" },
          overrides = { diagnostic = { severity = 2 } },
        },
      }),
    })
  }

  null_ls.register(markdownlint)
end

return M
