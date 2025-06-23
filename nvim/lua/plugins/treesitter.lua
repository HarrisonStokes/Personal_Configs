return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects", -- Better text objects
    -- Removed nvim-ts-autotag from here since it's configured separately
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Install parsers for all supported languages (only available ones)
      ensure_installed = {
        -- Core web languages
        "html", "xml", "css", "scss", "qmljs",
        
        -- JavaScript/TypeScript family (jsx is part of javascript parser)
        "javascript", "typescript", "tsx",
        
        -- Frontend frameworks
        -- "vue", "svelte",
        
        -- Server-side languages with HTML
        "php", "ruby", "python", "java",
        
        -- Markup and documentation
        "markdown", "markdown_inline",
        
        -- Configuration languages with tag-like syntax
        "yaml", "toml", "json", "json5", "jsonc",
        
        -- Other useful languages from your original config
        "c", "cpp", "rust", "lua", "vim", "bash", "verilog",
        
        -- Additional web-related
        "dockerfile", "graphql", "regex"
      },
      
      -- Automatically install missing parsers when entering buffer
      auto_install = true,
      
      -- Syntax highlighting
      highlight = {
        enable = true,
        -- Additional vim regex highlighting for languages not supported by treesitter
        additional_vim_regex_highlighting = { "php", "ruby" },
      },
      
      -- Indentation based on treesitter
      indent = {
        enable = true,
        -- Disable for problematic languages
        disable = { "python", "yaml" }
      },
      
      -- Enhanced text objects
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Tags and elements
            ["at"] = "@tag.outer",
            ["it"] = "@tag.inner",
            ["aa"] = "@attribute.outer", 
            ["ia"] = "@attribute.inner",
            
            -- Functions and classes
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            
            -- Blocks and statements
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["as"] = "@statement.outer",
            
            -- Comments
            ["aC"] = "@comment.outer",
            ["iC"] = "@comment.inner",
            
            -- Parameters and arguments
            ["ap"] = "@parameter.outer",
            ["ip"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- Add to jumplist
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]t"] = "@tag.outer",
            ["]a"] = "@attribute.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]T"] = "@tag.outer",
            ["]A"] = "@attribute.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer", 
            ["[c"] = "@class.outer",
            ["[t"] = "@tag.outer",
            ["[a"] = "@attribute.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[T"] = "@tag.outer",
            ["[A"] = "@attribute.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>swf"] = "@function.outer",
            ["<leader>swp"] = "@parameter.inner",
            ["<leader>swt"] = "@tag.outer",
          },
          swap_previous = {
            ["<leader>sWf"] = "@function.outer",
            ["<leader>sWp"] = "@parameter.inner", 
            ["<leader>sWt"] = "@tag.outer",
          },
        },
      },
      
      -- REMOVED: autotag configuration (now handled by separate autoclose-tags.lua)
      
      -- Additional language-specific configurations
      playground = {
        enable = true,
        disable = {},
        updatetime = 25,
        persist_queries = false,
      },
      
      -- Rainbow parentheses for better bracket matching
      rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
      }
    })
    
    -- Set up additional filetype mappings for better detection
    vim.filetype.add({
      extension = {
        -- Template files
        hbs = "handlebars",
        mustache = "mustache", 
        twig = "twig",
        liquid = "liquid",
        ejs = "ejs",
        erb = "eruby",
        
        -- Frontend framework files
        vue = "vue",
        svelte = "svelte",
        astro = "astro",
        
        -- JSX/TSX variants
        jsx = "javascriptreact",
        tsx = "typescriptreact",
        
        -- CSS variants
        scss = "scss",
        sass = "sass",
        less = "less",
        
        -- Markup variants
        mdx = "mdx",
        
        -- Config files with tag-like syntax
        xaml = "xml",
        plist = "xml",
        
        -- Server-side template files
        jsp = "jsp",
        asp = "asp",
        razor = "razor"
      },
      pattern = {
        -- Laravel Blade templates
        [".*%.blade%.php"] = "blade",
        
        -- Django templates
        [".*%.html%.django"] = "django",
        [".*%.html%.jinja"] = "jinja",
        [".*%.html%.j2"] = "jinja",
        
        -- Rails templates
        [".*%.html%.erb"] = "eruby",
        
        -- Handlebars templates
        [".*%.html%.hbs"] = "handlebars",
        [".*%.html%.handlebars"] = "handlebars",
        
        -- Mustache templates
        [".*%.html%.mustache"] = "mustache",
        
        -- Liquid templates (Jekyll, Shopify)
        [".*%.html%.liquid"] = "liquid",
        
        -- EJS templates
        [".*%.html%.ejs"] = "ejs",
        
        -- Twig templates (Symfony)
        [".*%.html%.twig"] = "twig",
      }
    })
    
    -- Enhanced folding for template and markup languages
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { 
        "html", "xml", "vue", "svelte", "jsx", "tsx", "astro",
        "handlebars", "mustache", "twig", "liquid", "ejs", "erb"
      },
      callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
        vim.opt_local.foldlevel = 2
      end,
    })
    
    -- Set up better indentation for template languages
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { 
        "html", "xml", "vue", "svelte", "jsx", "tsx", "astro",
        "handlebars", "mustache", "twig", "liquid", "ejs", "erb", "blade"
      },
      callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true
      end,
    })
    
    -- Additional key mappings for treesitter text objects
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { 
        "html", "xml", "vue", "svelte", "jsx", "tsx", "astro",
        "handlebars", "mustache", "twig", "liquid", "ejs", "erb"
      },
      callback = function()
        local opts = { buffer = true, silent = true }
        
        -- Quick tag selection
        vim.keymap.set({ "n", "v" }, "<leader>vt", "vat", opts) -- Select outer tag
        vim.keymap.set({ "n", "v" }, "<leader>vi", "vit", opts) -- Select inner tag
        
        -- Quick attribute selection
        vim.keymap.set({ "n", "v" }, "<leader>va", "vaa", opts) -- Select outer attribute
        vim.keymap.set({ "n", "v" }, "<leader>vA", "via", opts) -- Select inner attribute
      end,
    })
  end,
}
