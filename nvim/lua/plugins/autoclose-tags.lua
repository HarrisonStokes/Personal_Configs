return {
  "windwp/nvim-ts-autotag",
  ft = { 
    -- Web Languages
    "html", "xhtml", "xml", "svg", "xaml",
    -- JavaScript/TypeScript
    "javascript", "javascriptreact", "typescript", "typescriptreact", "jsx", "tsx",
    -- Frameworks & Libraries  
    "vue", "svelte", "astro", "solid",
    -- Template Languages
    "php", "erb", "ejs", "handlebars", "mustache", "twig", "blade", "jinja", "django",
    -- Server-side
    "jsp", "asp", "razor", "liquid",
    -- Markup
    "markdown", "mdx"
  },
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        -- Enable all features
        enable_close = true,          -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = true  -- Auto close on trailing </
      },
      
      -- Per-filetype configuration
      per_filetype = {
        -- Standard web languages
        ["html"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["xhtml"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["xml"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["svg"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["xaml"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        
        -- JavaScript/TypeScript variants
        ["javascript"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false -- JSX uses different syntax
        },
        ["javascriptreact"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        ["typescript"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        ["typescriptreact"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        ["jsx"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        ["tsx"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        
        -- Frontend frameworks
        ["vue"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["svelte"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["astro"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["solid"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false
        },
        
        -- Server-side and template languages
        ["php"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["erb"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["ejs"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["handlebars"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["mustache"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["twig"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["blade"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["jinja"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["django"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["jsp"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["asp"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["razor"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["liquid"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        
        -- Markup languages
        ["markdown"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true
        },
        ["mdx"] = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false -- MDX uses JSX syntax
        }
      }
    })
    
    -- Additional custom auto-close functionality for languages not fully supported by treesitter
    local function setup_custom_autoclose()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { 
          "handlebars", "mustache", "twig", "blade", "jinja", "django", 
          "liquid", "jsp", "asp", "razor", "ejs"
        },
        callback = function()
          local opts = { buffer = true, silent = true }
          
          -- Custom mappings for template-specific tags
          local filetype = vim.bo.filetype
          
          if filetype == "handlebars" or filetype == "mustache" then
            -- {{}} blocks
            vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{{{", "{{{  }}}<Left><Left><Left><Left>", opts)
          end
          
          if filetype == "twig" then
            -- Twig syntax
            vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{%", "{%  %}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{#", "{#  #}<Left><Left><Left>", opts)
          end
          
          if filetype == "blade" then
            -- Laravel Blade syntax
            vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{!!", "{!!  !!}<Left><Left><Left><Left>", opts)
            vim.keymap.set("i", "@{", "@{  }<Left><Left>", opts)
          end
          
          if filetype == "jinja" or filetype == "django" then
            -- Jinja2/Django syntax
            vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{%", "{%  %}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{#", "{#  #}<Left><Left><Left>", opts)
          end
          
          if filetype == "liquid" then
            -- Liquid syntax
            vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
            vim.keymap.set("i", "{%", "{%  %}<Left><Left><Left>", opts)
          end
          
          if filetype == "jsp" then
            -- JSP syntax
            vim.keymap.set("i", "<%", "<%  %><Left><Left><Left>", opts)
            vim.keymap.set("i", "<%=", "<%=  %><Left><Left><Left>", opts)
          end
          
          if filetype == "asp" then
            -- ASP syntax
            vim.keymap.set("i", "<%", "<%  %><Left><Left><Left>", opts)
            vim.keymap.set("i", "<%=", "<%=  %><Left><Left><Left>", opts)
          end
          
          if filetype == "razor" then
            -- Razor syntax
            vim.keymap.set("i", "@{", "@{  }<Left><Left>", opts)
            vim.keymap.set("i", "@(", "@(  )<Left><Left>", opts)
          end
          
          if filetype == "ejs" then
            -- EJS syntax
            vim.keymap.set("i", "<%", "<%  %><Left><Left><Left>", opts)
            vim.keymap.set("i", "<%=", "<%=  %><Left><Left><Left>", opts)
            vim.keymap.set("i", "<%-", "<%-  %><Left><Left><Left>", opts)
          end
        end,
      })
    end
    
    setup_custom_autoclose()
    
    -- Show notification when autotag is loaded
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { 
        "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact",
        "vue", "svelte", "php", "jsx", "tsx"
      },
      once = false,
      callback = function()
        -- Only show message once per session
        if not vim.g.autotag_message_shown then
          vim.notify("Auto-closing tags enabled for " .. vim.bo.filetype, vim.log.levels.INFO)
          vim.g.autotag_message_shown = true
        end
      end,
    })
  end,
}
