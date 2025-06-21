return {
  -- Enhanced completion sources
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    dependencies = "nvim-cmp",
  },
  
  -- Tailwind CSS completion and colorization
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    dependencies = "nvim-cmp",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  -- CSS completion enhancements
  {
    "Jezda1337/nvim-html-css",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("html-css"):setup({
        file_extensions = { "css", "sass", "less", "scss", "html", "vue", "svelte", "jsx", "tsx" },
        style_sheets = {
          -- Add paths to your CSS files
          -- Example: vim.fn.getcwd() .. "/src/styles/*.css",
        }
      })
    end,
    ft = { "html", "css", "sass", "scss", "less", "vue", "svelte", "jsx", "tsx", "astro" },
  },

  -- Universal LSP configuration for all tag-based languages
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "williamboman/mason.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Enhanced capabilities for better completion
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        }
      }

      -- HTML Language Server - enhanced for all HTML-like languages
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
              wrapLineLength = 120,
              unformatted = "wbr",
              contentUnformatted = "pre,code,textarea",
              indentInnerHtml = true,
              preserveNewLines = true,
              maxPreserveNewLines = 2,
              indentHandlebars = true,  -- Enable for template languages
              endWithNewline = false,
              extraLiners = "head, body, /html",
              wrapAttributes = "auto"
            },
            suggest = {
              html5 = true,
              angular1 = false,
              ionic = false
            },
            validate = {
              scripts = true,
              styles = true
            },
            completion = {
              attributeDefaultValue = "doublequotes"
            },
            hover = {
              documentation = true,
              references = true
            }
          }
        },
        init_options = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true
          },
          provideFormatter = true
        }
      })

      -- CSS Language Server - enhanced for all CSS-like languages
      lspconfig.cssls.setup({
        capabilities = capabilities,
        filetypes = { "css", "scss", "sass", "less" },
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            },
            completion = {
              triggerPropertyValueCompletion = true,
              completePropertyWithSemicolon = true
            }
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            },
            completion = {
              triggerPropertyValueCompletion = true,
              completePropertyWithSemicolon = true
            }
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            },
            completion = {
              triggerPropertyValueCompletion = true,
              completePropertyWithSemicolon = true
            }
          }
        }
      })

      -- TypeScript/JavaScript for JSX/TSX
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        filetypes = { 
          "javascript", "javascriptreact", "typescript", "typescriptreact",
          "jsx", "tsx"
        },
        settings = {
          typescript = {
            preferences = {
              includeCompletionsForModuleExports = true,
              includeCompletionsForImportStatements = true
            },
            suggest = {
              includeCompletionsForModuleExports = true
            }
          },
          javascript = {
            preferences = {
              includeCompletionsForModuleExports = true,
              includeCompletionsForImportStatements = true
            },
            suggest = {
              includeCompletionsForModuleExports = true
            }
          }
        }
      })

      -- Vue Language Server
      lspconfig.volar.setup({
        capabilities = capabilities,
        filetypes = { "vue" },
        settings = {
          vue = {
            complete = {
              casing = {
                tags = "kebab",
                props = "camel"
              }
            }
          }
        }
      })

      -- Svelte Language Server
      lspconfig.svelte.setup({
        capabilities = capabilities,
        filetypes = { "svelte" },
        settings = {
          svelte = {
            plugin = {
              html = {
                completions = {
                  enable = true,
                  emmet = true
                }
              },
              svelte = {
                completions = {
                  enable = true
                }
              }
            }
          }
        }
      })

      -- Astro Language Server
      lspconfig.astro.setup({
        capabilities = capabilities,
        filetypes = { "astro" }
      })

      -- PHP Language Server (for PHP with HTML)
      lspconfig.phpactor.setup({
        capabilities = capabilities,
        filetypes = { "php" },
        settings = {
          phpactor = {
            completion = {
              insertUseStatements = true
            }
          }
        }
      })

      -- Tailwind CSS Language Server
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
        filetypes = { 
          "html", "css", "scss", "sass", "javascript", "javascriptreact", 
          "typescript", "typescriptreact", "vue", "svelte", "astro", "php"
        },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                "tw`([^`]*)",
                "tw=\"([^\"]*)",
                "tw={\"([^\"}]*)",
                "tw\\.\\w+`([^`]*)",
                "tw\\(.*?\\)`([^`]*)"
              }
            }
          }
        }
      })

      -- Emmet Language Server for better completion
      lspconfig.emmet_ls.setup({
        capabilities = capabilities,
        filetypes = { 
          "html", "css", "sass", "scss", "less", "javascriptreact", 
          "typescriptreact", "vue", "svelte", "astro"
        },
        settings = {
          emmet = {
            includeLanguages = {
              ["javascript"] = "javascriptreact",
              ["typescript"] = "typescriptreact"
            }
          }
        }
      })
    end,
  },

  -- XML and markup language support
  {
    "amadeus/vim-xml",
    ft = { "xml", "xsl", "xslt", "xsd", "wsdl", "svg", "xaml", "plist" },
    config = function()
      -- Enhanced XML settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "xml", "xsl", "xslt", "xsd", "wsdl", "svg", "xaml", "plist" },
        callback = function()
          vim.opt_local.foldmethod = "syntax"
          vim.opt_local.foldlevel = 3
          vim.opt_local.iskeyword:append(":")
          vim.opt_local.iskeyword:append("-")
        end,
      })
    end,
  },

  -- Additional template language support
  {
    "mustache/vim-mustache-handlebars",
    ft = { "mustache", "handlebars" }
  },

  {
    "tpope/vim-liquid",
    ft = { "liquid" }
  },

  {
    "posva/vim-vue",
    ft = { "vue" }
  },

  {
    "leafOfTree/vim-svelte-plugin",
    ft = { "svelte" }
  }
}
