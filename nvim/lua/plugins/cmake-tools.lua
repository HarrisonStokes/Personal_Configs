return {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "c", "cpp", "cmake" },
    config = function()
        require("cmake-tools").setup({
            cmake_command = "cmake",
            cmake_build_command = "cmake",
            cmake_build_directory = "build",
            cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
            cmake_build_options = { "-j" .. vim.fn.system("nproc"):gsub("\n", "") },
            cmake_console = {
                name = "Main",
                location = "belowright",
                opts = {
                    height = 15,
                },
                auto_focus = true
            },
            cmake_variants_message = {
                short = { show = true },
                long = { show = true, max_length = 40 }
            },
            cmake_dap_configuration = {
                name = "cpp",
                type = "codelldb",
                request = "launch",
                stopOnEntry = false,
                runInTerminal = true,
                console = "integratedTerminal",
            },
        })
        
        -- Keymaps for CMake
        local keymap = vim.keymap.set
        keymap("n", "<leader>cg", "<cmd>CMakeGenerate<cr>", { desc = "CMake Generate" })
        keymap("n", "<leader>cb", "<cmd>CMakeBuild<cr>", { desc = "CMake Build" })
        keymap("n", "<leader>cr", "<cmd>CMakeRun<cr>", { desc = "CMake Run" })
        keymap("n", "<leader>cd", "<cmd>CMakeDebug<cr>", { desc = "CMake Debug" })
        keymap("n", "<leader>cy", "<cmd>CMakeSelectBuildType<cr>", { desc = "CMake Select Build Type" })
        keymap("n", "<leader>ct", "<cmd>CMakeSelectBuildTarget<cr>", { desc = "CMake Select Build Target" })
        keymap("n", "<leader>cT", "<cmd>CMakeSelectLaunchTarget<cr>", { desc = "CMake Select Launch Target" })
        keymap("n", "<leader>cc", "<cmd>CMakeClean<cr>", { desc = "CMake Clean" })
        keymap("n", "<leader>cs", "<cmd>CMakeStop<cr>", { desc = "CMake Stop" })
    end,
}
