local M = {}

function M.setup()
  local pid = vim.fn.getpid()
  -- On linux/darwin if using a release build, otherwise under scripts/OmniSharp(.Core)(.cmd)
  local omnisharp_bin = "/usr/local/src/omnisharp/run"
  -- on Windows
  -- local omnisharp_bin = "C:\\dev\\omnisharp\\OmniSharp.exe"

  local config = {
    handlers = {
      ["textDocument/definition"] = require('omnisharp_extended').handler,
    },
    cmd = { omnisharp_bin, '--languageserver', '--hostPID', tostring(pid) },
    -- rest of your settings
  }

  require 'lspconfig'.omnisharp.setup(config)
end

return M
