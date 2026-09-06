vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("pack")

require("vim._core.ui2").enable({
  enable = true,
})

require("options")
require("keymaps")
require("commands")
require("diagnostics")
require("treesitter")
require("nvimlualine")
