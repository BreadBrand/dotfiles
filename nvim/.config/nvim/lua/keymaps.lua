vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

vim.keymap.set("v", "<", "<gv", { desc = "Unindent and keep selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent and keep selection" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

vim.keymap.set("n", "n", "nzzzv", { desc = "next search result cursor centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "previous search result cursor centered" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { desc = "make file exe", silent = true })

vim.keymap.set("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "toggle builtin undotree" })

vim.keymap.set("n", "<leader>e", ":Ex<CR>", { desc = "go to netrw" })

vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "go to left split" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "go to lower split" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "go to upper split" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "go to right split" })

vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "close all non-active buffers" })
vim.keymap.set("n", "<leader>nx", "<C-w>q", { desc = "close active window" })

vim.keymap.set("n", "<leader>nv", "<C-w><C-v>", { desc = "open a vert split" })

vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info().selected == -1 then
      -- Nothing selected yet — select first item, then accept it
      return "<C-n><C-y>"
    else
      -- Something already selected — just accept it
      return "<C-y>"
    end
  else
    return "<CR>"
  end
end, { expr = true, noremap = true })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })
vim.keymap.set("n", "<leader>vf", vim.lsp.buf.format, { desc = "format local buffer" })
