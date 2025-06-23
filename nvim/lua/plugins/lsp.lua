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
            local mason_lspconfig = require("mason-lspconfig")

            -- Basic setup with ONLY valid Mason package names
            mason_lspconfig.setup({
                ensure_installed = {
                    -- Original core languages
                    "clangd",        -- C/C++
                    "rust_analyzer", -- Rust
                    "bashls",        -- Bash
                    "pylsp",         -- Python

                    -- Web languages - core
                    "html",          -- HTML
                    "cssls",         -- CSS
                    "ts_ls",         -- JavaScript/TypeScript

                    -- PHP
                    "intelephense",  -- PHP (more reliable than phpactor)

                    -- Additional useful servers
                    "marksman",      -- Markdown

                    "cmake",
                },
                automatic_installation = true,
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
            local mason_lspconfig = require("mason-lspconfig")
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

            -- Setup handlers for Mason-installed servers
            local handlers = {
                -- Default handler for servers without custom config
                function(server_name)
                    lspconfig[server_name].setup({
                        capabilities = capabilities,
                    })
                end,

                -- Custom handler for clangd
                ["clangd"] = function()
                    lspconfig.clangd.setup({
                        cmd = { 
                            "clangd", 
                            "--background-index",
                            "--clang-tidy",
                            "--header-insertion=iwyu",
                            "--completion-style=detailed",
                            "--function-arg-placeholders",
                            "--fallback-style=llvm",
                            "--query-driver=/usr/bin/g++,/usr/bin/clang++",
                            "--compile-commands-dir=build"
                        },
                        capabilities = capabilities,
                        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                        init_options = {
                            usePlaceholders = true,
                            completeUnimported = true,
                            clangdFileStatus = true,
                        },
                        settings = {
                            clangd = {
                                semanticHighlighting = true,
                                fallbackFlags = { "-std=c++20" },
                            }
                        },
                        on_attach = function(client, bufnr)
                            -- Qt-specific settings
                            vim.api.nvim_buf_set_option(bufnr, 'commentstring', '// %s')
                        end,
                    })
                end,

                ["cmake"] = function()
                    lspconfig.cmake.setup({
                        capabilities = capabilities,
                        filetypes = { "cmake" },
                    })
                end,

                -- Custom handler for rust_analyzer
                ["rust_analyzer"] = function()
                    lspconfig.rust_analyzer.setup({
                        capabilities = capabilities,
                        settings = {
                            ["rust-analyzer"] = {
                                cargo = {
                                    allFeatures = true,
                                },
                            },
                        },
                    })
                end,

                -- Custom handler for pylsp
                ["pylsp"] = function()
                    lspconfig.pylsp.setup({
                        capabilities = capabilities,
                        settings = {
                            pylsp = {
                                plugins = {
                                    pycodestyle = {
                                        maxLineLength = 100,
                                    },
                                },
                            },
                        },
                    })
                end,

                -- Enhanced HTML LSP for template languages
                ["html"] = function()
                    lspconfig.html.setup({
                        capabilities = capabilities,
                        filetypes = { 
                            "html", "xhtml", "handlebars", "mustache", "blade", "twig", 
                            "ejs", "erb", "liquid", "jsp", "asp", "razor"
                        },
                        settings = {
                            html = {
                                format = {
                                    templating = true,
                                    indentHandlebars = true,
                                },
                                suggest = {
                                    html5 = true,
                                },
                            },
                        },
                    })
                end,

                -- Enhanced CSS LSP
                ["cssls"] = function()
                    lspconfig.cssls.setup({
                        capabilities = capabilities,
                        filetypes = { "css", "scss", "sass", "less" },
                        settings = {
                            css = {
                                validate = true,
                                lint = {
                                    unknownAtRules = "ignore"
                                }
                            },
                        },
                    })
                end,

                -- PHP support with Intelephense
                ["intelephense"] = function()
                    lspconfig.intelephense.setup({
                        capabilities = capabilities,
                        filetypes = { "php" },
                        settings = {
                            intelephense = {
                                files = {
                                    maxSize = 1000000,
                                },
                            },
                        },
                    })
                end,
            }

            -- Try different methods based on mason-lspconfig version
            local setup_success = false

            -- Method 1: Try new API
            if not setup_success then
                local success = pcall(function()
                    mason_lspconfig.setup({
                        handlers = handlers
                    })
                end)
                if success then
                    setup_success = true
                end
            end

            -- Method 2: Try old API
            if not setup_success and mason_lspconfig.setup_handlers then
                local success = pcall(function()
                    mason_lspconfig.setup_handlers(handlers)
                end)
                if success then
                    setup_success = true
                end
            end

            -- Method 3: Manual setup if both methods fail
            if not setup_success then
                local servers = {
                    clangd = {
                        cmd = { "clangd", "--background-index" },
                        capabilities = capabilities,
                    },
                    rust_analyzer = {
                        capabilities = capabilities,
                        settings = {
                            ["rust-analyzer"] = {
                                cargo = { allFeatures = true },
                            },
                        },
                    },
                    pylsp = {
                        capabilities = capabilities,
                        settings = {
                            pylsp = {
                                plugins = {
                                    pycodestyle = { maxLineLength = 100 },
                                },
                            },
                        },
                    },
                    bashls = { capabilities = capabilities },
                    html = { 
                        capabilities = capabilities,
                        filetypes = { 
                            "html", "xhtml", "handlebars", "mustache", "blade", "twig", 
                            "ejs", "erb", "liquid", "jsp", "asp", "razor"
                        },
                    },
                    cssls = { 
                        capabilities = capabilities,
                        filetypes = { "css", "scss", "sass", "less" },
                    },
                    ts_ls = { capabilities = capabilities },
                    intelephense = { 
                        capabilities = capabilities,
                        filetypes = { "php" },
                    },
                    marksman = { capabilities = capabilities },
                }

                for server_name, config in pairs(servers) do
                    lspconfig[server_name].setup(config)
                end
            end

            -- Optional: Setup additional servers that may not be available via Mason
            -- These will only work if you manually install them

            -- Vue.js (if available)
            pcall(function()
                lspconfig.volar.setup({
                    capabilities = capabilities,
                    filetypes = { "vue" },
                })
            end)

            -- Svelte (if available)
            pcall(function()
                lspconfig.svelte.setup({
                    capabilities = capabilities,
                    filetypes = { "svelte" },
                })
            end)

            -- Tailwind CSS (if available)
            pcall(function()
                lspconfig.tailwindcss.setup({
                    capabilities = capabilities,
                    filetypes = { 
                        "html", "css", "scss", "sass", "javascript", "javascriptreact", 
                        "typescript", "typescriptreact", "vue", "svelte", "php"
                    },
                })
            end)

            -- Emmet Language Server (if available)
            pcall(function()
                lspconfig.emmet_ls.setup({
                    capabilities = capabilities,
                    filetypes = { 
                        "html", "css", "sass", "scss", "less", "javascriptreact", 
                        "typescriptreact", "vue", "svelte"
                    },
                })
            end)

            -- JSON Language Server (if available)
            pcall(function()
                lspconfig.jsonls.setup({
                    capabilities = capabilities,
                    filetypes = { "json", "jsonc" },
                })
            end)

            -- YAML Language Server (if available)
            pcall(function()
                lspconfig.yamlls.setup({
                    capabilities = capabilities,
                    filetypes = { "yaml", "yml" },
                })
            end)
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

                    "clang-format",
                    "cpplint",
                    "cmake-language-server",

                    "shellcheck",
                    "markdownlint",
                },
            })
        end,
    },
}
