--------------------------------------------------------------------------------
-- Location Docs: https://neovim.io/doc/user/starting.html#config
-- Location User: ~/.config/nvim/init.lua (the whole directory is linked)
-- Location Repo: none (.nvim.lua only with 'exrc', which is off)
-- Location Check: nvim --headless "+lua io.write(vim.env.MYVIMRC)" +qa
--------------------------------------------------------------------------------
-- LazyVim starter (https://github.com/LazyVim/starter) at 803bc18.

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
