vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  { src = "https://github.com/rose-pine/neovim",                name = "rose-pine", },
  "https://github.com/nvim-mini/mini.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",             branch = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("rose-pine").setup()
vim.cmd.colorscheme("rose-pine")

--- mini notify ---
require("mini.notify").setup({
  content = {
    format = function(notify)
      return notify.msg
    end,
  },
})

--- mini cmdline completion ---
require("mini.cmdline").setup({
  autocorrect = { enable = false }
})

--- mini surround ---
require("mini.surround").setup({
  mappings = {
    add = "gza",
    delete = "gzd",
    find = "gzf",
    find_left = "gzF",
    highlight = "gzh",
    replace = "gzr",
    update_n_lines = "gzn",
  },
})

--- mini pick ---
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")

-- Centered on screen
local win_config = function()
  local height = math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)
  return {
    anchor = 'NW',
    height = height,
    width = width,
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

MiniPick.setup({
  window = {
    config = win_config,
  }
})
MiniExtra.setup()

vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "mini file picker" })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "mini live grep" })
vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "mini help picker" })
vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "mini buffer picker" })
vim.keymap.set("n", "<leader>fr", function() MiniPick.builtin.resume() end, { desc = "mini resume picker" })

vim.keymap.set("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "mini diagnostic picker" })
vim.keymap.set("n", "<leader>fk", function() MiniExtra.pickers.keymaps() end, { desc = "mini keymap picker" })

--- mini completion ---
local MiniCompletion = require("mini.completion")
MiniCompletion.setup({
  lsp_completion = {
    process_items = function(items, base)
      return MiniCompletion.default_process_items(items, base, {
        filtersort = "fuzzy",
      })
    end,
  }
})

local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  MiniCompletion.get_lsp_capabilities()
)

vim.lsp.config("*", { capabilities = capabilities })

--- mini diff ---
local MiniDiff = require("mini.diff")
MiniDiff.setup()

--- mini icons ---
local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

--- mason ---
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "ts_ls", "zls", "gopls", "marksman", "sqls" },
})

--- mini git ---
require("mini.git").setup()

--- mini.pairs ---
require("mini.pairs").setup()

--- mini clue (which-key) ---
local MiniClue = require("mini.clue")
MiniClue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },
  clues = {
    MiniClue.gen_clues.builtin_completion(),
    MiniClue.gen_clues.g(),
    MiniClue.gen_clues.marks(),
    MiniClue.gen_clues.registers(),
    MiniClue.gen_clues.windows(),
    MiniClue.gen_clues.z(),
  },
  window = {
    config = { width = "auto" },
  },
})
