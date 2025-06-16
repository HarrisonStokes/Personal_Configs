return {
    -- Mason for managing LSPs
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },

    -- Mason LSP config
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "clangd",        -- C/C++
                    "rust_analyzer", -- Rust
                    "bashls",        -- Bash
                    "pylsp",         -- Python
                    "html",          -- HTML
                    "cssls",         -- CSS
                    "ts_ls",         -- JavaScript/TypeScript
                },
                automatic_installation = false, -- Disable to prevent errors
            })
        end,
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local cmp_nvim_lsp = require("cmp_nvim_lsp")

            -- LSP keymaps (only set when LSP attaches)
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    local keymap = vim.keymap.set

                    keymap("n", "gD", vim.lsp.buf.declaration, opts)
                    keymap("n", "gd", vim.lsp.buf.definition, opts)
                    keymap("n", "K", vim.lsp.buf.hover, opts)
                    keymap("n", "gi", vim.lsp.buf.implementation, opts)
                    keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                    keymap("n", "gr", vim.lsp.buf.references, opts)
                    keymap("n", "[d", vim.diagnostic.goto_prev, opts)
                    keymap("n", "]d", vim.diagnostic.goto_next, opts)
                    keymap("n", "<leader>d", vim.diagnostic.open_float, opts)
                end,
            })

            local capabilities = cmp_nvim_lsp.default_capabilities()

            -- Configure diagnostic signs
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = "󰠠 ",
                        [vim.diagnostic.severity.INFO] = " ",
                    },
                },
            })
            -- Manual LSP setup (more reliable)
            local servers = {
                clangd = {
                    cmd = { "clangd", "--background-index" },
                },
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                            },
                        },
                    },
                },
                pylsp = {
                    settings = {
                        pylsp = {
                            plugins = {
                                pycodestyle = {
                                    maxLineLength = 100,
                                },
                            },
                        },
                    },
                },
                bashls = {},
                html = {},
                cssls = {},
                ts_ls = {},
            }

            for server, config in pairs(servers) do
                config.capabilities = capabilities
                lspconfig[server].setup(config)
            end
        end,
    },

    -- Additional tools
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "prettier",
                    "stylua",
                    "black",
                    "isort",
                    "eslint_d",
                },
            })
        end,
    },
}
