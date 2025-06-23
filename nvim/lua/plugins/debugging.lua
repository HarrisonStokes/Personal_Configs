return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio"
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            
            -- Setup dap-ui
            dapui.setup()
            
            -- Setup virtual text
            require("nvim-dap-virtual-text").setup()
            
            -- GDB adapter for C++
            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "-i", "dap" }
            }
            
            -- C++ configuration
            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                    setupCommands = {
                        {
                            text = "-enable-pretty-printing",
                            description = "enable pretty printing",
                            ignoreFailures = false
                        },
                    },
                },
                {
                    name = "Attach to gdbserver :1234",
                    type = "gdb",
                    request = "attach",
                    target = "localhost:1234",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
                    end,
                    cwd = "${workspaceFolder}"
                }
            }
            
            -- C configuration (same as C++)
            dap.configurations.c = dap.configurations.cpp
            
            -- Auto-open/close dap-ui
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            
            -- Debugging keymaps
            local keymap = vim.keymap.set
            keymap("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
            keymap("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
            keymap("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
            keymap("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
            keymap("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
            keymap("n", "<leader>B", function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, { desc = "Debug: Set Conditional Breakpoint" })
            keymap("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })
        end,
    }
}
