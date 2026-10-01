require("mason-nvim-dap").setup({
  ensure_installed = { "delve", "js" },
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

require("dap-view").setup({
  winbar = {
    sections = { "scopes", "exceptions" },
    default_section = "scopes",
    controls = { enabled = true }, -- clickable play / step into / over / out / stop
  },
  windows = {
    position = "right", -- tall pane suits a variable list
    size = 0.3,
    terminal = { hide = true }, -- no separate console window
  },
  virtual_text = { enabled = true }, -- inline values, only drawn during a session; toggle with <leader>dv
})

dap.listeners.before.attach["dap-view-config"] = function() require("dap-view").open() end
dap.listeners.before.launch["dap-view-config"] = function() require("dap-view").open() end
dap.listeners.before.event_terminated["dap-view-config"] = function() require("dap-view").close() end
dap.listeners.before.event_exited["dap-view-config"] = function() require("dap-view").close() end

-- Nerd Font glyphs written as codepoints so they survive any editor/encoding
local signs = {
  DapBreakpoint = { text = "\u{eaa9}", texthl = "DiagnosticError" },
  DapBreakpointCondition = { text = "\u{eaa7}", texthl = "DiagnosticWarn" },
  DapBreakpointRejected = { text = "\u{eb8c}", texthl = "DiagnosticHint" },
  DapLogPoint = { text = "\u{eaab}", texthl = "DiagnosticInfo" },
  DapStopped = { text = "\u{f04b}", texthl = "DiagnosticOk", linehl = "CursorLine" },
}
for name, sign in pairs(signs) do
  vim.fn.sign_define(name, sign)
end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "dap toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Break when: "))
end, { desc = "dap conditional breakpoint" })
vim.keymap.set("n", "<leader>dh", function()
  dap.set_breakpoint(nil, vim.fn.input("Hit count (e.g. >= 10): "))
end, { desc = "dap hit-count breakpoint" })
vim.keymap.set("n", "<leader>dp", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log message (use {expr}): "))
end, { desc = "dap logpoint" })
vim.keymap.set("n", "<leader>dx", dap.clear_breakpoints, { desc = "dap clear all breakpoints" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "dap continue" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "dap step into" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "dap step over" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "dap step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "dap toggle repl" })
vim.keymap.set("n", "<leader>dv", "<cmd>DapViewVirtualTextToggle<cr>", { desc = "dap toggle inline values" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "dap run last" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "dap terminate" })
