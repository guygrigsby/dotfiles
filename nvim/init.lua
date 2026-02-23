vim.cmd("source $DOTFILES/nvim/vimrc.vim")
require("config.lazy")
require("opencode")
require("lazy").setup("plugins")
