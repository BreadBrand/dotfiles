require("mason-nvim-dap").setup({
  ensure_installed = { "delve", "js-debug-adapter" },
})

require("dap-go").setup()

local dap = require("dap")

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "js-debug-adapter",
    args = { "${port}" },
  },
}

for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[lang] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

require("dap-view").setup()

dap.listeners.before.attach["dap-view-config"] = function() require("dap-view").open() end
dap.listeners.before.launch["dap-view-config"] = function() require("dap-view").open() end
dap.listeners.before.event_terminated["dap-view-config"] = function() require("dap-view").close() end
dap.listeners.before.event_exited["dap-view-config"] = function() require("dap-view").close() end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "dap toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "dap continue" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "dap step into" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "dap step over" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "dap step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "dap toggle repl" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "dap run last" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "dap terminate" })
