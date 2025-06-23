return {
    -- Better C++ syntax highlighting
    {
        "octol/vim-cpp-enhanced-highlight",
        ft = { "c", "cpp" },
        config = function()
            vim.g.cpp_class_scope_highlight = 1
            vim.g.cpp_member_variable_highlight = 1
            vim.g.cpp_class_decl_highlight = 1
            vim.g.cpp_posix_standard = 1
            vim.g.cpp_experimental_simple_template_highlight = 1
        end,
    },
    
    -- Better comment support for C++
    {
        "numToStr/Comment.nvim",
        ft = { "c", "cpp" },
        config = function()
            require("Comment").setup({
                toggler = {
                    line = '<leader>/',
                    block = '<leader>?',
                },
                opleader = {
                    line = '<leader>/',
                    block = '<leader>?',
                },
            })
        end,
    },
}
