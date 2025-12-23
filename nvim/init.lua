-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.cmd("source $MYVIMRC/../copy.vim")

-- Auto line break
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.textwidth = 80
vim.opt.formatoptions:append("t")
