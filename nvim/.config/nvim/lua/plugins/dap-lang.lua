return {
    "mfussenegger/nvim-dap",
    config = function()
        local dap = require("dap")

        -- codelldb adapter (used by Zig, C, C++, Rust)
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                args = { "--port", "${port}" },
            },
        }

        -- Zig
        dap.configurations.zig = {
            {
                name = "Debug",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to binary: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }

        -- JavaScript / TypeScript (needs js-debug-adapter)
        dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter",
                args = { "${port}" },
            },
        }

        for _, lang in ipairs({ "javascript", "typescript" }) do
            dap.configurations[lang] = {
                {
                    name = "Launch",
                    type = "pwa-node",
                    request = "launch",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },
            }
        end

        -- Go (needs delve)
        dap.adapters.delve = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
                args = { "dap", "-l", "127.0.0.1:${port}" },
            },
        }

        dap.configurations.go = {
            {
                name = "Debug",
                type = "delve",
                request = "launch",
                program = "${file}",
            },
        }
    end,
}
