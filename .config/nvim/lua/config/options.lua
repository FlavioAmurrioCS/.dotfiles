-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Config files Neovim doesn't recognise by name. VS Code and cmux read their
-- settings as JSON with comments.
vim.filetype.add({
  filename = { shellcheckrc = "conf", [".shellcheckrc"] = "conf" },
  pattern = {
    [".*/%.vscode/.*%.json"] = "jsonc",
    [".*/cmux/cmux%.json"] = "jsonc",
  },
})
